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
    var NotificationType: String?
    var NotificationText: String?
    var CreatedAt: NSNumber?


    static func dynamoDBTableName() -> String! {
        return "TipperNotifications"
    }

    static func hashKeyAttribute() -> String! {
        return "UserID"
    }

    static func rangeKeyAttribute() -> String! {
        return "CreatedAt"
    }

    class func fetch(userId:String, context:NSManagedObjectContext, completion: () -> Void) {
        let expression = AWSDynamoDBQueryExpression()
        expression.hashKeyValues = userId
        //expression.indexName = "TipperNotifications"
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
                        Notification.entityWithDYNAMO(Notification.self, model: result, context: privateContext)
                    }
                    privateContext.saveMoc()
                    context.performBlock({ () -> Void in
                        print("lastEvaluatedKey:\(results.lastEvaluatedKey)")
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
        return "userId"
    }

    func lookupValue() -> String {
        return self.UserID!
    }


}