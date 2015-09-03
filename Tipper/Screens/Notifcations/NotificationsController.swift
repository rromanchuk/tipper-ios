//
//  NotificationsController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/2/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class NotificationsController: UIViewController, ContainerDelegate {
    let className = "NotificationsController"
    var managedObjectContext: NSManagedObjectContext?
    var currentUser: CurrentUser!
    var market: Market!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("\(className)::\(__FUNCTION__)")
//        if let header = parentViewController as? HeaderContainer {
//            header.toggleRightButton()
//        }
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
    
//    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
//        if let id = identifier{
//            println("\(className)::\(__FUNCTION__) identifier: \(id)")
//            if id == "ExitToHome" {
//                let unwindSegue = CustomUnwindModalSegue(identifier: id, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
//                    
//                })
//                return unwindSegue
//            }
//        }
//        
//        return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)
//    }
    
    @IBAction func didTapClose() {
        println("\(className)::\(__FUNCTION__)")
        self.performSegueWithIdentifier("ExitToHomeFromNotifications", sender: self)
    }

}
