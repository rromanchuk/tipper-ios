//
//  TipTabBarController.swift
//  
//
//  Created by Ryan Romanchuk on 6/22/15.
//
//

import UIKit

class TipTabBarController: UITabBarController, SegmentControlDelegate {
    let className = "TipTabBarController"

    var managedObjectContext: NSManagedObjectContext!
    var currentUser: CurrentUser!
    var market: Market!

    override func viewDidLoad() {
        super.viewDidLoad()
        println("\(className)::\(__FUNCTION__)")

        tabBar.hidden = true
        if let controllers = viewControllers {
            for vc in controllers {
                if let receivedVc = vc as? ReceivedTips {
                    receivedVc.managedObjectContext = managedObjectContext
                    receivedVc.currentUser = currentUser
                    receivedVc.market = market
                } else if let sentVc = vc as? SentTips {
                    sentVc.managedObjectContext = managedObjectContext
                    sentVc.currentUser = currentUser
                    sentVc.market = market
                }
            }
        }
    }

    func refresh() {
        println("\(className)::\(__FUNCTION__)")
        (parentViewController as? HomeController)?.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func segmentChanged(sender: UISegmentedControl) {
        println("\(className)::\(__FUNCTION__)")
        selectedIndex = sender.selectedSegmentIndex
    }
}
