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
import TSMessages


class HomeController: GAITrackedViewController, NotificationMessagesDelegate, UITableViewDelegate, Logoutable {

    var managedObjectContext: NSManagedObjectContext!
    var currentUser: CurrentUser!
    var market: Market!

    let className = "HomeController"
    let tweetTableReuseIdentifier = "TipCell"
    var headerContainerController: HeaderContainer!

    weak var refreshDelegate: RefreshControlDelegate?

    lazy var headerDateFormatter: NSDateFormatter = {
        let _formatter = NSDateFormatter()
        _formatter.dateFormat = "cccc, MMM d, y"
        return _formatter
    }()


    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var tipsContainer: UIView!


    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backToSplash", name: "BACK_TO_SPLASH", object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        (UIApplication.sharedApplication().delegate as! AppDelegate).notificationsDelegate = self
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    func didReceiveNotificationAlert(message: String, subtitle: String, type: TSMessageNotificationType) {
        log.verbose("")
        TSMessage.showNotificationInViewController(self, title: message, subtitle: subtitle, type: type, duration: 5.0)
        refresh()
    }

    func refresh() {
        log.verbose("")
        refreshDelegate?.refreshHeader()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        log.verbose("identifier: \(segue.identifier)")

        if segue.identifier == "HomeHeaderEmbed" {
            let vc = segue.destinationViewController as! HeaderContainer
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
            vc.activeScreenType = .Unknown
            refreshDelegate = vc
            self.headerContainerController = vc
        } else if segue.identifier == "FeedEmbed" {
            let vc = segue.destinationViewController as! TipsController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
        } else if segue.identifier == "DidTapNotifications" {
            let vc = segue.destinationViewController as! NotificationsController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
            vc.exitSegueIdentifier = "ExitToHomeFromNotifications"
        } else if segue.identifier == "DidTapAccountSegue" {
            let vc = segue.destinationViewController as! AccountController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
            vc.exitSegueIdentifier = "ExitToHomeFromAccount"
        }
    }

    func backToSplash() {
        log.verbose("")
        currentUser.resetIdentifiers()
        (UIApplication.sharedApplication().delegate as! AppDelegate).resetCoreData()
        performSegueWithIdentifier("BackToSplash", sender: self)
    }

    @IBAction func done(segue: UIStoryboardSegue, sender: AnyObject?) {
        log.verbose("\(className)::\(__FUNCTION__) identifier: \(segue.identifier) \(segue.sourceViewController)")
        let vc = segue.sourceViewController
        if let header = vc as? HeaderContainer {
           header.refreshHeader()
        }
    }
    

}

protocol SegmentControlDelegate:class {
    func segmentChanged(sender: UISegmentedControl)
}

protocol RefreshControlDelegate:class {
    func refreshHeader()
}