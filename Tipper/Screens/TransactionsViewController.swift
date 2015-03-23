//
//  TransactionsViewController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/13/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import TwitterKit
import Alamofire
import SwiftyJSON

class TransactionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TWTRTweetViewDelegate {
    //var currentUser: CurrentUser?
    var provider: TwitterAuth?
    var className = "TransactionsViewController"
    let tweetTableReuseIdentifier = "TweetCell"
    var tweets = Set<TWTRTweet>()

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
        tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: tweetTableReuseIdentifier)
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension // Explicitly set on iOS 8 if using automatic row height calculation
        tableView.allowsSelection = false
        tableView.delegate = self

        let req = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL: "https://api.twitter.com/1.1/favorites/list.json", parameters: ["count": "200", "include_entities": "false"], error: nil)


        Alamofire.Manager.sharedInstance.request(req).responseSwiftyJSON(options: nil) { (request, response, json, error) -> Void in
            let privateContext = self.managedObjectContext.privateContext
            privateContext.performBlock({ () -> Void in
                for tweet in json.arrayValue {
                    let fav = Favorite.entityWithJSON(Favorite.self, json: tweet, context: privateContext)!
                    fav.save()
                }
            })

        }

    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let favorite = fetchedResultsController.objectAtIndexPath(indexPath) as! Favorite
        let twt = TWTRTweet(JSONDictionary: favorite.twitterJSON)
        return TWTRTweetTableViewCell.heightForTweet(twt, width: CGRectGetWidth(self.view.bounds))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let favorite = fetchedResultsController.objectAtIndexPath(indexPath) as! Favorite
        let twt = TWTRTweet(JSONDictionary: favorite.twitterJSON)

        let cell = tableView.dequeueReusableCellWithIdentifier(tweetTableReuseIdentifier, forIndexPath: indexPath) as! TWTRTweetTableViewCell
        cell.tweetView.delegate = self
        cell.configureWithTweet(twt)

        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects!
    }

    

}
