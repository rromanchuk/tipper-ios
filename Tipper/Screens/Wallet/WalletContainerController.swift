//
//  WalletContainerController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 5/16/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class WalletContainerController: UIViewController {
    var managedObjectContext: NSManagedObjectContext?
    var currentUser: CurrentUser!
    var market: Market!
    let className = "WalletContainerController"

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setBalance()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("\(className)::\(__FUNCTION__)")

        if segue.identifier == "WalletEmbed" {
            let vc = segue.destinationViewController as! WalletController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
        }
    }
    

    @IBAction func closeTapped(sender: UIButton) {
        println("\(className)::\(__FUNCTION__)")
        performSegueWithIdentifier("WalletClose", sender: self)
    }

    func setBalance() {
        let string = "a\(currentUser.balanceAsUBTC)"
        let labelAttributes = NSMutableAttributedString(string: string)
        labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "coiner", size: 42.0)!, range: NSMakeRange(0,1))
        labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol-Regular", size: 40.0)!, range: NSMakeRange(1, count(string) - 1))
        labelAttributes.addAttribute(NSKernAttributeName, value:-5.0, range: NSMakeRange(0, 1))
        balanceLabel.attributedText = labelAttributes
    }

}
