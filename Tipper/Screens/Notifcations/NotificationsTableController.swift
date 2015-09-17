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
        return NSPredicate(format: "userId == %@", self.currentUser.userId!)
    }()

    lazy var sortDescriptors: [NSSortDescriptor] = {
        return [NSSortDescriptor(key: "createdAt", ascending: false)]
    }()

    lazy var fetchRequest: NSFetchRequest = {
        let request = NSFetchRequest(entityName: "Notification")
        request.predicate = self.predicate
        request.sortDescriptors = self.sortDescriptors
        return request
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(className)::\(__FUNCTION__)")
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)

        
        DynamoNotification.fetch(currentUser.userId!, context: managedObjectContext) { () -> Void in
            print("\(self.className)::\(__FUNCTION__) count\(self.fetchedResultsController.fetchedObjects?.count)")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell", forIndexPath: indexPath) as! NotificationCell
        let notification = fetchedResultsController.objectAtIndexPath(indexPath) as! Notification
        cell.notification = notification
        
        return cell
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        DynamoNotification.fetch(currentUser.userId!, context: managedObjectContext) { () -> Void in
            refreshControl.endRefreshing()
        }
    }
}
