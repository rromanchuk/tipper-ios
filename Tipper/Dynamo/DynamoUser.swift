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
    var TwitterUserID: String?
    var TwitterUsername: String?
    var BitcoinAddress: String?
    var CreatedAt: NSNumber?
    var token: String?
    var CognityIdentity: String?
    var TwitterAuthToken: String?
    var TwitterAuthSecret: String?
    var EndpointArn: String?
    var DeviceToken: String?
    var BitcoinBalanceSatoshi: NSNumber?
    var BitcoinBalanceMBTC: NSNumber?
    var BitcoinBalanceBTC: NSNumber?

    static func dynamoDBTableName() -> String! {
        return "TipperBitcoinAccounts"
    }

    static func hashKeyAttribute() -> String! {
        return "TwitterUserID"
    }

    func lookupProperty() -> String {
        return DynamoFavorite.lookupProperty()
    }

    class func lookupProperty() -> String {
        return "twitterUserId"
    }

    func lookupValue() -> String {
        return self.TwitterUserID!
    }
    
    override func isEqual(anObject: AnyObject?) -> Bool {
        return super.isEqual(anObject)
    }
}
