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

    static var lookupProperty: String {
        get {
            return "version"
        }
    }

    var lookupValue: String {
        get {
            return self.version!
        }
    }

    class func dateForTwitterDate(date: String) -> NSDate {
        return TwitterDateFormatter.dateFromString(date)!
    }

    class func get(settingId: String = "1") {

        TIPPERTipperClient.defaultClient().settingsGet(settingId).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            print("Settings fetch \(task.result), \(task.error) exception: \(task.exception)")
            if let settings = task.result as? TIPPERSettings {
                print("Settings  \(settings.Version)")
                Settings.sharedInstance.version = settings.Version
                Settings.sharedInstance.fundAmount = settings.FundAmount
                Settings.sharedInstance.feeAmount = settings.FeeAmount
                Settings.sharedInstance.tipAmount = settings.TipAmount
                Settings.sharedInstance.writeToDisk()
            }
            
            return nil;
        })
    }
//
//    class func update() {
//        print("\(className)::\(__FUNCTION__)")
//        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
//        let exp = AWSDynamoDBScanExpression()
//        exp.limit = 1
//
//        mapper.scan(DynamoSettings.self, expression: exp).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
//            print("Result: \(task.result) Error \(task.error), Exception: \(task.exception)")
//            if let results = task.result as?  AWSDynamoDBPaginatedOutput where task.error == nil && task.exception == nil {
//                if let dynamoSettings: DynamoSettings = results.items[0] as? DynamoSettings {
//                    self.updateEntityWithDynamoModel(dynamoSettings)
//                    self.writeToDisk()
//                }
//            }
//            return nil
//        })
//
//        
//    }

    func updateEntityWithJSON(json: JSON) {
        print("\(className)::\(__FUNCTION__) json:\(json)")
        self.fundAmount = json["fund_amount"].stringValue
        self.tipAmount = json["tip_amount"].stringValue
        self.feeAmount = json["fee_amount"].string
    }

    func updateEntityWithDynamoModel(dynamoModel: DynamoUpdatable) {
        print("\(className)::\(__FUNCTION__) model:\(dynamoModel)")
        let settings                    = dynamoModel as! DynamoSettings
        self.version                    = settings.Version
        self.fundAmount                 = settings.FeeAmount
        self.tipAmount                  = settings.TipAmount
        self.feeAmount                  = settings.FeeAmount
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