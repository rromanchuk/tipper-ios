//
//  DynamoUser.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/9/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
//
//  DynamoPost.swift
//  Today
//
//  Created by Ryan Romanchuk on 3/1/15.
//  Copyright (c) 2015 Frontback. All rights reserved.
//

import Foundation
class DynamoPost : AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var BitCoinAdress: String?
    var TwitterUserId: String?
    var TwitterPhoneNumber: String?
    var TwitterAuthToken: String?
    var TwitterAuthSecret: String?


    static func dynamoDBTableName() -> String! {
        return "TipperUsers"
    }

    static func hashKeyAttribute() -> String! {
        return "TwitterUserId"
    }

//    class func all(context: NSManagedObjectContext) {
//        let scanExpression = AWSDynamoDBScanExpression()
//        scanExpression.limit = 10
//        let dynamoDBObjectMapper: AWSDynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
//        dynamoDBObjectMapper.scan(DynamoPost.self, expression: scanExpression).continueWithBlock { (task: BFTask!) -> AnyObject! in
//            if (task.result != nil) {
//                let pagniatedOutput = task.result as! AWSDynamoDBPaginatedOutput
//                var myResults: Array = pagniatedOutput.items
//                for post in myResults as [AnyObject] {
//                    if let dynamoPost: DynamoPost = post as? DynamoPost {
//                        println("dynaPost is \(dynamoPost)")
//                        Post.entityWithDynamoModel(Post.self, dynamoModel: dynamoPost, context: context)
//                    }
//                }
//                println("myResults\(myResults)")
//            }
//            return nil
//        }
//
//
//    }

    var lookupProperty = "TwitterUserId"
    var dynamoModelLookupValue: String  {
        return self.TwitterUserId!
    }
}