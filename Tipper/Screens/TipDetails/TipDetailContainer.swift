//
//  TipDetailContainer.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 6/8/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import TwitterKit
import MapKit
class TipDetailContainer: UITableViewController, TWTRTweetViewDelegate {
    let className = "TipDetailContainer"
    var managedObjectContext: NSManagedObjectContext!
    var currentUser: CurrentUser!
    var favorite: Favorite?
    var notification: Notification?
    
    private var isLoaded = false
    private var transactionRefreshedFromServer = false
    private var tweet: TWTRTweet?

    lazy var transaction: Transaction? = {
        return Transaction.entityWithId(Transaction.self, context: self.managedObjectContext, lookupProperty: "txid", lookupValue: self.favorite!.txid!)
    }()

    @IBOutlet weak var tweetView: TWTRTweetView!

    @IBOutlet weak var tipBTCLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!

    @IBOutlet weak var transactionIdLabel: UILabel!
    @IBOutlet weak var confirmationsLabel: UILabel!

    @IBOutlet weak var tipHeaderLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var blockchainContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 290
        tweetView.delegate = self
        

        log.verbose("")
        if let notification = notification {
            loadFavoriteFromNotification(notification, callback: { () -> Void in
                self.setup()
            })
        } else if let _ = favorite {
            setup()
        }

