//
//  TipDetailsViewController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 6/8/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class TipDetailsViewController: UIViewController {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("\(className)::\(__FUNCTION__)")

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
