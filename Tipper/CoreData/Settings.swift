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

class Settings: NSManagedObject, CoreDataUpdatable {
    @NSManaged var fundAmount: String?
    @NSManaged var tipAmount: String?
    @NSManaged var feeAmount: String?
    @NSManaged var version: String?
    
    static let sharedInstance = Settings.createInstance()
    
    class func createInstance() -> Settings {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let _settings = NSEntityDescription.insertNewObjectForEntityForName("Settings", inManagedObjectContext: appDelegate.managedObjectContext) as! Settings
        return _settings
    }
    
    class var className: String {
        get {
            return "Settings"
        }
    }

    var className: String {
        return Settings.className
    }

    static func lookupProperty() -> String {
        return Settings.lookupProperty()
    }

    func lookupProperty() -> String {
        return "version"
    }

    func lookupValue() -> String {
        return self.version!
    }

    class func dateForTwitterDate(date: String) -> NSDate {
        return TwitterDateFormatter.dateFromString(date)!
    }

    class func get(settingId: String = "1") {

        TIPPERTipperClient.defaultClient().settingsGet(settingId).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            log.verbose("Settings fetch \(task.result), \(task.error) exception: \(task.exception)")
            if let settings = task.result as? TIPPERSettings {
                Settings.sharedInstance.updateEntityWithModel(settings)
            }
            return nil;
        })
    }

    func updateEntityWithModel(model: Any) {
        if let settings = model as? TIPPERSettings {
            self.version                    = settings.Version
            self.fundAmount                 = settings.FundAmount
            self.tipAmount                  = settings.TipAmount
            self.feeAmount                  = settings.FeeAmount
        }
    }


    var tipAmountUBTC:String? {
        get {
            if let tipAmount = self.tipAmount {
                let tipAmountFloat = (tipAmount as NSString).floatValue
                let uBTCFloat = tipAmountFloat / 0.00000100
                return "\(Int(uBTCFloat))"
            } else {
                return nil
            }
        }
    }

    var fundAmountUBTC:String? {
        get {
            if let fundAmount = self.fundAmount {
                let fundAmountFloat = (fundAmount as NSString).floatValue
                let uBTCFloat = fundAmountFloat / 0.00000100
                return "\(Int(uBTCFloat))"
            } else {
                return nil
            }
        }
    }
}