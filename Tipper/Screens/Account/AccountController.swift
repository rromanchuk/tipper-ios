//
//  AccountController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/2/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation

class AccountController: GAITrackedViewController, ContainerDelegate, CustomSegueable {
    var managedObjectContext: NSManagedObjectContext?
    var currentUser: CurrentUser!
    var market: Market!
    var exitSegueIdentifier: String!
    let className = "AccountController"
    
    @IBOutlet weak var headerContainer: UIView!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        log.verbose("")
        
        if segue.identifier == "AccountEmbed" {
            let vc = segue.destinationViewController as! WalletController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
        } else if segue.identifier == "AccountHeaderEmbed" {
            let vc = segue.destinationViewController as! HeaderContainer
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
            vc.activeScreenType = .AccountScreen
            vc.containerDelegate = self
        }

    }
    
    func didTapClose() {
        log.verbose("")
        self.performSegueWithIdentifier(exitSegueIdentifier, sender: self)
    }
    
    func prepareForSegueAnimation() {
        log.verbose("")
        view.backgroundColor = UIColor.clearColor()
        headerContainer.hidden = true
    }
    
    func segueAnimationComplete() {
        view.backgroundColor = UIColor.brandColor()
        headerContainer.hidden = false
    }
    
    func prepareForUnwindSegue() {
        
    }
    
    func segueUnwindComplete() {
        
    }

}
