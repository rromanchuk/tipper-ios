//
//  WalletDelegate.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 11/11/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
import PassKit
import Stripe
import ApplePayStubs
import SwiftyJSON

class PaymentController: NSObject, PKPaymentAuthorizationViewControllerDelegate, STPCheckoutViewControllerDelegate {
    weak var walletDelegate: UIViewController?
    
    var market: Market
    let stripeCheckout = STPCheckoutViewController()
    let ApplePayMerchantID = Config.get("APPLE_PAY_MERCHANT")
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
    
    var applePaySupported: Bool {
        get {
            let paymentRequest = Stripe.paymentRequestWithMerchantIdentifier(ApplePayMerchantID)
            return PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks) && Stripe.canSubmitPaymentRequest(paymentRequest) ? true : false
        }
    }
    
    init(withMarket: Market) {
        market = withMarket
    }
    
    func pay() {
        log.verbose("")
        let request = PKPaymentRequest()
        request.merchantIdentifier = ApplePayMerchantID
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.Capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        let amount = (market.amount! as NSString).doubleValue
        request.paymentSummaryItems = [PKPaymentSummaryItem(label: "Tipper \(Settings.sharedInstance.fundAmount!)BTC deposit", amount: NSDecimalNumber(double: amount))]
        if Stripe.canSubmitPaymentRequest(request) {
            #if DEBUG
                log.info("in debug mode")
                let applePayController = STPTestPaymentAuthorizationViewController(paymentRequest: request)
                applePayController.delegate = paymentController
                self.presentViewController(applePayController, animated: true, completion: nil)
            #else
                let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
                applePayController.delegate = self
                walletDelegate?.presentViewController(applePayController, animated: true, completion: nil)
            #endif
        } else {
            launchStripeFlow()
        }
    }
    
    private func launchStripeFlow() {
        //default to Stripe's PaymentKit Form
        let options = STPCheckoutOptions()
        let amount = (market.amount! as NSString).doubleValue
        options.purchaseDescription = "Tipper \(Settings.sharedInstance.fundAmount) deposit";
        options.purchaseAmount = UInt(amount * 100)
        options.companyName = "Tipper"
        let checkoutViewController = STPCheckoutViewController(options: options)
        checkoutViewController.checkoutDelegate = self
        walletDelegate?.presentViewController(checkoutViewController, animated: true, completion: nil)
    }
    
    private func createBackendChargeWithToken(token: STPToken, completion: STPTokenSubmissionHandler) {
        log.verbose("")
        API.sharedInstance.charge(token.tokenId, amount:self.market.amount!, completion: { [weak self] (json, error) -> Void in
            if (error != nil) {
                completion(STPBackendChargeResult.Failure, error)
            } else {
                //self?.currentUser.updateEntityWithJSON(json)
                completion(STPBackendChargeResult.Success, nil)
                //TSMessage.showNotificationInViewController(self?.parentViewController!, title: "Payment complete", subtitle: "Your bitcoin will arrive shortly.", type: .Success, duration: 5.0)
            }
            })
    }

    
    // MARK: STPCheckoutViewControllerDelegate
    func checkoutController(controller: STPCheckoutViewController, didCreateToken token: STPToken, completion: STPTokenSubmissionHandler) {
        log.verbose("")
        createBackendChargeWithToken(token, completion: completion)
    }
    
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        log.verbose("")
        walletDelegate?.parentViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkoutController(controller: STPCheckoutViewController, didFinishWithStatus status: STPPaymentStatus, error: NSError?) {
        log.error("error:\(error)")
        walletDelegate?.parentViewController!.dismissViewControllerAnimated(true, completion: {
            switch(status) {
            case .UserCancelled:
                return // just do nothing in this case
            case .Success:
                log.info("Backend stripe payment complete")
            case .Error:
                log.error("oh no, an error: \(error?.localizedDescription)")
            }
        })
    }
    
    // MARK: STPCheckoutViewControllerDelegate
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: ((PKPaymentAuthorizationStatus) -> Void)) {
        log.verbose("")
        STPAPIClient.sharedClient().createTokenWithPayment(payment, completion: { [weak self] (token, error) -> Void in
            log.verbose("error:\(error), token: \(token)")
            if error == nil {
                if let token = token {
                    self?.createBackendChargeWithToken(token, completion: { (result, error) -> Void in
                        log.verbose("error:\(error), result: \(result)")
                        if result == STPBackendChargeResult.Success {
                            completion(PKPaymentAuthorizationStatus.Success)
                            return
                        }
                    })
                }
            } else {
                completion(PKPaymentAuthorizationStatus.Failure)
            }
            
            })
    }


}


protocol WalletDelegate {
    func done()
}