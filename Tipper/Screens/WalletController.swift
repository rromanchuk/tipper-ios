//
//  WalletController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 5/14/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
import PassKit
import QRCode


class WalletController: UITableViewController, PKPaymentAuthorizationViewControllerDelegate {
    var managedObjectContext: NSManagedObjectContext?
    var currentUser: CurrentUser!
    var market: Market!


    let ApplePayMerchantID = Config.get("APPLE_PAY_MERCHANT")
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
    let className = "WalletController"

    @IBOutlet weak var btcConversionLabel: UILabel!
    @IBOutlet weak var ubtcExchangeLabel: UILabel!
    @IBOutlet weak var usdExchangeLabel: UILabel!
    @IBOutlet weak var applePayButton: UIButton!

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copyToClipboardButton: UIButton!

    @IBOutlet weak var pasteAddressFromClipboard: UIButton!
    @IBOutlet weak var addressToPayTextField: UITextField!

    @IBOutlet weak var qrCode: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("\(className)::\(__FUNCTION__) currentUser: \(currentUser)")

        self.addressLabel.text = currentUser.bitcoinAddress
        qrCode.image = QRCode(currentUser.bitcoinAddress!)?.image

        if let marketValue = currentUser.marketValue, subtotalAmount = marketValue.subtotalAmount, btc = currentUser.bitcoinBalanceBTC {
            usdExchangeLabel.text = "\(market.amount!)"
        }


        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }


    @IBAction func didCopy(sender: UIButton) {
        println("\(className)::\(__FUNCTION__)")
        let pb = UIPasteboard.generalPasteboard()
        pb.string = currentUser.bitcoinAddress!
    }

    @IBAction func didPaste(sender: UIButton) {
        println("\(className)::\(__FUNCTION__)")
        if (count(addressToPayTextField.text) == 0) {
            let pb = UIPasteboard.generalPasteboard()
            if let address = pb.string {
                addressToPayTextField.text = address
                pasteAddressFromClipboard.setTitle("Send", forState: .Normal)
                pasteAddressFromClipboard.backgroundColor = UIColor.colorWithRGB(0x69C397, alpha: 1.0)
            }
        } else {
            currentUser.withdrawBalance(addressToPayTextField.text, completion: { (error) -> Void in
                if error != nil {
                    let alertController = UIAlertController(title: "There was a problem", message: "Please try again later", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.parentViewController!.presentViewController(alertController, animated: true) {
                        // ...
                    }
                } else {
                    let alertController = UIAlertController(title: "Success", message: "Withdraw in progress. Please wait a few moments for you balances to be updated", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.self.parentViewController!.presentViewController(alertController, animated: true) {
                        // ...
                    }

                }
            })
        }


    }

    @IBAction func didTapPay(sender: UIButton) {
        let request = PKPaymentRequest()
        request.merchantIdentifier = ApplePayMerchantID
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.Capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        let amount = (market.amount! as NSString).doubleValue
        request.paymentSummaryItems = [PKPaymentSummaryItem(label: "Тipper ", amount: NSDecimalNumber(double: amount))]
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

    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        //dismisses ApplePay ViewController
    }
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didAuthorizePayment payment: PKPayment!, completion: ((PKPaymentAuthorizationStatus) -> Void)!) {
        println("\(className)::\(__FUNCTION__)")
        STPAPIClient.sharedClient().createTokenWithPayment(payment, completion: { (token, error) -> Void in
            println("token:\(token) error:\(error)")

            if error == nil {
                //handle token to create charge in backend
                API.sharedInstance.charge(token.tokenId, amount:self.market.amount!, completion: { (json, error) -> Void in
                    completion(PKPaymentAuthorizationStatus.Success)
                })
            } else {
                completion(PKPaymentAuthorizationStatus.Failure)
            }
        })

    }

}