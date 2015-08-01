//
//  Settings.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 5/24/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Settings: NSManagedObject {
    @NSManaged var fundAmount: String?
    @NSManaged var tipAmount: String?
    @NSManaged var feeAmount: String?
    @NSManaged var user: Tipper.CurrentUser?

    let className = "Settings"

    func update() {
        API.sharedInstance.settings { (json, error) -> Void in
            Debug.isBlocking()
            self.managedObjectContext?.performBlock({ () -> Void in
                self.updateEntityWithJSON(json)
            })
        }
    }

    func updateEntityWithJSON(json: JSON) {
        println("\(className)::\(__FUNCTION__) json:\(json)")
        self.fundAmount = json["fund_amount"].stringValue
        self.tipAmount = json["tip_amount"].stringValue
        self.feeAmount = json["fee_amount"].string
    }


    var tipAmountUBTC:String {
        get {
            if let tipAmount = self.tipAmount {
                let tipAmountFloat = (tipAmount as NSString).floatValue
                let uBTCFloat = tipAmountFloat / 0.00000100
                return "\(Int(uBTCFloat))"
            } else {
                return "0"
            }
        }
    }

    var fundAmountUBTC:String {
        get {
            if let fundAmount = self.fundAmount {
                let fundAmountFloat = (fundAmount as NSString).floatValue
                let uBTCFloat = fundAmountFloat / 0.00000100
                return "\(Int(uBTCFloat))"
            } else {
                return "0"
            }
        }
    }
}