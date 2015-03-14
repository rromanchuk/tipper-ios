//
//  TransactionsViewController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/13/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class TransactionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //var currentUser: CurrentUser?
    var provider: TwitterAuth?
    var className = "TransactionsViewController"


    var managedObjectContext: NSManagedObjectContext {
        get {
            return (tabBarController as! TipperTabBarController).managedObjectContext!
        }
    }

    var currentUser: CurrentUser {
        get {
            return (tabBarController as! TipperTabBarController).currentUser!
        }
    }


    @IBOutlet weak var tableView: UITableView!

    lazy var fetchedResultsController: NSFetchedResultsController = NSFetchedResultsController.superFetchedResultsController("Favorite", sectionNameKeyPath: nil, sortDescriptors: self.sortDescriptors, predicate: self.predicate, tableView: self.tableView, context: self.managedObjectContext)


    lazy var predicate: NSPredicate? = {
        let now = NSDate()
        let hourAgo = now.dateByAddingTimeInterval(-(60 * 60) * 24)
        return nil
    }()

    lazy var sortDescriptors: [AnyObject] = {
        return [NSSortDescriptor(key: "createdAt", ascending: true)]
    }()

    lazy var fetchRequest: NSFetchRequest = {
        let request = NSFetchRequest(entityName: "Favorite")
        request.predicate = self.predicate
        request.sortDescriptors = self.sortDescriptors
        return request
    }()



    override func viewDidLoad() {
        super.viewDidLoad()
        DynamoFavorite.fetch(currentUser, context: managedObjectContext)
        //DynamoFavorite.fetchFromAWS(currentUser, context: managedObjectContext)
        fetchedResultsController.performFetch(nil)
        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let favorite = fetchedResultsController.objectAtIndexPath(indexPath) as! Favorite
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("TransactionCell", forIndexPath: indexPath) as! UITableViewCell
        println("favorite: \(favorite)")
        cell.textLabel?.text = favorite.tweetText


        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects!
    }

    

}
