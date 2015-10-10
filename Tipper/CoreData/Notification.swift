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
    @NSManaged var tipId: String?
    @NSManaged var tipFromUserId: String?
    @NSManaged var type: String!
    @NSManaged var text: String!
    @NSManaged var createdAt: NSDate!
    @NSManaged var seenAt: NSDate
    @NSManaged var favorite: Favorite

    static func lookupProperty() -> String {
        return Notification.lookupProperty()
    }

    func lookupProperty() -> String {
        return "objectId"
    }

    func lookupValue() -> String {
        return self.objectId
    }

    class var className: String {
        get {
            return "Notification"
        }
    }

    var className: String {
        return Notification.className
    }


    func updateEntityWithModel(model: Any) {
        log.verbose("\(className)::\(__FUNCTION__) model:\(model)")
        if let notification = model as? DynamoNotification {
            self.userId                         = notification.UserID
            self.type                           = notification.NotificationType
            self.text                           = notification.NotificationText
            self.objectId                       = notification.ObjectID

            if let tipId = notification.TipID, tipFromUserId = notification.TipFromUserID {
                self.tipId = tipId
                self.tipFromUserId = tipFromUserId
            }

            if let objectId = notification.ObjectID, moc = self.managedObjectContext {
                if let favorite = Favorite.entityWithId(Favorite.self, context: moc, lookupProperty: "objectId", lookupValue: objectId) {
                    self.favorite = favorite
                } else {
                    
                }
            }

            if let createdAt = notification.CreatedAt?.doubleValue {
                self.createdAt              = NSDate(timeIntervalSince1970: createdAt)
            }

        }
    }

    func updateEntityWithJSON(json: JSON) {
        fatalError("This method is deprecated")
    }
    
    class func markAllAsRead() {
        let fetchRquest = NSFetchRequest(entityName: "Notification")
        fetchRquest.predicate = NSPredicate(format: "seenAt = null")
        do {
            let results = try (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext.executeFetchRequest(fetchRquest)
            for result in results as! [Notification] {
                result.seenAt = NSDate()
            }
        } catch let error as NSError {
            log.error("\(error)")
        }
    }

    class func unreadCount() -> Int {
        let fetchRquest = NSFetchRequest(entityName: "Notification")
        fetchRquest.predicate = NSPredicate(format: "seenAt = null")
        
        let result = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext.countForFetchRequest(fetchRquest, error: nil)
        return result
        
    }

}