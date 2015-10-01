//
//  DynamoUser.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/15/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

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
import AWSDynamoDB

class DynamoUser: AWSDynamoDBObjectModel, AWSDynamoDBModeling, DynamoUpdatable {
    var UserID: String?
    var TwitterUserID: String?
    var TwitterUsername: String?
    var BitcoinAddress: String?
    var CreatedAt: NSNumber?
    var UpdatedAt: NSNumber?
    var token: String?
    var CognitoIdentity: String?
    var TwitterAuthToken: String?
    var TwitterAuthSecret: String?
    var EndpointArns: NSSet?
    var BitcoinBalanceBTC: NSNumber?
    var Admin: Bool?
    var IsActive: String?
    var ProfileImage: String?
    var AutomaticTippingEnabled: Bool?
    var DeviceTokens: NSSet?

    class func findByTwitterId(twitterId:String, completion: (user:DynamoUser?) -> Void) {
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let exp = AWSDynamoDBQueryExpression()
        exp.hashKeyValues      = twitterId
        exp.indexName = "TwitterUserID-index"
        exp.hashKeyAttribute = "TwitterUserID"

        mapper.query(DynamoUser.self, expression: exp).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            print("DynamoUser::\(__FUNCTION__) error:\(task.error), exception:\(task.exception), taskResult:\(task.result)")
            Debug.isBlocking()
            if (task.error == nil) {
                if let results = task.result as? AWSDynamoDBPaginatedOutput, items = results.items as? [DynamoUser]  {
                    let user = items[0]
                    print("user:\(user)")
                    completion(user: user)
                } else {
                    print("Could not find user!!")
                    completion(user: nil)
                }

            } else {
                completion(user: nil)
            }

            return nil
        })
    }


    static func dynamoDBTableName() -> String! {
        return "TipperUsers"
    }

    static func hashKeyAttribute() -> String! {
        return "UserID"
    }

    func lookupProperty() -> String {
        return DynamoUser.lookupProperty()
    }

    class func lookupProperty() -> String {
        return "UserID"
    }

    func lookupValue() -> String {
        return self.UserID!
    }
    
    override func isEqual(anObject: AnyObject?) -> Bool {
        return super.isEqual(anObject)
    }
}
