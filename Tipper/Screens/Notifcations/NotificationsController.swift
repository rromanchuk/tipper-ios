//
//  NotificationsController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/2/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class NotificationsController: UIViewController, ContainerDelegate, CustomModable {
    let className = "NotificationsController"
    var managedObjectContext: NSManagedObjectContext?
    var currentUser: CurrentUser!
    var market: Market!
    
    @IBOutlet weak var headerContainer: UIView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("\(className)::\(__FUNCTION__)")

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("\(className)::\(__FUNCTION__) identifier: \(segue.identifier)")
        
        if segue.identifier == "NotificationsEmbed" {
            let vc = segue.destinationViewController as! NotificationsTableController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
        } else if segue.identifier == "NotificationHeaderEmbed" {
            let vc = segue.destinationViewController as! HeaderContainer
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
            vc.activeScreenType = .NotificationsScreen
            vc.containerDelegate = self
        }
        
    }
    
    func prepareForSegueAnimation() {
        println("\(className)::\(__FUNCTION__)")
        view.backgroundColor = UIColor.clearColor()
        headerContainer.hidden = true
    }
    
    func segueAnimationComplete() {
        view.backgroundColor = UIColor.brandColor()
        headerContainer.hidden = false
    }
    
//    func prepareForUnwindSegue() {
//        prepareForSegue()
//    }
//    
//    func segueUnwindComplete() {
//        
//    }
    
    
    @IBAction func didTapClose() {
        println("\(className)::\(__FUNCTION__)")
        self.performSegueWithIdentifier("ExitToHomeFromNotifications", sender: self)
    }

}
