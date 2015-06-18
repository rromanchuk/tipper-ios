//
//  TipDetailsViewController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 6/8/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class TipDetailsViewController: UIViewController, Logoutable {
    let className = "TipDetailsViewController"
    var managedObjectContext: NSManagedObjectContext!
    var currentUser: CurrentUser!
    var favorite: Favorite!
    var market: Market!


    override func viewDidLoad() {
        super.viewDidLoad()
        println("\(className)::\(__FUNCTION__)")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func backToSplash() {
        println("\(className)::\(__FUNCTION__)")
        currentUser.resetIdentifiers()
        performSegueWithIdentifier("BackToSplashFromTipDetails", sender: self)
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("\(className)::\(__FUNCTION__) identifier: \(segue.identifier)")

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
        }
    }

}
