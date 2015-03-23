//
//  PayViewController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/10/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
import PassKit
import TwitterKit
import QRCode

class ApplePayViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    var className = "ApplePayViewController"

    var managedObjectContext: NSManagedObjectContext {
        get {
            return (tabBarController as! TipperTabBarController).managedObjectContext!
        }
    }

    var currentUser: CurrentUser {
        get {
            return (tabBarController as! TipperTabBarController).currentUser!
        }
    }

    var market: Market {
        get {
            return (tabBarController as! TipperTabBarController).market!
        }
    }

    @IBOutlet weak var welcomeLabel: UILabel!

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var qrImage: UIImageView!

    @IBOutlet weak var payButton: UIButton!

    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
    let ApplePayMerchantID = Config.get("APPLE_PAY_MERCHANT")

    override func viewDidLoad() {
        super.viewDidLoad()
        println("\(className)::\(__FUNCTION__) \(managedObjectContext)")

        //payButton!.enabled = PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks)


        //let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL: "https://userstream.twitter.com/1.1/user.json", parameters: ["with": "favorite"], error: nil)

        //let connection = NSURLConnection(request: request, delegate: self)
        //connection?.start()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive:", name: UIApplicationWillResignActiveNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: UIApplication.sharedApplication())

        API.sharedInstance.market { (json, error) -> Void in
            Debug.isBlocking()
            self.market.amount = json["amount"].stringValue
            self.market.updatedAt = NSDate()
            self.refreshUI()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshUI()

    }

    func refreshUI() {
        var marketString: String = ""
        if let amount = market.amount {
            marketString = "You can buy 0.002BTC for $\(amount)."
        }
        welcomeLabel.text = "Hi, @\(currentUser.twitterUsername)! You currently have \(currentUser.bitcoinBalanceBTC)BTC in your account. \(marketString)"
        
        self.addressLabel.text = currentUser.bitcoinAddress
        let qrCode = QRCode(currentUser.bitcoinAddress!)
        qrImage.image = qrCode?.image
    }

    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        let response: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        println(response)
    }

    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        //println(
    }


    @IBAction func didTapPay(sender: UIButton) {
        let request = PKPaymentRequest()
        request.merchantIdentifier = ApplePayMerchantID
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.Capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.paymentSummaryItems = [PKPaymentSummaryItem(label: "Тipper ", amount: NSDecimalNumber(double: 10))]
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
                API.sharedInstance.charge(token.tokenId, bitcoinAddress:self.currentUser.bitcoinAddress!, completion: { (json, error) -> Void in
                    completion(PKPaymentAuthorizationStatus.Success)
               })
            } else {
                completion(PKPaymentAuthorizationStatus.Failure)
            }

        })

    }

    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        //dismisses ApplePay ViewController
    }

    // MARK: Application lifecycle

    func applicationWillResignActive(aNotification: NSNotification) {
        println("\(className)::\(__FUNCTION__)")
    }

    func applicationDidEnterBackground(aNotification: NSNotification) {
        println("\(className)::\(__FUNCTION__)")

    }

    func applicationDidBecomeActive(aNotification: NSNotification) {
        println("\(className)::\(__FUNCTION__)")
        refreshUI()
    }



}