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
    
    // All favorites, not just tipped
    class func fetchAllFavoritesFromUser(currentUser: CurrentUser, context: NSManagedObjectContext, completion: () -> Void) {
        print("DynamoFavorite::\(__FUNCTION__)")
        currentUser.deepCrawledAt = NSDate()
        let exp = AWSDynamoDBQueryExpression()
        
        exp.hashKeyValues      = currentUser.userId!
        exp.indexName = "FromUserID-index"
        exp.hashKeyAttribute = "FromUserID"
        self.query(exp, context: context) { () -> Void in
            completion()
        }
    }
    
    
    
    class func fetchTips(currentUser: CurrentUser, context: NSManagedObjectContext, completion: () -> Void) {
        fetchSentTips(currentUser, context: context) { () -> Void in
            self.fetchReceivedTips(currentUser, context: context, completion: { () -> Void in
                completion()
            })
        }
    }

    class func fetchSentTips(currentUser: CurrentUser, context: NSManagedObjectContext, completion: () -> Void) {
        print("DynamoFavorite::\(__FUNCTION__)")

        let exp = AWSDynamoDBQueryExpression()

        exp.hashKeyValues      = currentUser.userId!
        exp.indexName = "FromUserID-TippedAt-index"
        exp.hashKeyAttribute = "FromUserID"
        self.query(exp, context: context) { () -> Void in
            completion()
        }

    }

    class func fetchReceivedTips(currentUser: CurrentUser, context: NSManagedObjectContext, completion: () -> Void) {
        print("DynamoFavorite::\(__FUNCTION__)")

        let exp = AWSDynamoDBQueryExpression()

        exp.hashKeyValues      = currentUser.userId!
        exp.indexName = "ToUserID-TippedAt-index"
        exp.hashKeyAttribute = "ToUserID"
        self.query(exp, context: context) { () -> Void in
            completion()
        }
    }

    class func updateTips(currentUser: CurrentUser, context: NSManagedObjectContext, completion: () -> Void) {
        updateReceivedTips(currentUser, context: context) { () -> Void in
            self.updateSentTips(currentUser, context: context, completion: { () -> Void in
                completion()
            })
        }
    }


    class func updateReceivedTips(currentUser: CurrentUser, context: NSManagedObjectContext, completion: () -> Void) {
        print("DynamoFavorite::\(__FUNCTION__)")
        let exp = AWSDynamoDBQueryExpression()

        exp.hashKeyValues      = currentUser.userId!
        exp.indexName = "ToUserID-TippedAt-index"
        exp.hashKeyAttribute = "ToUserID"
        self.query(exp, context: context) { () -> Void in
            completion()
        }
    }

    class func updateSentTips(currentUser: CurrentUser, context: NSManagedObjectContext, completion: () -> Void) {
        print("DynamoFavorite::\(__FUNCTION__)")

        let exp = AWSDynamoDBQueryExpression()

        exp.hashKeyValues      = currentUser.userId!
        exp.indexName = "FromUserID-TippedAt-index"
        exp.hashKeyAttribute = "FromUserID"
        self.query(exp, context: context) { () -> Void in
            completion()
        }

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

    private class func query(exp: AWSDynamoDBQueryExpression, context: NSManagedObjectContext, completion: () -> Void) {
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let privateContext = context.privateContext


        mapper.query(DynamoFavorite.self, expression: exp).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            print("query, value: \(exp.hashKeyValues)  Result: \(task.result) Error \(task.error), Exception: \(task.exception)")
            if let results = task.result as?  AWSDynamoDBPaginatedOutput where task.error == nil && task.exception == nil {
                privateContext.performBlock({ () -> Void in
                    for result in results.items as! [DynamoFavorite] {
                        Favorite.entityWithDYNAMO(Favorite.self, model: result, context: privateContext)
                    }
                    privateContext.saveMoc()
                    context.performBlock({ () -> Void in
                        print("lastEvaluatedKey:\(results.lastEvaluatedKey)")
                        if results.lastEvaluatedKey != nil {
                            exp.exclusiveStartKey = results.lastEvaluatedKey
                            self.query(exp, context: context, completion:completion)
                        } else {
                            context.saveMoc()
                            completion()
                        }
                    })
                })
            } else {
                print("FAILURE!!!!!!")
                completion()
            }

            return nil
        })
    }

    override func isEqual(anObject: AnyObject?) -> Bool {
        return super.isEqual(anObject)
    }
}