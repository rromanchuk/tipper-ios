//
//  HomeController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/25/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import TwitterKit

class HomeController: UIViewController {
    var managedObjectContext: NSManagedObjectContext!
    var currentUser: CurrentUser!
    var market: Market!
    let tweetTableReuseIdentifier = "TweetCell"


    var className = "HomeController"

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!

    let ApplePayMerchantID = Config.get("APPLE_PAY_MERCHANT")
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]

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
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            println("\(self.className)::\(__FUNCTION__) cancelAction")
        }
        _actionController.addAction(cancelAction)

        let destroyAction = UIAlertAction(title: "Logout", style: .Destructive) { (action) in
            println("\(self.className)::\(__FUNCTION__) destroyAction")
            self.currentUser.resetIdentifiers()
            self.performSegueWithIdentifier("BackToSplash", sender: self)
        }
        _actionController.addAction(destroyAction)
        return _actionController
    }()



    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension // Explicitly set on iOS 8 if using automatic row height calculation
        tableView.layer.cornerRadius = 2.0
        tableView.contentInset = UIEdgeInsetsMake(29, 0, 0, 0)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive:", name: UIApplicationWillResignActiveNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: UIApplication.sharedApplication())

        updateMarkets()
        DynamoFavorite.fetchFromAWS(currentUser, context: managedObjectContext)
        DynamoFavorite.fetchReceivedFromAWS(currentUser, context: managedObjectContext)


    }

    func refreshUI() {
        Debug.isBlocking()
        if let marketValue = currentUser.marketValue, subtotalAmount = marketValue.subtotalAmount, btc = currentUser.bitcoinBalanceBTC {
            balanceLabel.text = "Ƀ\(btc)"
        }

        if let marketValue = market.amount {
            //addFundsLabel.text = "ADD FUNDS (Ƀ0.02 for $\(marketValue))"
        }

    }

    func updateMarkets() {
        market.update { () -> Void in
            self.refreshUI()
        }
        currentUser.updateBalanceUSD { () -> Void in
            self.refreshUI()
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func didTapSettings(sender: UIButton) {
        self.presentViewController(actionSheet, animated: true) {
            // ...
        }
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
        API.sharedInstance.me({ (json, error) -> Void in
            if (error == nil) {
                self.currentUser.updateEntityWithJSON(json)
                self.currentUser.writeToDisk()
                self.updateMarkets()
                self.refreshUI()
            } else if let error = error where error.code == 401 {
                self.currentUser.resetIdentifiers()
                self.performSegueWithIdentifier("BackToSplash", sender: self)
            }
        })
        
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

        if segmentControl.selectedSegmentIndex == 0 {
            cell.tipConfirmedButton.hidden = !favorite.didLeaveTip
            cell.tipButton.hidden = favorite.didLeaveTip
        } else {
            cell.tipConfirmedButton.hidden = true
            cell.tipButton.hidden = true
        }


        //cell.tweetView.delegate = self
        //cell.configureWithTweet(twt)

        return cell
    }


    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects!
    }


}

