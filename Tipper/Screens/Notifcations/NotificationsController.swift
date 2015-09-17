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
    var managedObjectContext: NSManagedObjectContext!
    var currentUser: CurrentUser!
    var market: Market!
    var exitSegueIdentifier: String!
    
    @IBOutlet weak var headerContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("\(className)::\(__FUNCTION__)")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("\(className)::\(__FUNCTION__) identifier: \(segue.identifier)")
        
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
        print("\(className)::\(__FUNCTION__)")
        view.backgroundColor = UIColor.clearColor()
        headerContainer.hidden = true
    }
    
    func segueAnimationComplete() {
        view.backgroundColor = UIColor.brandColor()
        headerContainer.hidden = false
    }

    @IBAction func didTapClose() {
        print("\(className)::\(__FUNCTION__)")
        self.performSegueWithIdentifier(exitSegueIdentifier, sender: self)
    }

}
