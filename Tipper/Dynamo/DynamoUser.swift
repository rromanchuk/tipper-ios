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

class DynamoUser: AWSDynamoDBObjectModel, AWSDynamoDBModeling, DynamoUpdatable {
    var UserID: String?
    var TwitterUserID: String?
    var TwitterUsername: String?
    var BitcoinAddress: String?
    var CreatedAt: NSNumber?
    var token: String?
    var CognitoIdentity: String?
    var TwitterAuthToken: String?
    var TwitterAuthSecret: String?
    var EndpointArn: String?
    var DeviceToken: String?
    var BitcoinBalanceBTC: NSNumber?

    static func dynamoDBTableName() -> String! {
        return "TipperUsers"
    }

    static func hashKeyAttribute() -> String! {
        return "UserID"
    }

    func lookupProperty() -> String {
        return DynamoFavorite.lookupProperty()
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
