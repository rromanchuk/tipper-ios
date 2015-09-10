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
        print("\(className)::\(__FUNCTION__)", terminator: "")
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("\(className)::\(__FUNCTION__)", terminator: "")
        requestBalanceFromPhone()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        print("\(className)::\(__FUNCTION__)", terminator: "")
    }


    @IBAction func refresh() {
        requestBalanceFromPhone()
    }
    
    func requestBalanceFromPhone() {
        
        WKInterfaceController.openParentApplication(["request": "balance"], reply: { (replyInfo, error) -> Void in
            print("\(self.className)::\(__FUNCTION__) replyInfo:\(replyInfo) error:\(error)", terminator: "")
            if error == nil  {
                if let balance: String = replyInfo["balance"] as? String  {
                    self.balanceLabel.setText(balance)
                }
            }
            

        })
    }
}
