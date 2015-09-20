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
        print("\(className)::\(__FUNCTION__) userId: \(self.currentUser.userId!)")
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)

        
        DynamoNotification.fetch(currentUser.userId!, context: managedObjectContext) { () -> Void in
            print("\(self.className)::\(__FUNCTION__) count\(self.fetchedResultsController.fetchedObjects!)")
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
        print("\(className)::\(__FUNCTION__)")
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell", forIndexPath: indexPath) as! NotificationCell
        let notification = fetchedResultsController.objectAtIndexPath(indexPath) as! Notification
        cell.notification = notification
        
        print("Setting cell with \(notification)")
        return cell
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

}
