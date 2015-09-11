//
//  Notification.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/10/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Notification: NSManagedObject, CoreDataUpdatable {



    @NSManaged var userId: String!
    @NSManaged var type: String!
    @NSManaged var createdAt: NSDate!

    static var lookupProperty: String {
        get {
            return "userId"
        }
    }

    class var className: String {
        get {
            return "Notification"
        }
    }

    var className: String {
        return Notification.className
    }

    func updateEntityWithDynamoModel(dynamoModel: DynamoUpdatable) {
        print("\(className)::\(__FUNCTION__) model:\(dynamoModel)")
        let notification                    = dynamoModel as! DynamoNotification
        self.userId = notification.UserID
        self.type = notification.Type

        if let createdAt = notification.CreatedAt?.doubleValue {
            self.createdAt              = NSDate(timeIntervalSince1970: createdAt)
        }

    }

    func updateEntityWithJSON(json: JSON) {

    }

}