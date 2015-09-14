//
//  OnboardFundingViewController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/8/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import PassKit
import Stripe


class OnboardFundingViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate, STPCheckoutViewControllerDelegate, UINavigationControllerDelegate {
    var managedObjectContext: NSManagedObjectContext!
    var currentUser: CurrentUser!
    var market: Market!
    
    let stripeCheckout = STPCheckoutViewController()
    let ApplePayMerchantID = Config.get("APPLE_PAY_MERCHANT")
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
    let className = "OnboardFundingViewController"


    @IBOutlet weak var stripeButton: UIButton!
    @IBOutlet weak var applePayButton: UIButton!
    @IBOutlet weak var welcomeToTipperLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMarkets()
        let paymentRequest = Stripe.paymentRequestWithMerchantIdentifier(ApplePayMerchantID)
        
        if PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks) && Stripe.canSubmitPaymentRequest(paymentRequest) {
            print("ApplePay supported", terminator: "")
            self.applePayButton.hidden = false
            self.stripeButton.hidden = true
        } else {
            print("ApplePay not supported", terminator: "")
            self.applePayButton.hidden = true
            self.stripeButton.hidden = false
        }


        // Do any additional setup after loading the view.
        setAttributedLabels()
    }

    func setAttributedLabels() {
        let prefix = "Welcome to "
        let bold = "Tipper"
        let postfix = "!"
        
        let string = "\(prefix)\(bold)\(postfix)"
        let labelAttributes = NSMutableAttributedString(string: string)
        labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol-Regular", size: 33.0)!, range: NSMakeRange(0,prefix.characters.count))
        labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol-Bold", size: 33.0)!, range: NSMakeRange(prefix.characters.count, bold.characters.count))
        labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol-Regular", size: 33.0)!, range: NSMakeRange(prefix.characters.count + bold.characters.count,postfix.characters.count))
        welcomeToTipperLabel.attributedText = labelAttributes
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateMarkets() {
        //println("\(className)::\(__FUNCTION__)")
        market.update { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
            })
        }
        currentUser.updateBalanceUSD { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
            })
        }
    }
    
    @IBAction func didLongPressPay(sender: UILongPressGestureRecognizer) {
        if let admin = currentUser.admin where admin.boolValue {
            launchStripeFlow()
        }
    }

    @IBAction func didTapPay(sender: UIButton) {
        print("\(className)::\(__FUNCTION__) market: \(market)", terminator: "")
        let request = PKPaymentRequest()
        request.merchantIdentifier = ApplePayMerchantID
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.Capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        let amount = (market.amount! as NSString).doubleValue
        request.paymentSummaryItems = [PKPaymentSummaryItem(label: "Tipper 0.02BTC deposit", amount: NSDecimalNumber(double: amount))]
        if Stripe.canSubmitPaymentRequest(request) {
            #if DEBUG
                print("in debug mode", terminator: "")
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
        options.purchaseDescription = "Tipper 0.02BTC deposit";
        options.purchaseAmount = UInt(amount * 100)
        options.companyName = "Tipper"
        let checkoutViewController = STPCheckoutViewController(options: options)
        checkoutViewController.checkoutDelegate = self
        self.presentViewController(checkoutViewController, animated: true, completion: nil)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "" {
            
        }
    }
    
    
    // MARK: Stripe
    func checkoutController(controller: STPCheckoutViewController, didCreateToken token: STPToken, completion: STPTokenSubmissionHandler) {
        print("\(className)::\(__FUNCTION__)", terminator: "")
        createBackendChargeWithToken(token, completion: completion)
    }
    
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        print("\(className)::\(__FUNCTION__)", terminator: "")
        self.parentViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkoutController(controller: STPCheckoutViewController, didFinishWithStatus status: STPPaymentStatus, error: NSError?) {
        print("\(className)::\(__FUNCTION__) error:\(error)", terminator: "")
        self.parentViewController!.dismissViewControllerAnimated(true, completion: {
            switch(status) {
            case .UserCancelled:
                return // just do nothing in this case
            case .Success:
                print("great success!", terminator: "")
            case .Error:
                print("oh no, an error: \(error?.localizedDescription)", terminator: "")
            }
        })
    }
    
    
    func createBackendChargeWithToken(token: STPToken, completion: STPTokenSubmissionHandler) {
        print("\(className)::\(__FUNCTION__)", terminator: "")
        API.sharedInstance.charge(token.tokenId, amount:self.market.amount!, completion: { [weak self] (json, error) -> Void in
            if (error != nil) {
                completion(STPBackendChargeResult.Failure, error)
            } else {
                //self?.currentUser.updateEntityWithJSON(json)
                completion(STPBackendChargeResult.Success, nil)
                self?.performSegueWithIdentifier("OnboardStepTwo", sender: self)
                TSMessage.showNotificationInViewController(self?.parentViewController!, title: "Payment complete", subtitle: "Your bitcoin will arrive shortly.", type: .Success, duration: 5.0)
            }
            })
    }
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: ((PKPaymentAuthorizationStatus) -> Void)) {
        print("\(className)::\(__FUNCTION__)", terminator: "")
        STPAPIClient.sharedClient().createTokenWithPayment(payment, completion: { [weak self] (token, error) -> Void in
            print("\(self!.className)::\(__FUNCTION__) error:\(error), token: \(token)", terminator: "")
            if error == nil {
                if let token = token {
                    self?.createBackendChargeWithToken(token, completion: { (result, error) -> Void in
                        print("\(self!.className)::\(__FUNCTION__) error:\(error), result: \(result)", terminator: "")
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
