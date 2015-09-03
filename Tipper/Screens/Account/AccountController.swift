//
//  AccountController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/2/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation

class AccountController: UIViewController, ContainerDelegate {
    var managedObjectContext: NSManagedObjectContext?
    var currentUser: CurrentUser!
    var market: Market!
    let className = "AccountController"
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("\(className)::\(__FUNCTION__)")
        
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
        println("\(className)::\(__FUNCTION__)")
        self.performSegueWithIdentifier("ExitToHomeFromAccount", sender: self)
    }

}
