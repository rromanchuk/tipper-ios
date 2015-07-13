//
//  TipDetailContainer.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 6/8/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import TwitterKit

class TipDetailContainer: UITableViewController {
    let className = "TipDetailContainer"
    var managedObjectContext: NSManagedObjectContext!
    var currentUser: CurrentUser!
    var favorite: Favorite!
    var tipCellType: TipCellType!
    
    @IBOutlet weak var tweetView: TWTRTweetView!

    @IBOutlet weak var tipLabel: UILabel!

    @IBOutlet weak var transactionIdLabel: UILabel!
    @IBOutlet weak var confirmationsLabel: UILabel!

    @IBOutlet weak var tipHeaderLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        println("\(className)::\(__FUNCTION__) tipCellType \(tipCellType)")
        setupTipAmount()

        let twt = TWTRTweet(JSONDictionary: favorite.twitterJSON)
        tweetView.configureWithTweet(twt)

        if tipCellType == TipCellType.Sent {
            usernameLabel.text = "@\(favorite.toTwitterUsername)"
            tipHeaderLabel.text = "You tipped \(twt.author.name)."
            if let profileImage = currentUser.profileImage, url = NSURL(string: profileImage) {
                profileImageView.hnk_setImageFromURL(url)
            }

        } else {
            tipHeaderLabel.text = "\(favorite.fromTwitterUsername) tipped you."
            usernameLabel.text = "@\(favorite.fromTwitterUsername)"
            if let urlString = favorite.fromTwitterProfileImage, url = NSURL(string: urlString) {
                profileImageView.hnk_setImageFromURL(url)
            }
        }


        if let txid = favorite.txid {
            transactionIdLabel.text = favorite.txid
        } else {
            transactionIdLabel.text = "Transaction pending..."
        }

        if let txid = favorite.txid {
            println("\(className)::\(__FUNCTION__) txid: \(txid)")
            DynamoTransaction.fetch(txid, context: managedObjectContext) { (transaction) -> Void in
                if let transaction = transaction {
                    self.confirmationsLabel.text = transaction.confirmations?.stringValue
                }
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        println("\(className)::\(__FUNCTION__)")
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    @IBAction func didTapBack(sender: UIButton) {
        println("\(className)::\(__FUNCTION__)")
        self.performSegueWithIdentifier("ExitToHome", sender: self)
    }

    @IBAction func didTapTxidLabel(sender: UITapGestureRecognizer) {
        println("\(className)::\(__FUNCTION__)")
        if let txid = favorite.txid {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://blockchain.info/tx/\(txid)")!)
        }
    }

    func setupTipAmount() {
        if let currentUser = currentUser, settings = currentUser.settings {
            let string = "a\(settings.tipAmountUBTC)"
            let labelAttributes = NSMutableAttributedString(string: string)
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "coiner", size: 18.0)!, range: NSMakeRange(0,1))
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol", size: 18.0)!, range: NSMakeRange(1, count(string) - 1))
            labelAttributes.addAttribute(NSKernAttributeName, value:-5.0, range: NSMakeRange(0, 1))
            labelAttributes.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, count(string)))
            tipLabel.attributedText = labelAttributes;
        }
    }


}
