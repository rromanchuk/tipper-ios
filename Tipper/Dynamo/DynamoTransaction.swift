//
//  DynamoTransaction.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 6/14/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation

class DynamoTransaction: AWSDynamoDBObjectModel, AWSDynamoDBModeling, DynamoUpdatable {
    var txid: String?

    var ToTwitterID: String?
    var ToUserID: String?
    var ToTwitterUsername: String?
    var FromTwitterID: String?
    var FromUserID: String?
    var FromTwitterUsername: String?
    var fee: String?
    var amount: String?
    var confirmations: String?

    var time: NSNumber?


    static func dynamoDBTableName() -> String! {
        return "TipperBitcoinTransactions"
    }

    static func hashKeyAttribute() -> String! {
        return "txid"
    }

    func lookupProperty() -> String {
        return DynamoFavorite.lookupProperty()
    }

    class func lookupProperty() -> String {
        return "txid"
    }

    func lookupValue() -> String {
        return self.txid!
    }


}
