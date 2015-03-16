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
    var FromTwitterUserID: String?
    var ToTwitterUserID: String?
    var FromUsername: String?
    var ToUsername: String?
    var FromBitcoinAddress: String?
    var ToBitcoinAddress: String?
    var FavoriteID: String?
    var CreatedAt: NSNumber?
    var TweetText: String?


   
    static func dynamoDBTableName() -> String! {
        return "TipperFavorites"
    }

    static func hashKeyAttribute() -> String! {
        return "FavoriteID"
    }

    func lookupProperty() -> String {
        return DynamoFavorite.lookupProperty()
    }

    class func lookupProperty() -> String {
        return "favoriteId"
    }

    func lookupValue() -> String {
        return self.FavoriteID!
    }

    class func fetchFromAWS(currentUser: CurrentUser, context: NSManagedObjectContext) {
        println("DynamoFavorite::\(__FUNCTION__)")
        let cond = AWSDynamoDBCondition()
        let v1    = AWSDynamoDBAttributeValue();
        v1.S = currentUser.twitterUserId
        cond.comparisonOperator = AWSDynamoDBComparisonOperator.EQ
        cond.attributeValueList = [ v1 ]
        let c = [ "FromTwitterID" : cond ]

        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()

        let exp = AWSDynamoDBQueryExpression()

        exp.hashKeyValues      = currentUser.twitterUserId
        //exp.hashValue = currentUser.twitterUserId
        //exp.rangeKeyConditions = c
        exp.indexName = "FromTwitterUserID-index"

        mapper.query(DynamoFavorite.self, expression: exp, withSecondaryIndexHashKey: "FromTwitterUserID").continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            println("Result: \(task.result) Error \(task.error)")

            let results = task.result as! AWSDynamoDBPaginatedOutput
            for result in results.items as! [DynamoFavorite] {
                println("result from query \(result)")
                let json = JSON(result)
                context.performBlock({ () -> Void in
                    Favorite.entityWithDYNAMO(Favorite.self, model: result, context: context)
                    return
                })


            }
            context.saveMoc()
            return nil
        })

        //exp.rangeKeyConditions = keyConditions

        //return mapper.query(Item.self, expression: exp)
    }

    class func fetch(currentUser: CurrentUser, context: NSManagedObjectContext) {
        println("DynamoFavorite::\(__FUNCTION__)")
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        API.sharedInstance.favorites { (json, error) -> Void in
            //println("json: \(json) error:\(error)")
            Debug.isBlocking()
            if let array = json.array {
                for favorite in array {
                    let favoriteModel = DynamoFavorite.new()
                    if let user = favorite["user"].dictionary {
                        favoriteModel.FavoriteID = user["id_str"]!.string
                        favoriteModel.ToUsername =  user["screen_name"]!.string
                        favoriteModel.ToTwitterUserID =  user["id_str"]!.string
                    }
                    favoriteModel.FromUsername = currentUser.twitterUsername
                    favoriteModel.FromTwitterUserID = currentUser.twitterUserId
                    favoriteModel.FavoriteID = favorite["id"].stringValue
                    favoriteModel.TweetText = favorite["text"].stringValue
                    favoriteModel.CreatedAt = (Favorite.dateForTwitterDate(favorite["created_at"].stringValue) as NSDate).timeIntervalSince1970

                    mapper.save(favoriteModel).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in

                        println(task.error)
                        println(task.result)
                        context.performBlock({ () -> Void in
                            Favorite.entityWithDYNAMO(Favorite.self, model: favoriteModel, context: context)
                        })


                        return nil
                    })



                }
            }
        }
        
    }

    override func isEqual(anObject: AnyObject?) -> Bool {
        return super.isEqual(anObject)
    }
}