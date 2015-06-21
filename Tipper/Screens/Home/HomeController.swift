//
//  HomeController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/25/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import TwitterKit
import SwiftyJSON

class HomeController: UIViewController, NotificationMessagesDelegate, UITableViewDelegate, Logoutable {
    var managedObjectContext: NSManagedObjectContext!
    var currentUser: CurrentUser!
    var market: Market!
    var showBalanceBTC = false
    let tweetTableReuseIdentifier = "TipCell"
    let transitionManager = TransitionManager()

    lazy var headerDateFormatter: NSDateFormatter = {
        let _formatter = NSDateFormatter()
        _formatter.dateFormat = "cccc, MMM d, y"
        return _formatter
    }()


    var className = "HomeController"

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!

    lazy var fetchedResultsController: NSFetchedResultsController = NSFetchedResultsController.superFetchedResultsController("Favorite", sectionNameKeyPath: "daySectionString", sortDescriptors: self.sortDescriptors, predicate: self.predicate, tableView: self.tableView, context: self.managedObjectContext)

    lazy var predicate: NSPredicate? = {
        return NSPredicate(format: "fromUserId = %@", self.currentUser.userId!)
    }()

    lazy var receivedPredicate: NSPredicate? = {
        return NSPredicate(format: "toUserId = %@", self.currentUser.userId!)
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
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension // Explicitly set on iOS 8 if using automatic row height calculation
        tableView.layer.cornerRadius = 2.0


        DynamoFavorite.fetchFromAWS(currentUser, context: managedObjectContext)
        DynamoFavorite.fetchReceivedFromAWS(currentUser, context: managedObjectContext)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "UNAUTHORIZED_USER", object: nil)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)

    }

    func refresh(refreshControl: UIRefreshControl) {
        DynamoFavorite.fetchFromAWS(currentUser, context: managedObjectContext)
        DynamoFavorite.fetchReceivedFromAWS(currentUser, context: managedObjectContext)
        refreshControl.endRefreshing()
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        (UIApplication.sharedApplication().delegate as! AppDelegate).notificationsDelegate = self
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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


    func didReceiveNotificationAlert(message: String, subtitle: String, type: TSMessageNotificationType) {
        println("\(className)::\(__FUNCTION__)")
        TSMessage.showNotificationInViewController(self, title: message, subtitle: subtitle, type: type, duration: 5.0)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("\(className)::\(__FUNCTION__) identifier: \(segue.identifier)")

        if segue.identifier == "TipDetails" {
            let cell: TipCell = sender as! TipCell
            let indexPath = tableView.indexPathForCell(cell)
            let favorite: Favorite = fetchedResultsController.objectAtIndexPath(indexPath!) as! Favorite
            let vc = segue.destinationViewController as! TipDetailsViewController
            vc.transitioningDelegate = self.transitionManager
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.favorite = favorite
            vc.market = market
        } else if segue.identifier == "HomeHeaderEmbed" {
            let vc = segue.destinationViewController as! HeaderContainer
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
            //vc.favorite = favorite
        }

    }

    func backToSplash() {
        println("\(className)::\(__FUNCTION__)")
        currentUser.resetIdentifiers()
        (UIApplication.sharedApplication().delegate as! AppDelegate).resetCoreData()
        performSegueWithIdentifier("BackToSplash", sender: self)
    }

    @IBAction func done(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("\(className)::\(__FUNCTION__)")
    }


    // MARK: UICollectionViewDataSource

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let favorite = fetchedResultsController.objectAtIndexPath(indexPath) as! Favorite
        let twt = TWTRTweet(JSONDictionary: favorite.twitterJSON)

        let cell = tableView.dequeueReusableCellWithIdentifier(tweetTableReuseIdentifier, forIndexPath: indexPath) as! TipCell
        cell.currentUser = currentUser
        cell.type = TipCellType(rawValue: segmentControl.selectedSegmentIndex)!
        cell.favorite = favorite



        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section] as! NSFetchedResultsSectionInfo
            if let name = currentSection.name, numericSection = name.toInt() {
                let year = numericSection / 10000;
                let month = (numericSection / 100) % 100;
                let day = numericSection % 100;

                let dateComponents: NSDateComponents =  NSDateComponents()
                dateComponents.year = year
                dateComponents.month = month
                dateComponents.day = day

                let date = NSCalendar.currentCalendar().dateFromComponents(dateComponents)
                return headerDateFormatter.stringFromDate(date!)
            }
        }

        return ""
    }


    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.colorWithRGB(0x1D1D26, alpha: 0.10)

        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel.textColor = UIColor.colorWithRGB(0x1D1D26, alpha: 1.0)
        header.textLabel.font = UIFont(name: "Bariol-Regular", size: 11.0)
    }


    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects!
    }

    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let favorite = fetchedResultsController.objectAtIndexPath(indexPath) as? Favorite {
            return favorite.didLeaveTip
        }
        return false
    }


}