        blockchainContainer.layer.cornerRadius = 5
        blockchainContainer.layer.masksToBounds = true
    }
    
    func setup() {
        log.verbose("")
        SwiftSpinner.show("Loading tip...")
        setupTipAmount()
        if let _favorite = favorite {
            loadTweet(_favorite, callback: { () -> Void in
                self.loadTransactionData()
                SwiftSpinner.hide()
            })
        }
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        SwiftSpinner.hide()
    }

    func setupTweetInfo(twt: TWTRTweet, favorite: Favorite) {
        if favorite.fromTwitterId == currentUser.twitterUserId {
            usernameLabel.text = "@\(favorite.toTwitterUsername)"
            tipHeaderLabel.text = "You tipped \(twt.author.name)."
            log.info("Loading image \(currentUser.profileImage)")
            if let urlString = currentUser.profileImage, url = NSURL(string: urlString) {
                //profileImageView.hnk_setImageFromURL(url)
                profileImageView.hnk_setImageFromURL(url, placeholder: nil, format: nil, failure: { (error) -> () in
                    log.error("[ERROR] Could not load image \(urlString) \(error)")
                    self.profileImageView.image = UIImage(named: "default-profile")
                    }, success: { (image) -> () in
                        log.info("Loading image \(urlString)")
                        self.profileImageView.image = image
                })

            }

        } else {
            tipHeaderLabel.text = "\(favorite.fromTwitterUsername) tipped you."
            usernameLabel.text = "@\(favorite.fromTwitterUsername)"
            log.info("Loading image \(favorite.fromTwitterProfileImage)")
            if let urlString = favorite.fromTwitterProfileImage, url = NSURL(string: urlString) {
                //profileImageView.hnk_setImageFromURL(url)
                profileImageView.hnk_setImageFromURL(url, placeholder: nil, format: nil, failure: { (error) -> () in
                    log.error("[ERROR] Could not load image \(urlString) \(error)")
                    self.profileImageView.image = UIImage(named: "default-profile")
                    }, success: { (image) -> () in
                        
                        self.profileImageView.image = image
                })
            }
        }

    }

    func loadTransactionData() {
        if let transaction = self.transaction {
            self.confirmationsLabel.text = "\(transaction.confirmations!) Confirmations"
            let cord = CLLocationCoordinate2D(latitude: 37.7833, longitude: -122.4167)
            self.mapView.setCenterCoordinate(cord, animated: true)
//            if let relayedBy = transaction.relayedBy {
//                //self.fetchLocation(relayedBy)
//                
//            }
            
        }

        if !transactionRefreshedFromServer {
            transactionRefreshedFromServer = true
            refreshTransactionData()
        }

    }

    func refreshTransactionData() {
        if let txid = self.favorite?.txid {
            Transaction.get(txid, context: managedObjectContext, callback: { (transaction) -> Void in
                if let transaction = transaction {
                    self.transaction = transaction
                    self.loadTransactionData()
                }
            })
        }
    }

    func loadTweet(favorite: Favorite, callback: () -> Void) {
        let client = TWTRAPIClient()
        client.loadTweetWithID(favorite.tweetId) { tweet, error in
            
            if let t = tweet {
                self.tweet = t
                self.tweetView.configureWithTweet(t)
                self.setupTweetInfo(t, favorite: favorite)

            } else if let error = error {
                log.error("Failed to load Tweet: \(error.localizedDescription)")
            }
            callback()
        }

    }
    
    func loadFavoriteFromNotification(notification: Notification, callback: ()->Void) {
        if let favorite = Favorite.fetchFromCoreData(notification.tipId!, fromUserId: notification.tipFromUserId!, context: managedObjectContext) {
            self.favorite = favorite
            callback()
        } else {
            Favorite.fetchFromDynamo(notification.tipFromUserId!, tipId: notification.tipId!, context: managedObjectContext, callback: { (favorite) -> Void in
                if let favorite = favorite  {
                    self.favorite = favorite
                }
                callback()
            })
        }
    }
    
    func fetchLocation(ipAddress: String) {
//        TIPPERTipperClient.defaultClient().locationGet(ipAddress).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
//            if let location = task.result as? TIPPERLocation {
//                let cord = CLLocationCoordinate2D(latitude: location.lat.doubleValue, longitude: location.lng.doubleValue)
//                self.mapView.setCenterCoordinate(cord, animated: true)
//            }
//            return nil
//        })
    }
    
    // MARK: - Table view data source

    @IBAction func didTapBack(sender: UIButton) {
        log.verbose("")
        if notification == nil {
            self.parentViewController?.performSegueWithIdentifier("UnwindFromTipDetail", sender: self)
        } else {
            self.parentViewController?.performSegueWithIdentifier("ExitToNotificationsFromTipDetails", sender: self)
        }
        
    }

    @IBAction func didTapTxidLabel(sender: UITapGestureRecognizer) {
        log.verbose("")

    }

    func setupTipAmount() {
        if let _ = currentUser {
            let string = "a\(Settings.sharedInstance.tipAmountUBTC!)"
            let labelAttributes = NSMutableAttributedString(string: string)
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "coiner", size: 18.0)!, range: NSMakeRange(0,1))
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol", size: 18.0)!, range: NSMakeRange(1, string.characters.count - 1))
            labelAttributes.addAttribute(NSKernAttributeName, value:-5.0, range: NSMakeRange(0, 1))
            labelAttributes.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, string.characters.count))
            tipLabel.attributedText = labelAttributes;
            
            if let tipAmount = Settings.sharedInstance.tipAmount {
                tipBTCLabel.text = tipAmount
            }
            
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        if indexPath.row == 0 {
            return 70
        } else if indexPath.row == 2 {
            return 290
        } else {
            return UITableViewAutomaticDimension
        }

    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        log.verbose("tweet: \(tweet), userId:\(tweet?.author.userID)")
        if let tweetId = favorite?.tweetId where indexPath.row == 1 {
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: "twitter://")!) {
                UIApplication.sharedApplication().openURL(NSURL(string: "twitter://status?id=\(tweetId)")!)
            } else if let tweet = tweet {
                UIApplication.sharedApplication().openURL(tweet.permalink)
            }
        } else if indexPath.row == 2 {
            if let txid = favorite?.txid {
                UIApplication.sharedApplication().openURL(NSURL(string: "https://blockchain.info/tx/\(txid)")!)
            }
        }
    }


    // PRAGMA MARK: TWTRTweetViewDelegate methods

    func tweetView(tweetView: TWTRTweetView, didSelectTweet tweet: TWTRTweet) {
        tableView(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
    }

}
