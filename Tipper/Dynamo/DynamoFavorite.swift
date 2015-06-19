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

    class func fetchFromAWS(currentUser: CurrentUser, context: NSManagedObjectContext) {
        println("DynamoFavorite::\(__FUNCTION__)")

        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let exp = AWSDynamoDBQueryExpression()
        exp.hashKeyValues      = currentUser.userId!
        exp.indexName = "FromUserID-index"
        exp.limit = 30

        println("userId: \(currentUser.userId!)")

        mapper.query(DynamoFavorite.self, expression: exp, withSecondaryIndexHashKey: "FromUserID").continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            println("fetchFromAWS Result: \(task.result) Error \(task.error), Exception: \(task.exception)")
            if task.error == nil {
                if let results = task.result as? AWSDynamoDBPaginatedOutput {
                    let privateContext = context.privateContext
                    privateContext.performBlock({ () -> Void in
                        for result in results.items as! [DynamoFavorite] {
                            autoreleasepool({ () -> () in
                                println("fetchFromAWS result from query \(result)")
                                let json = JSON(result)
                                Favorite.entityWithDYNAMO(Favorite.self, model: result, context: privateContext)
                                privateContext.saveMoc()
                            })
                        }
                    })
                }
            }

            return nil
        })
    }

    class func fetch(tweetId:String, fromTwitterId:String, context: NSManagedObjectContext, completion: () -> Void) {
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        mapper.load(DynamoFavorite.self, hashKey: tweetId, rangeKey: fromTwitterId).continueWithBlock { (task) -> AnyObject! in
            if (task.result != nil) {
                let favorite: DynamoFavorite = task.result as! DynamoFavorite
                Favorite.entityWithDYNAMO(Favorite.self, model: favorite, context: context)
                //Do something with the result.
                completion()
            }
            return nil
        }
    }

    class func fetchReceivedFromAWS(currentUser: CurrentUser, context: NSManagedObjectContext) {
        println("DynamoFavorite::\(__FUNCTION__)")

        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let exp = AWSDynamoDBQueryExpression()
        exp.hashKeyValues      = currentUser.userId!
        exp.indexName = "ToUserID-index"
        exp.limit = 30

        mapper.query(DynamoFavorite.self, expression: exp, withSecondaryIndexHashKey: "ToUserID").continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            println("fetchReceivedFromAWS Result: \(task.result) Error \(task.error)")
            if task.error == nil {
                let results = task.result as! AWSDynamoDBPaginatedOutput
                let privateContext = context.privateContext
                privateContext.performBlock({ () -> Void in
                    for result in results.items as! [DynamoFavorite] {
                        autoreleasepool({ () -> () in
                            println("fetchReceivedFromAWS result from query \(result)")
                            Favorite.entityWithDYNAMO(Favorite.self, model: result, context: privateContext)
                            privateContext.saveMoc()
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