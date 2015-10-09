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

    private var isLoaded = false
    private var transactionRefreshedFromServer = false

    lazy var transaction: Transaction? = {
        return Transaction.entityWithId(Transaction.self, context: self.managedObjectContext, lookupProperty: "txid", lookupValue: self.favorite.txid!)
    }()

    @IBOutlet weak var tweetView: TWTRTweetView!

    @IBOutlet weak var tipLabel: UILabel!

    @IBOutlet weak var transactionIdLabel: UILabel!
    @IBOutlet weak var confirmationsLabel: UILabel!

    @IBOutlet weak var tipHeaderLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        log.verbose("")
        setupTipAmount()
        loadTweet()
        loadTransactionData()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !isLoaded {
            SwiftSpinner.show("Loading tip...")
        }
    }

    func setupTweetInfo(twt: TWTRTweet) {
        Debug.isBlocking()
        if favorite.fromTwitterId == currentUser.twitterUserId {
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

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        log.verbose("")
        // Dispose of any resources that can be recreated.
    }


    func loadTransactionData() {
        if let transaction = self.transaction {
            self.confirmationsLabel.text = transaction.confirmations?.stringValue
        }

        if !transactionRefreshedFromServer {
            transactionRefreshedFromServer = true
            refreshTransactionData()
        }

    }

    func refreshTransactionData() {
        if let txid = self.favorite.txid {
            Transaction.get(txid, context: managedObjectContext, callback: { (transaction) -> Void in
                if let transaction = transaction {
                    self.transaction = transaction
                    self.loadTransactionData()
                }
            })
        }
    }

    func loadTweet() {
        let client = TWTRAPIClient()
        client.loadTweetWithID(favorite.tweetId) { tweet, error in
            SwiftSpinner.hide()
            if let t = tweet {
                self.tweetView.configureWithTweet(t)
                self.setupTweetInfo(t)

            } else if let error = error {
                log.error("Failed to load Tweet: \(error.localizedDescription)")
            }
        }

    }

    // MARK: - Table view data source

    @IBAction func didTapBack(sender: UIButton) {
        log.verbose("")
        self.parentViewController?.performSegueWithIdentifier("UnwindFromTipDetail", sender: self)
    }

    @IBAction func didTapTxidLabel(sender: UITapGestureRecognizer) {
        log.verbose("")
        if let txid = favorite.txid {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://blockchain.info/tx/\(txid)")!)
        }
    }

    func setupTipAmount() {
        if let currentUser = currentUser {
            let string = "a\(Settings.sharedInstance.tipAmountUBTC!)"
            let labelAttributes = NSMutableAttributedString(string: string)
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "coiner", size: 18.0)!, range: NSMakeRange(0,1))
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol", size: 18.0)!, range: NSMakeRange(1, string.characters.count - 1))
            labelAttributes.addAttribute(NSKernAttributeName, value:-5.0, range: NSMakeRange(0, 1))
            labelAttributes.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, string.characters.count))
            tipLabel.attributedText = labelAttributes;
        }
    }


}
