//
//  TipDetailsViewController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 6/8/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class TipDetailsViewController: GAITrackedViewController, Logoutable, CustomSegueable {
    let className = "TipDetailsViewController"
    var managedObjectContext: NSManagedObjectContext!
    var currentUser: CurrentUser!
    var favorite: Favorite?
    var market: Market!
    var notification: Notification?

    @IBOutlet weak var headerContainer: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        log.verbose("")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func backToSplash() {
        log.verbose("")
        currentUser.resetIdentifiers()
        performSegueWithIdentifier("BackToSplashFromTipDetails", sender: self)
    }
    
    @IBAction func done(segue: UIStoryboardSegue, sender: AnyObject?) {
        log.verbose("identifier: \(segue.identifier) \(segue.sourceViewController)")
        let vc = segue.sourceViewController
        if let header = vc as? HeaderContainer {
            header.refreshHeader()
        }
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        log.verbose("identifier: \(segue.identifier)")

        if segue.identifier == "TipDetailEmbed" {
            let vc = segue.destinationViewController as! TipDetailContainer
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.favorite = favorite
            vc.notification = notification
        } else if segue.identifier == "TipDetailsHeaderEmbed" {
            let vc = segue.destinationViewController as! HeaderContainer
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
        } else if segue.identifier == "DidTapNotifications" {
            let vc = segue.destinationViewController as! NotificationsController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
            vc.exitSegueIdentifier = "ExitToTipDetailsFromNotifications"
        } else if segue.identifier == "DidTapAccountSegue" {
            let vc = segue.destinationViewController as! AccountController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
            vc.exitSegueIdentifier = "ExitToTipDetailsFromAccount"
        }
    }

    func prepareForSegueAnimation() {
        log.verbose("")
        view.backgroundColor = UIColor.clearColor()
        headerContainer.hidden = true
    }

    func segueAnimationComplete() {
        log.verbose("")
        view.backgroundColor = UIColor.brandColor()
        headerContainer.hidden = false


    }

}
