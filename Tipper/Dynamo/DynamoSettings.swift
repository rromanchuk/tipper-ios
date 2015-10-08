//
//  DynamoTransaction.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 6/14/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
import TwitterKit
import SwiftyJSON
import AWSDynamoDB

class DynamoSettings: AWSDynamoDBObjectModel, AWSDynamoDBModeling, ModelCoredataMapable {
    var FundAmount: String?
    var TipAmount: String?
    var FeeAmount: String?
    var Version: String?


    static func dynamoDBTableName() -> String! {
        return "TipperSettings"
    }

    static func hashKeyAttribute() -> String! {
        return "Version"
    }

    func lookupProperty() -> String {
        return DynamoSettings.lookupProperty()
    }

    class func lookupProperty() -> String {
        return "Version"
    }

    func lookupValue() -> String {
        return self.Version!
    }

    override func isEqual(anObject: AnyObject?) -> Bool {
        return super.isEqual(anObject)
    }
    
}
