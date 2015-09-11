//
//  DynamoNotification.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/10/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
class DynamoNotification: AWSDynamoDBObjectModel, AWSDynamoDBModeling, DynamoUpdatable {
    var UserID: String?
    var Type: String?
    var CreatedAt: NSNumber?


    static func dynamoDBTableName() -> String! {
        return "TipperNotifications"
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


}