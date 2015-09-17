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
    @NSManaged var objectId: String!
    @NSManaged var userId: String!
    @NSManaged var type: String!
    @NSManaged var text: String!
    @NSManaged var createdAt: NSDate!

    static var lookupProperty: String {
        get {
            return "objectId"
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
        self.userId                         = notification.UserID
        self.type                           = notification.NotificationType
        self.text                           = notification.NotificationText
        self.objectId                       = notification.ObjectID

        if let createdAt = notification.CreatedAt?.doubleValue {
            self.createdAt              = NSDate(timeIntervalSince1970: createdAt)
        }

    }

    func updateEntityWithJSON(json: JSON) {

    }

}