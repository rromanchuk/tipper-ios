//
//  HomeController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/25/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import TwitterKit
import MessageUI
import SwiftyJSON

class HomeController: UIViewController, MFMailComposeViewControllerDelegate, NotificationMessagesDelegate {
    var managedObjectContext: NSManagedObjectContext!
    var currentUser: CurrentUser!
    var market: Market!
    var showBalanceBTC = false
    let tweetTableReuseIdentifier = "TweetCell"


    var className = "HomeController"

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!

    lazy var fetchedResultsController: NSFetchedResultsController = NSFetchedResultsController.superFetchedResultsController("Favorite", sectionNameKeyPath: nil, sortDescriptors: self.sortDescriptors, predicate: self.predicate, tableView: self.tableView, context: self.managedObjectContext)

    lazy var predicate: NSPredicate? = {
        return NSPredicate(format: "fromTwitterId = %@", self.currentUser.uuid!)
    }()

    lazy var receivedPredicate: NSPredicate? = {
        return NSPredicate(format: "toTwitterId = %@", self.currentUser.uuid!)
    }()

    lazy var sortDescriptors: [AnyObject] = {
        return [NSSortDescriptor(key: "createdAt", ascending: false)]
    }()

    lazy var fetchRequest: NSFetchRequest = {
        let request = NSFetchRequest(entityName: "Favorite")
        request.predicate = self.predicate
        request.sortDescriptors = self.sortDescriptors
        return request
    }()

    lazy var actionSheet: UIAlertController = {
        let _actionController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        if let popoverController = _actionController.popoverPresentationController {
            popoverController.sourceView = self.settingsButton
            popoverController.sourceRect = self.settingsButton.bounds
        }



        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { [weak self] (action) in
            println("\(self?.className)::\(__FUNCTION__) cancelAction")
        }
        _actionController.addAction(cancelAction)

        let destroyAction = UIAlertAction(title: "Logout", style: .Destructive) { [weak self] (action) in
            println("\(self?.className)::\(__FUNCTION__) destroyAction")
            self?.currentUser.resetIdentifiers()
            self?.performSegueWithIdentifier("BackToSplash", sender: self)
        }

        let feedbackAction = UIAlertAction(title: "Feedback and Support", style: .Default, handler: { [weak self] (action) -> Void in
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject("Feedback and Support")
            mailComposer.setToRecipients(["support@coinbit.tips"])
            self?.presentViewController(mailComposer, animated:true, completion: nil)
        })
        _actionController.addAction(feedbackAction)
        _actionController.addAction(destroyAction)
        return _actionController
    }()

    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismissViewControllerAnimated(true, completion:nil)
    }

    func logout() {
        currentUser.resetIdentifiers()
        performSegueWithIdentifier("BackToSplash", sender: self)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension // Explicitly set on iOS 8 if using automatic row height calculation
        tableView.layer.cornerRadius = 2.0

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive:", name: UIApplicationWillResignActiveNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: UIApplication.sharedApplication())


        updateMarkets()
        DynamoFavorite.fetchFromAWS(currentUser, context: managedObjectContext)
        DynamoFavorite.fetchReceivedFromAWS(currentUser, context: managedObjectContext)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "UNAUTHORIZED_USER", object: nil)

    }

    func setBalance() {
        let string = "a\(currentUser.balanceAsUBTC)"
        let labelAttributes = NSMutableAttributedString(string: string)
        labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "coiner", size: 40.0)!, range: NSMakeRange(0,1))
        labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol-Regular", size: 40.0)!, range: NSMakeRange(1, count(string) - 1))
        labelAttributes.addAttribute(NSKernAttributeName, value:-5.0, range: NSMakeRange(0, 1))

        balanceLabel.attributedText = labelAttributes

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        (UIApplication.sharedApplication().delegate as! AppDelegate).notificationsDelegate = self
        refreshUI()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func refreshUI() {
        println("\(className)::\(__FUNCTION__)")
        Debug.isBlocking()

        managedObjectContext.refreshObject(currentUser, mergeChanges: true)
        setBalance()
    }

    func updateMarkets() {
        println("\(className)::\(__FUNCTION__)")
        market.update { [weak self] () -> Void in
            self?.refreshUI()
        }
        currentUser.updateBalanceUSD { [weak self] () -> Void in
            self?.refreshUI()
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func didTapSettings(sender: UIButton) {
        println("\(className)::\(__FUNCTION__)")
        self.presentViewController(actionSheet, animated: true) {
            // ...
        }
    }

    @IBAction func didTapBalance(sender: UITapGestureRecognizer) {
        println("\(className)::\(__FUNCTION__)")

    }

    @IBAction func segmentChanged(sender: UISegmentedControl) {
        println("\(className)::\(__FUNCTION__) selected:\(sender.selectedSegmentIndex)")
        if sender.selectedSegmentIndex == 0 {
            fetchedResultsController.fetchRequest.predicate = predicate
            fetchedResultsController.performFetch(nil)
            tableView.reloadData()
        } else {
            fetchedResultsController.fetchRequest.predicate = receivedPredicate
            fetchedResultsController.performFetch(nil)
            tableView.reloadData()
        }
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
        updateMarkets()
        currentUser.refreshWithServer { [weak self] (error) -> Void in
            if (error == nil) {
                self?.updateMarkets()
                self?.refreshUI()
            } else if let error = error where error.code == 401 {
                self?.currentUser.resetIdentifiers()
                self?.performSegueWithIdentifier("BackToSplash", sender: self)
            }
        }
    }

    func didReceiveNotificationAlert(message: String, subtitle: String, type: TSMessageNotificationType) {
        println("\(className)::\(__FUNCTION__)")
        TSMessage.showNotificationInViewController(self, title: message, subtitle: subtitle, type: type, duration: 5.0)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("\(className)::\(__FUNCTION__)")

        if segue.identifier == "Wallet" {
            let vc = segue.destinationViewController as! WalletContainerController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
        }
    }

    @IBAction func done(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("\(className)::\(__FUNCTION__)")
    }


    // MARK: UICollectionViewDataSource

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let favorite = fetchedResultsController.objectAtIndexPath(indexPath) as! Favorite
        let twt = TWTRTweet(JSONDictionary: favorite.twitterJSON)

        let cell = tableView.dequeueReusableCellWithIdentifier(tweetTableReuseIdentifier, forIndexPath: indexPath) as! TweetCell
        cell.currentUser = currentUser
        cell.favorite = favorite
        cell.tweetView.configureWithTweet(twt)

        //println("\(className)::\(__FUNCTION__) didLeaveTip: \(favorite.didLeaveTip)")
        if favorite.didLeaveTip {
            cell.tipButton.backgroundColor = UIColor.grayColor()
            cell.tipButton.enabled = false
        } else {
            cell.tipButton.backgroundColor = UIColor.colorWithRGB(0x69C397, alpha: 1.0)
            cell.tipButton.enabled = true
        }

        cell.setupTipButton()

        return cell
    }


    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects!
    }


}

