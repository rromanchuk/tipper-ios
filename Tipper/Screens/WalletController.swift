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
import SwiftyJSON
import Stripe
import Haneke
import TSMessages
import ApplePayStubs

class WalletController: UITableViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    var managedObjectContext: NSManagedObjectContext?
    var currentUser: CurrentUser!
    var market: Market!

    let regularExpression = try! NSRegularExpression(pattern: "^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$", options: [])

    lazy var paymentController : PaymentController = {
        PaymentController(withMarket: self.market)
    }()

    @IBOutlet weak var btcConversionLabel: UILabel!
    @IBOutlet weak var ubtcExchangeLabel: UILabel!
    @IBOutlet weak var usdExchangeLabel: UILabel!
    @IBOutlet weak var applePayButton: PKPaymentButton!

    @IBOutlet weak var stripeButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copyToClipboardButton: UIButton!

    @IBOutlet weak var pasteAddressFromClipboard: UIButton!
    @IBOutlet weak var addressToPayTextField: UITextField!

    @IBOutlet weak var qrCode: UIImageView!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var twitterUsername: UILabel!

    @IBOutlet weak var autotipSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 1300;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        //applePayButton = PKPaymentButton(type: .Buy, style: .Black)
        paymentController.walletDelegate = self

        if let fundAmount = Settings.sharedInstance.fundAmount, fundAmountUBTC = Settings.sharedInstance.fundAmountUBTC {
            btcConversionLabel.text = "(\(fundAmount) Bitcoin)"
            ubtcExchangeLabel.text = fundAmountUBTC
        }
        
        self.addressLabel.text = currentUser.bitcoinAddress
        qrCode.image = QRCode(currentUser.bitcoinAddress!)?.image


        if let amount = market.amount {
            usdExchangeLabel.text = amount
        }

        if paymentController.applePaySupported {
            log.verbose("ApplePay supported")
            self.applePayButton.hidden = false
            self.stripeButton.hidden = true
        } else {
            log.verbose("ApplePay not supported")
            self.applePayButton.hidden = true
            self.stripeButton.hidden = false
        }

        if let profileImageUrl = currentUser.profileImage, url = NSURL(string: profileImageUrl) {
            profileImage.hnk_setImageFromURL(url)
        }
        
        if let automaticTipping = currentUser.automaticTippingEnabled {
            autotipSwitch.on = automaticTipping.boolValue
        }
        //
        twitterUsername.text = currentUser.twitterUsername

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }

    func addressValid() -> Bool {
        let textRange = NSMakeRange(0, addressToPayTextField.text!.characters.count);
        let matchRange = regularExpression.rangeOfFirstMatchInString(addressToPayTextField.text!, options: .ReportProgress, range: textRange)
        if matchRange.location != NSNotFound {
            return true
        }
        return false
    }

    @IBAction func didCopy(sender: UIButton) {
        log.verbose("")
        let pb = UIPasteboard.generalPasteboard()
        pb.string = currentUser.bitcoinAddress!
    }

    @IBAction func didPaste(sender: UIButton) {
        log.verbose("")
        if (addressToPayTextField.text?.characters.count == 0) {
            let pb = UIPasteboard.generalPasteboard()
            if let address = pb.string {
                addressToPayTextField.text = address
                pasteAddressFromClipboard.setTitle("Send", forState: .Normal)
                pasteAddressFromClipboard.backgroundColor = UIColor.colorWithRGB(0x69C397, alpha: 1.0)
            }
        } else if !addressValid() {
            let alertController = UIAlertController(title: "Not a valid Bitcoin address.", message: nil, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(OKAction)
            self.parentViewController!.presentViewController(alertController, animated: true, completion: nil)
        } else {
            currentUser.withdrawBalance(addressToPayTextField.text!, completion: { [weak self] (error) -> Void in
                if error != nil {
                    let alertController = UIAlertController(title: "There was a problem", message: "Please try again later", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default, handler:nil)
                    alertController.addAction(OKAction)
                    self?.parentViewController!.presentViewController(alertController, animated: true,  completion:nil)
                } else {
                    let alertController = UIAlertController(title: "Success", message: "Withdraw in progress. Please wait a few moments for you balances to be updated", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default, handler:nil)
                    alertController.addAction(OKAction)
                    self?.parentViewController!.presentViewController(alertController, animated: true, completion:nil)
                }
            })
        }


    }

    func checkoutController(controller: STPCheckoutViewController, didFinishWithStatus status: STPPaymentStatus, error: NSError?) {
        log.error("error:\(error)")
        self.parentViewController!.dismissViewControllerAnimated(true, completion: {
            switch(status) {
            case .UserCancelled:
                return // just do nothing in this case
            case .Success:
                log.verbose("great success!")
            case .Error:
                log.error("oh no, an error: \(error?.localizedDescription)")
            }
        })
    }

    @IBAction func didToggleAutomaticTipping(sender: UISwitch) {
        log.verbose("autotipSwitch:\(autotipSwitch.on), currentUser.automaticTippingEnabled:\(currentUser.automaticTippingEnabled)")
        SwiftSpinner.show("Saving..")
        if autotipSwitch.on {
            currentUser.turnOnAutoTipping({ (error) -> Void in
                SwiftSpinner.hide()
            })
        } else {
            currentUser.turnOffAutoTipping({ (error) -> Void in
                SwiftSpinner.hide()
            })
        }
    }
    
    @IBAction func didLongPressPayButton(sender: UILongPressGestureRecognizer) {
        log.info("\(currentUser.admin)")
        if let admin = currentUser.admin where admin.boolValue {
            //launchStripeFlow()
        }
    }

    @IBAction func didTapLogout(sender: UIButton) {
        log.verbose("")
        currentUser.resetIdentifiers()
        performSegueWithIdentifier("BackToSplashFromAccount", sender: self)
    }

    @IBAction func didTapPay(sender: UIButton) {
        log.verbose("")
        paymentController.pay()
    }
    

    @IBAction func textFieldChanged(sender: UITextField) {
        if (addressToPayTextField.text!.characters.count > 24) {
            pasteAddressFromClipboard.setTitle("Send", forState: .Normal)
            pasteAddressFromClipboard.backgroundColor = UIColor.colorWithRGB(0x69C397, alpha: 1.0)

        } else {
            pasteAddressFromClipboard.setTitle("Paste from Clipboard", forState: .Normal)
            pasteAddressFromClipboard.backgroundColor = UIColor.colorWithRGB(0xD7D7D7, alpha: 1.0)
        }


    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}