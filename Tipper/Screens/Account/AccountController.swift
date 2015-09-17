//
//  AccountController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/2/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation

class AccountController: UIViewController, ContainerDelegate, CustomModable {
    var managedObjectContext: NSManagedObjectContext?
    var currentUser: CurrentUser!
    var market: Market!
    var exitSegueIdentifier: String!
    let className = "AccountController"
    
    @IBOutlet weak var headerContainer: UIView!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("\(className)::\(__FUNCTION__)", terminator: "")
        
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
        print("\(className)::\(__FUNCTION__)", terminator: "")
        self.performSegueWithIdentifier(exitSegueIdentifier, sender: self)
    }
    
    func prepareForSegueAnimation() {
        print("\(className)::\(__FUNCTION__)", terminator: "")
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
