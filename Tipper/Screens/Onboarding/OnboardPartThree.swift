//
//  OnboardPartThree.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/27/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import PassKit
import Stripe
import ApplePayStubs

class OnboardPartThree: UIViewController, PKPaymentAuthorizationViewControllerDelegate, STPCheckoutViewControllerDelegate, UINavigationControllerDelegate, StandardViewController {
    var provider: AWSCognitoCredentialsProvider!
    var currentUser: CurrentUser!
    var className = "OnboardPartThree"
    var managedObjectContext: NSManagedObjectContext?
    var market: Market!
    weak var onboardingDelegate: OnboardingViewController?
    weak var containerController: OnboardingViewController?
    let stripeCheckout = STPCheckoutViewController()
    let ApplePayMerchantID = Config.get("APPLE_PAY_MERCHANT")
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
    
    
    @IBOutlet weak var stripeButton: UIButton!
    @IBOutlet weak var applePayButton: UIButton!
    @IBOutlet weak var welcomeToTipperLabel: UILabel!
    @IBOutlet weak var tipAmountLabel: UILabel!
    @IBOutlet weak var fundAmountLabel: UILabel!
    
    @IBOutlet weak var btcConversionLabel: UILabel!
    @IBOutlet weak var ubtcExchangeLabel: UILabel!
    @IBOutlet weak var usdExchangeLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        updateBTCSpotPrice()
        updateMarketData()


        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateMarketData() {
        log.verbose("")

        if let fundAmount = Settings.sharedInstance.fundAmount, fundAmountUBTC =  Settings.sharedInstance.fundAmountUBTC {
            btcConversionLabel.text = "(\(fundAmount) Bitcoin)"
            ubtcExchangeLabel.text = fundAmountUBTC
        }

        if let amount = market.amount {
            usdExchangeLabel.text = amount
        }
    }

    func updateBTCSpotPrice() {
        log.verbose("")
        market.update { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.updateMarketData()
            })
        }
    }

    
    
    @IBAction func didTapPay(sender: UIButton) {
        log.verbose("")
        let request = PKPaymentRequest()
        request.merchantIdentifier = ApplePayMerchantID
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.Capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        let amount = (market.amount! as NSString).doubleValue
        request.paymentSummaryItems = [PKPaymentSummaryItem(label: "Tipper \(Settings.sharedInstance.fundAmount)BTC deposit", amount: NSDecimalNumber(double: amount))]
        if Stripe.canSubmitPaymentRequest(request) {
            #if DEBUG
                log.info("in debug mode")
                let applePayController = STPTestPaymentAuthorizationViewController(paymentRequest: request)
                applePayController.delegate = self
                self.presentViewController(applePayController, animated: true, completion: nil)
            #else
                let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
                applePayController.delegate = self
                self.presentViewController(applePayController, animated: true, completion: nil)
            #endif
        } else {
            launchStripeFlow()
        }
        
        
    }
    
    func launchStripeFlow() {
        //default to Stripe's PaymentKit Form
        let options = STPCheckoutOptions()
        let amount = (market.amount! as NSString).doubleValue
        options.purchaseDescription = "Tipper \(Settings.sharedInstance.fundAmount) deposit";
        options.purchaseAmount = UInt(amount * 100)
        options.companyName = "Tipper"
        let checkoutViewController = STPCheckoutViewController(options: options)
        checkoutViewController.checkoutDelegate = self
        self.presentViewController(checkoutViewController, animated: true, completion: nil)
    }
    
    
    // MARK: Stripe
    func checkoutController(controller: STPCheckoutViewController, didCreateToken token: STPToken, completion: STPTokenSubmissionHandler) {
        log.verbose("")
        createBackendChargeWithToken(token, completion: completion)
    }
    
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        log.verbose("")
        (parentViewController as! OnboardingPageControllerViewController).autoAdvance()
    }
    
    func checkoutController(controller: STPCheckoutViewController, didFinishWithStatus status: STPPaymentStatus, error: NSError?) {
        log.verbose("\(className)::\(__FUNCTION__) error:\(error)")
        self.parentViewController!.dismissViewControllerAnimated(true, completion: {
            switch(status) {
            case .UserCancelled:
                return // just do nothing in this case
            case .Success:
                log.info("great success!")
                (self.parentViewController as! OnboardingPageControllerViewController).autoAdvance()
            case .Error:
                log.error("oh no, an error: \(error?.localizedDescription)")
            }
        })
    }
    
    
    func createBackendChargeWithToken(token: STPToken, completion: STPTokenSubmissionHandler) {
        log.verbose("")
        API.sharedInstance.charge(token.tokenId, amount:self.market.amount!, completion: { [weak self] (json, error) -> Void in
            if (error != nil) {
                completion(STPBackendChargeResult.Failure, error)
            } else {
                //self?.currentUser.updateEntityWithJSON(json)
                completion(STPBackendChargeResult.Success, nil)
                (self!.parentViewController as! OnboardingPageControllerViewController).autoAdvance()
                //TSMessage.showNotificationInViewController(self?.parentViewController!, title: "Payment complete", subtitle: "Your bitcoin will arrive shortly.", type: .Success, duration: 5.0)
            }
            })
    }
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: ((PKPaymentAuthorizationStatus) -> Void)) {
        log.verbose("")
        STPAPIClient.sharedClient().createTokenWithPayment(payment, completion: { [weak self] (token, error) -> Void in
            log.info("\(self!.className)::\(__FUNCTION__) error:\(error), token: \(token)")
            if error == nil {
                if let token = token {
                    self?.createBackendChargeWithToken(token, completion: { (result, error) -> Void in
                        log.info("\(self!.className)::\(__FUNCTION__) error:\(error), result: \(result)")
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

    
    func didTapButton(sender: UIButton) {
        log.verbose("")
        didTapPay(sender)
    }
    
    
    @IBAction func didTapSkip(sender: UIButton) {
        (parentViewController as! OnboardingPageControllerViewController).autoAdvance()
    }

}
