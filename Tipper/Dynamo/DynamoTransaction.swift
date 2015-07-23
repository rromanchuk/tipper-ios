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

class DynamoTransaction: AWSDynamoDBObjectModel, AWSDynamoDBModeling, DynamoUpdatable {
    var amount: NSNumber?
    var category: String?
    var confirmations: NSNumber?
    var details: String?
    var fee: NSNumber?
    var FromBitcoinAddress: String?
    var FromTwitterID: String?
    var FromTwitterUsername: String?
    var FromUserID: String?

    var tip_amount: NSNumber?
    var ToBitcoinAddress: String?
    var ToUserID: String?
    var ToTwitterUsername: String?
    var ToTwitterID: String?

    var txid: String?


    var time: NSNumber?


    static func dynamoDBTableName() -> String! {
        return "TipperBitcoinTransactions"
    }

    static func hashKeyAttribute() -> String! {
        return "txid"
    }

    func lookupProperty() -> String {
        return DynamoTransaction.lookupProperty()
    }

    class func lookupProperty() -> String {
        return "txid"
    }

    func lookupValue() -> String {
        return self.txid!
    }

    override func isEqual(anObject: AnyObject?) -> Bool {
        return super.isEqual(anObject)
    }

    class func fetch(txid: String, context: NSManagedObjectContext, completion: (transaction: Transaction?) -> Void) {
        println("DynamoTransaction::\(__FUNCTION__) txid: \(txid), context:\(context)")
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        mapper.load(DynamoTransaction.self, hashKey: txid, rangeKey: nil).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            println("error \(task.error)")
            var transaction: Transaction?
            if task.error == nil {
                let dynamoTransaction = task.result as! DynamoTransaction
                transaction = Transaction.entityWithDYNAMO(Transaction.self, model: dynamoTransaction, context: context)
            }
            completion(transaction: transaction)
            return nil
        })

    }

}
