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
        print("\(className)::\(__FUNCTION__)")
        TSMessage.showNotificationInViewController(self, title: message, subtitle: subtitle, type: type, duration: 5.0)
        refresh()
    }

    func refresh() {
        print("\(className)::\(__FUNCTION__)")
        refreshDelegate?.refreshHeader()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("\(className)::\(__FUNCTION__) identifier: \(segue.identifier)")

        if segue.identifier == "HomeHeaderEmbed" {
            let vc = segue.destinationViewController as! HeaderContainer
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
            vc.activeScreenType = .Unknown
            refreshDelegate = vc
            self.headerContainerController = vc
            //vc.favorite = favorite
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
        print("\(className)::\(__FUNCTION__)")
        currentUser.resetIdentifiers()
        (UIApplication.sharedApplication().delegate as! AppDelegate).resetCoreData()
        performSegueWithIdentifier("BackToSplash", sender: self)
    }

    @IBAction func done(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("\(className)::\(__FUNCTION__) identifier: \(segue.identifier) \(segue.sourceViewController)")
        let vc = segue.sourceViewController
        if let header = vc as? HeaderContainer {
           header.refreshHeader()
        }
    }
    
    override func viewControllerForUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject?) -> UIViewController? {
        print("\(className)::\(__FUNCTION__) fromViewController: \(fromViewController)")
        let vc = super.viewControllerForUnwindSegueAction(action, fromViewController: fromViewController, withSender: sender)
        print("viewController to handle the unwind: \(vc)")
        return vc
    }
    
    override func canPerformUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject) -> Bool {
        print("\(className)::\(__FUNCTION__) fromViewController: \(fromViewController)")
        let canPerform =  super.canPerformUnwindSegueAction(action, fromViewController: fromViewController, withSender: sender)
        print("canPerform?: \(canPerform)")
        return canPerform
    }

    
    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        print("\(className)::\(__FUNCTION__) toViewController: \(toViewController), fromViewController: \(fromViewController)")
        if let _ = fromViewController as? CustomModable {

            let unwindSegue = CustomUnwindModalSegue(identifier: identifier, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
                
            })
            return unwindSegue
        }
        
        return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)!
    }
    


}

protocol SegmentControlDelegate:class {
    func segmentChanged(sender: UISegmentedControl)
}

protocol RefreshControlDelegate:class {
    func refreshHeader()
}