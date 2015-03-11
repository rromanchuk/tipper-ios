//
//  PayViewController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/10/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
import PassKit
//class StripePayViewController: PTKViewDelegate {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        paymentView = PTKView(frame: CGRectMake(15, 20, 290, 55))
//        paymentView?.center = view.center
//        paymentView?.delegate = self
//        view.addSubview(paymentView!)
//
//        payButton = UIBarButtonItem(title: "pay", style: UIBarButtonItemStyle.Plain, target: self, action: "createToken")
//        payButton!.enabled = false
//        navigationItem.rightBarButtonItem = payButton
//    }
//
//
//    func paymentView(paymentView: PTKView!, withCard card: PTKCard!, isValid valid: Bool) {
//        payButton!.enabled = valid
//    }
//
//    func createToken() {
//        let card = STPCard()
//        card.number = paymentView!.card.number
//        card.expMonth = paymentView!.card.expMonth
//        card.expYear = paymentView!.card.expYear
//        card.cvc = paymentView!.card.cvc
//
//        Stripe.createTokenWithCard(card, completion: { (token: STPToken!, error: NSError!) -> Void in
//            self.handleToken(token)
//        })
//    }
//
//    func handleToken(token: STPToken!) {
//        //send token to backend and create charge
//    }
//}

class ApplePayViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {
    var currentUser: CurrentUser?
    var provider: TwitterAuth?
    var className = "ApplePayViewController"
    var managedObjectContext: NSManagedObjectContext?

    @IBOutlet weak var payButton: UIButton!
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
    let ApplePayMerchantID = Config.get("APPLE_PAY_MERCHANT")

    override func viewDidLoad() {
        super.viewDidLoad()

        //payButton!.enabled = PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks)
    }

    @IBAction func didTapPay(sender: UIButton) {
        let request = PKPaymentRequest()
        request.merchantIdentifier = ApplePayMerchantID
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.Capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.paymentSummaryItems = [PKPaymentSummaryItem(label: "CHARGE_NAME_HERE", amount: NSDecimalNumber(double: 10))]
        if Stripe.canSubmitPaymentRequest(request) {
            #if DEBUG
                let applePayController = STPTestPaymentAuthorizationViewController(paymentRequest: request)
                applePayController.delegate = self
                self.presentViewController(applePayController, animated: true, completion: nil)
                #else
                let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
                applePayController.delegate = self
                self.presentViewController(applePayController, animated: true, completion: nil)
            #endif
        } else {
            //default to Stripe's PaymentKit Form
        }

    }


    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didAuthorizePayment payment: PKPayment!, completion: ((PKPaymentAuthorizationStatus) -> Void)!) {
        println("\(className)::\(__FUNCTION__)")
        STPAPIClient.sharedClient().createTokenWithPayment(payment, completion: { (token, error) -> Void in
            println("token:\(token) error:\(error)")

            if error == nil {
                //handle token to create charge in backend
                completion(PKPaymentAuthorizationStatus.Success)
            } else {
                completion(PKPaymentAuthorizationStatus.Failure)
            }

        })

    }

    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        //dismisses ApplePay ViewController
    }


}