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

    let className = "HomeController"
    let tweetTableReuseIdentifier = "TipCell"
    let transitionManager = TransitionManager()

    weak var refreshDelegate: RefreshControlDelegate?

    lazy var headerDateFormatter: NSDateFormatter = {
        let _formatter = NSDateFormatter()
        _formatter.dateFormat = "cccc, MMM d, y"
        return _formatter
    }()


    @IBOutlet weak var tabBarContainer: UIView!


    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backToSplash", name: "BACK_TO_SPLASH", object: nil)
        let font = UIFont(name: "Bariol-Regular", size: 19)!
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        (UIApplication.sharedApplication().delegate as! AppDelegate).notificationsDelegate = self
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    func didReceiveNotificationAlert(message: String, subtitle: String, type: TSMessageNotificationType) {
        println("\(className)::\(__FUNCTION__)")
        TSMessage.showNotificationInViewController(self, title: message, subtitle: subtitle, type: type, duration: 5.0)
        refresh()
    }

    func refresh() {
        println("\(className)::\(__FUNCTION__)")
        refreshDelegate?.refreshUI()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("\(className)::\(__FUNCTION__) identifier: \(segue.identifier)")

        if segue.identifier == "HomeHeaderEmbed" {
            let vc = segue.destinationViewController as! HeaderContainer
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
            refreshDelegate = vc
            //vc.favorite = favorite
        } else if segue.identifier == "FeedEmbed" {
            let vc = segue.destinationViewController as! TipsController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
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

}

protocol SegmentControlDelegate:class {
    func segmentChanged(sender: UISegmentedControl)
}

protocol RefreshControlDelegate:class {
    func refreshUI()
}