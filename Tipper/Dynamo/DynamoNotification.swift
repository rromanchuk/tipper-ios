//
//  DynamoNotification.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/10/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
class DynamoNotification: AWSDynamoDBObjectModel, AWSDynamoDBModeling, DynamoUpdatable {
    var UserID: String?
    var ObjectID: String?
    var NotificationType: String?
    var NotificationText: String?
    var CreatedAt: NSNumber?


    static func dynamoDBTableName() -> String! {
        return "TipperNotifications"
    }

    static func hashKeyAttribute() -> String! {
        return "ObjectID"
    }

    class func fetch(userId:String, context:NSManagedObjectContext, completion: () -> Void) {
        let expression = AWSDynamoDBQueryExpression()
        expression.hashKeyValues = userId
        expression.indexName = "UserID-CreatedAt-index"
        expression.hashKeyAttribute = "UserID"
        query(expression, context: context) { () -> Void in
            completion()
        }
    }

    class func query(expression: AWSDynamoDBQueryExpression, context:NSManagedObjectContext, completion: () -> Void) {
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let privateContext = context.privateContext

        mapper.query(DynamoNotification.self, expression: expression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            if let results = task.result as?  AWSDynamoDBPaginatedOutput where task.error == nil && task.exception == nil {
                print("Result: \(task.result) Error \(task.error), Exception: \(task.exception)")
                privateContext.performBlock({ () -> Void in
                    for result in results.items as! [DynamoNotification] {
                        let notification = Notification.entityWithDYNAMO(Notification.self, model: result, context: privateContext)
                        notification!.save()
                        print("New notification entity \(notification)")
                    }
                    privateContext.saveMoc()
                    context.performBlock({ () -> Void in
                        print("lastEvaluatedKey:\(results.lastEvaluatedKey)")
                        context.saveMoc()
                        if results.lastEvaluatedKey != nil {
                            expression.exclusiveStartKey = results.lastEvaluatedKey
                            self.query(expression, context: context, completion:completion)
                        } else {
                            completion()
                        }
                    })
                })
            } else {
                completion()
            }
            return nil
        })
    }

    func lookupProperty() -> String {
        return DynamoNotification.lookupProperty()
    }

    class func lookupProperty() -> String {
        return "objectId"
    }

    func lookupValue() -> String {
        return self.ObjectID!
    }


}