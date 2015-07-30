//
//  DynamoFavorite.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/13/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
import TwitterKit
import SwiftyJSON

class DynamoFavorite: AWSDynamoDBObjectModel, AWSDynamoDBModeling, DynamoUpdatable {
    var ObjectID: String?
    var FromUserID: String?
    var ToUserID: String?
    var TweetID: String?
    var ToTwitterID: String?
    var ToTwitterUsername: String?
    var FromTwitterID: String?
    var FromTwitterUsername: String?
    var FromTwitterProfileImage: String?
    var ToTwitterProfileImage: String?
    var Provider: String?
    var TweetJSON: String?
    var CreatedAt: NSNumber?
    var TippedAt: NSNumber?
    var DidLeaveTip: String?
    var txid: String?


    static func dynamoDBTableName() -> String! {
        return "TipperTips"
    }

    static func hashKeyAttribute() -> String! {
        return "ObjectID"
    }

    static func rangeKeyAttribute() -> String! {
        return "FromUserID"
    }

    func lookupProperty() -> String {
        return DynamoFavorite.lookupProperty()
    }

    class func lookupProperty() -> String {
        return "objectId"
    }

    func lookupValue() -> String {
        return self.ObjectID!
    }



    class func updateSentTips(currentUser: CurrentUser, context: NSManagedObjectContext) {
        println("DynamoFavorite::\(__FUNCTION__)")

        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let exp = AWSDynamoDBQueryExpression()

        exp.hashKeyValues      = currentUser.userId!
        //exp.rangeKeyConditions
        exp.indexName = "FromUserID-TippedAt-index"
        self.query(exp, secondaryIndexHash: "FromUserID", context: context)
    }

    class func fetchFromAWS(currentUser: CurrentUser, context: NSManagedObjectContext) {
        println("DynamoFavorite::\(__FUNCTION__)")

        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let exp = AWSDynamoDBQueryExpression()

        exp.hashKeyValues      = currentUser.userId!
        //exp.rangeKeyConditions
        exp.indexName = "FromUserID-index"
        self.query(exp, secondaryIndexHash: "FromUserID", context: context)
    }

    class func updateReceivedTips(currentUser: CurrentUser, context: NSManagedObjectContext) {
        println("DynamoFavorite::\(__FUNCTION__)")

        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let exp = AWSDynamoDBQueryExpression()

        exp.hashKeyValues      = currentUser.userId!
        //exp.rangeKeyConditions
        exp.indexName = "ToUserID-TippedAt-index"
        self.query(exp, secondaryIndexHash: "FromUserID", context: context)
    }


    class func fetchReceivedFromAWS(currentUser: CurrentUser, context: NSManagedObjectContext) {
        println("DynamoFavorite::\(__FUNCTION__)")

        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let exp = AWSDynamoDBQueryExpression()

        exp.hashKeyValues      = currentUser.userId!
        exp.indexName = "ToUserID-index"
        self.query(exp, secondaryIndexHash: "ToUserID", context: context)
    }


    class func fetch(tweetId:String, fromTwitterId:String, context: NSManagedObjectContext, completion: () -> Void) {
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let privateContext = context.privateContext

        mapper .load(DynamoFavorite.self, hashKey: tweetId, rangeKey: fromTwitterId) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            if (task.result != nil) {
                privateContext.performBlock({ () -> Void in
                    let favorite: DynamoFavorite = task.result as! DynamoFavorite
                    Favorite.entityWithDYNAMO(Favorite.self, model: favorite, context: privateContext)
                    privateContext.saveMoc()
                    context.performBlock({ () -> Void in
                        completion()
                    })
                })
            } else {
                completion()
            }

            return nil
        })

    }

    class func query(exp: AWSDynamoDBQueryExpression, secondaryIndexHash: String, context: NSManagedObjectContext) {
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()


        mapper.query(DynamoFavorite.self, expression: exp, withSecondaryIndexHashKey: secondaryIndexHash).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            println("fetchReceivedFromAWS Result: \(task.result) Error \(task.error), Exception: \(task.exception)")
            if task.error == nil {
                let results = task.result as! AWSDynamoDBPaginatedOutput
                let privateContext = context.privateContext
                privateContext.performBlock({ () -> Void in
                    for result in results.items as! [DynamoFavorite] {
                        autoreleasepool({ () -> () in
                            //println("fetchReceivedFromAWS result from query \(result)")
                            Favorite.entityWithDYNAMO(Favorite.self, model: result, context: privateContext)
                            privateContext.saveMoc()
                            context.performBlock({ () -> Void in
                                context.saveMoc()
                                if results.lastEvaluatedKey != nil {
                                    exp.exclusiveStartKey = results.lastEvaluatedKey
                                    self.query(exp, secondaryIndexHash: secondaryIndexHash, context: context)
                                }
                            })
                        })
                    }
                })

            }

            return nil
        })
    }

    override func isEqual(anObject: AnyObject?) -> Bool {
        return super.isEqual(anObject)
    }
}