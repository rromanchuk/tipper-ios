//
//  NotificationsTableController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/2/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class NotificationsTableController: UITableViewController {
    let className = "NotificationsTableController"
    var managedObjectContext: NSManagedObjectContext!
    var currentUser: CurrentUser!
    var market: Market!
    
    lazy var fetchedResultsController: NSFetchedResultsController = NSFetchedResultsController.superFetchedResultsController("Notification", sectionNameKeyPath: nil, sortDescriptors: self.sortDescriptors, predicate: self.predicate, tableView: self.tableView, context: self.managedObjectContext)

    lazy var predicate: NSPredicate? = {
        return NSPredicate(format: "userId = %@", self.currentUser.userId!)
    }()

    lazy var sortDescriptors: [NSSortDescriptor] = {
        return [NSSortDescriptor(key: "createdAt", ascending: false)]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.verbose("\(className)::\(__FUNCTION__) userId: \(self.currentUser.userId!)")
        Settings.get("1")
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)

        
        DynamoNotification.fetch(currentUser.userId!, context: managedObjectContext) { () -> Void in
            log.verbose("\(self.className)::\(__FUNCTION__) count\(self.fetchedResultsController.fetchedObjects!)")
            self.tableView.reloadData()
        }

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        Notification.markAllAsRead()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        log.verbose("\(className)::\(__FUNCTION__)")
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell", forIndexPath: indexPath) as! NotificationCell
        let notification = fetchedResultsController.objectAtIndexPath(indexPath) as! Notification
        cell.notification = notification
        
        log.verbose("Setting cell with \(notification)")
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let notification = fetchedResultsController.objectAtIndexPath(indexPath) as! Notification
        log.verbose("notification: \(notification)")
        if let tipId = notification.tipId, tipFromUserId = notification.tipFromUserId where notification.type == "user_sent_tip" {
            if let favorite = Favorite.fetchFromCoreData(tipId, fromUserId: tipFromUserId, context: managedObjectContext) {
                self.performSegueWithIdentifier("TipDetail", sender: favorite)
            } else if let favorite = Favorite.fetchFromDynamo(tipFromUserId, tipId: tipId, context: managedObjectContext){
                self.performSegueWithIdentifier("TipDetail", sender: favorite)
            }

        }


    }

    func refresh(refreshControl: UIRefreshControl) {
        DynamoNotification.fetch(currentUser.userId!, context: managedObjectContext) { () -> Void in
            refreshControl.endRefreshing()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TipDetails" {
            let vc = segue.destinationViewController as! TipDetailsViewController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.favorite = sender as! Favorite
        }
    }

}
