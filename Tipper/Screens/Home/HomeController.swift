//
//  HomeController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/25/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import PassKit
import TwitterKit

class HomeController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {
    var managedObjectContext: NSManagedObjectContext!
    var currentUser: CurrentUser!
    var market: Market!
    let tweetTableReuseIdentifier = "TweetCell"


    var className = "HomeController"

    @IBOutlet weak var addFundsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var applePayButton: UIButton!
    @IBOutlet weak var withdrawButton: UIButton!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!

    let ApplePayMerchantID = Config.get("APPLE_PAY_MERCHANT")
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]

    lazy var fetchedResultsController: NSFetchedResultsController = NSFetchedResultsController.superFetchedResultsController("Favorite", sectionNameKeyPath: nil, sortDescriptors: self.sortDescriptors, predicate: self.predicate, tableView: self.tableView, context: self.managedObjectContext)

    lazy var predicate: NSPredicate? = {
        let now = NSDate()
        let hourAgo = now.dateByAddingTimeInterval(-(60 * 60) * 24)
        return nil
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


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension // Explicitly set on iOS 8 if using automatic row height calculation

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive:", name: UIApplicationWillResignActiveNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: UIApplication.sharedApplication())

        updateMarkets()
        DynamoFavorite.fetchFromAWS(currentUser, context: managedObjectContext)

    }

    func refreshUI() {
        Debug.isBlocking()
        if let marketValue = currentUser.marketValue, subtotalAmount = marketValue.subtotalAmount, btc = currentUser.bitcoinBalanceBTC {
            balanceLabel.text = "$\(subtotalAmount) / Ƀ\(btc)"
        }

        if let marketValue = market.amount {
            addFundsLabel.text = "ADD FUNDS (Ƀ0.002 for $\(marketValue))"
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
    

    @IBAction func didTapWithdraw(sender: UIButton) {

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

    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        //dismisses ApplePay ViewController
    }


    @IBAction func didTapAddress(sender: UIButton) {
        performSegueWithIdentifier("Address", sender: self)
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
                self.refreshUI()
            }
        })
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Address" {
            let vc = segue.destinationViewController as! AddressController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
        }
    }

    @IBAction func done(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }


    // MARK: UICollectionViewDataSource

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let favorite = fetchedResultsController.objectAtIndexPath(indexPath) as! Favorite
        let twt = TWTRTweet(JSONDictionary: favorite.twitterJSON)

        let cell = tableView.dequeueReusableCellWithIdentifier(tweetTableReuseIdentifier, forIndexPath: indexPath) as! TweetCell
        cell.tweetView.configureWithTweet(twt)
        //cell.tweetView.delegate = self
        //cell.configureWithTweet(twt)

        return cell
    }

//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let favorite = fetchedResultsController.objectAtIndexPath(indexPath) as! Favorite
//        let twt = TWTRTweet(JSONDictionary: favorite.twitterJSON)
//        return TWTRTweetTableViewCell.heightForTweet(twt, width: 288.0)
//    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects!
    }


}
