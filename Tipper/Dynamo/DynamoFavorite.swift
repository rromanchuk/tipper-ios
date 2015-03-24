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
    var FavoriteID: String?
    var TweetJSON: String?
    var TipperUserID: String?
    var CreatedAt: NSNumber?

   
    static func dynamoDBTableName() -> String! {
        return "TipperTwitterFavorites"
    }

    static func hashKeyAttribute() -> String! {
        return "TweetID"
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

        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let exp = AWSDynamoDBQueryExpression()
        exp.hashKeyValues      = currentUser.uuid
        exp.indexName = "TipperUserID-index"
        exp.limit = 3000

        mapper.query(DynamoFavorite.self, expression: exp, withSecondaryIndexHashKey: "TipperUserID").continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            //println("Result: \(task.result) Error \(task.error)")
            let results = task.result as! AWSDynamoDBPaginatedOutput
            for result in results.items as! [DynamoFavorite] {
                println("result from query \(result)")
                let json = JSON(result)
                context.performBlock({ () -> Void in
                    Favorite.entityWithDYNAMO(Favorite.self, model: result, context: context)
                })
            }
            context.saveMoc()
            return nil
        })
    }

    override func isEqual(anObject: AnyObject?) -> Bool {
        return super.isEqual(anObject)
    }
}