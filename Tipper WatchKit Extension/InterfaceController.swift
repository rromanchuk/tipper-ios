//
//  InterfaceController.swift
//  Tipper WatchKit Extension
//
//  Created by Ryan Romanchuk on 6/20/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    let className = "InterfaceController"

    @IBOutlet weak var balanceLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        println("\(className)::\(__FUNCTION__)")
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        println("\(className)::\(__FUNCTION__)")
        requestBalanceFromPhone()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        println("\(className)::\(__FUNCTION__)")
    }


    @IBAction func refresh() {
        requestBalanceFromPhone()
    }
    
    func requestBalanceFromPhone() {
        WKInterfaceController.openParentApplication(["request": "balance"], reply: { (replyInfo, error) -> Void in
            println("\(self.className)::\(__FUNCTION__) replyInfo:\(replyInfo) error:\(error)")
            if let balance: String = replyInfo["balance"] as? String {
                self.balanceLabel.setText(balance)
            }

        })
    }
}
