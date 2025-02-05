//
//  GlanceController.swift
//  Tipper WatchKit Extension
//
//  Created by Ryan Romanchuk on 6/20/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {
    let className = "GlanceController"
    @IBOutlet weak var balanceLabel: WKInterfaceLabel!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        requestBalanceFromPhone()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func requestBalanceFromPhone() {
        WKInterfaceController.openParentApplication(["request": "balance"], reply: { (replyInfo, error) -> Void in
            print("\(self.className)::\(__FUNCTION__) replyInfo:\(replyInfo) error:\(error)", terminator: "")
            if let balance: String = replyInfo["balance"] as? String {
                self.balanceLabel.setText(balance)
            }

        })
    }


}
