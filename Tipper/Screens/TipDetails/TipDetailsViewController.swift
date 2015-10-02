//
//  TipDetailsViewController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 6/8/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class TipDetailsViewController: UIViewController, Logoutable, CustomSegueable {
    let className = "TipDetailsViewController"
    var managedObjectContext: NSManagedObjectContext!
    var currentUser: CurrentUser!
    var favorite: Favorite!
    var market: Market!


    override func viewDidLoad() {
        super.viewDidLoad()
        log.verbose("")

        // Do any additional setup after loading the view.
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
    
    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        log.verbose("toViewController: \(toViewController), fromViewController: \(fromViewController)")
        if let _ = fromViewController as? CustomSegueable {
            
            let unwindSegue = CustomUnwindModalSegue(identifier: identifier, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
                
            })
            return unwindSegue
        }
        
        return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)!
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        log.verbose("identifier: \(segue.identifier)")

        if segue.identifier == "TipDetailEmbed" {
            let vc = segue.destinationViewController as! TipDetailContainer
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.favorite = favorite
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
        
    }

    func segueAnimationComplete() {

    }

}
