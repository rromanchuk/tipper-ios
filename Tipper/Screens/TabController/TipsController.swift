//
//  ReceivedTips.swift
//  
//
//  Created by Ryan Romanchuk on 6/22/15.
//
//

import Foundation
import UIKit
import TwitterKit
import SwiftyJSON



class TipsController: UIViewController {
    let className = "SentTips"
    let transitionManager = TransitionManager()

    var managedObjectContext: NSManagedObjectContext!
    var currentUser: CurrentUser!
    var market: Market!

    @IBOutlet weak var tableView: UITableView!

    lazy var headerDateFormatter: NSDateFormatter = {
        let _formatter = NSDateFormatter()
        _formatter.dateFormat = "cccc, MMM d, y"
        return _formatter
    }()

    lazy var fetchedResultsController: NSFetchedResultsController = NSFetchedResultsController.superFetchedResultsController("Favorite", sectionNameKeyPath: "daySectionString", sortDescriptors: self.sortDescriptors, predicate: self.predicate, tableView: self.tableView, context: self.managedObjectContext)

    lazy var predicate: NSPredicate? = {
        return NSPredicate(format: "fromUserId = %@ OR toUserId = %@", self.currentUser.userId!, self.currentUser.userId!)
    }()

    lazy var sortDescriptors: [AnyObject] = {
        return [NSSortDescriptor(key: "tippedAt", ascending: false)]
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        log.verbose("fetchedObjects: \(fetchedResultsController.fetchedObjects?.count)")

        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension // Explicitly set on iOS 8 if using automatic row height calculation


        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        if currentUser.deepCrawledAt == nil {
            SwiftSpinner.show("Loading your tips...", animated: true)
            DynamoFavorite.fetchAllFavoritesFromUser(currentUser, context: managedObjectContext, completion: { () -> Void in
                SwiftSpinner.hide(nil)
                self.tableView.reloadData()
            })
        }
        
    }

    func refresh(refreshControl: UIRefreshControl) {
        log.verbose("")
        DynamoFavorite.updateTips(currentUser, context: managedObjectContext) { () -> Void in
            refreshControl.endRefreshing()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        log.verbose("identifier: \(segue.identifier)")

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
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let favorite = fetchedResultsController.objectAtIndexPath(indexPath) as! Favorite
        //let twt = TWTRTweet(JSONDictionary: favorite.twitterJSON)

        let cell = tableView.dequeueReusableCellWithIdentifier(className, forIndexPath: indexPath) as! TipCell
        cell.currentUser = currentUser
        cell.type = .Sent
        cell.favorite = favorite

        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section] 
            if let numericSection = Int(currentSection.name) {
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
        header.textLabel!.textColor = UIColor.colorWithRGB(0x1D1D26, alpha: 1.0)
        header.textLabel!.font = UIFont(name: "Bariol-Regular", size: 11.0)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }

    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let favorite = fetchedResultsController.objectAtIndexPath(indexPath) as? Favorite {
            return favorite.didLeaveTip
        }
        return false
    }
}
