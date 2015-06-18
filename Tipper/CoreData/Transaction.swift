//
//  Transaction.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 6/14/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Transaction: NSManagedObject, CoreDataUpdatable {


    @NSManaged var txid: String?
    @NSManaged var amount: String?
    @NSManaged var fee: String?
    @NSManaged var confirmations: String?

    @NSManaged var fromTwitterId: String?
    @NSManaged var toTwitterId: String?
    @NSManaged var fromTwitterUsername: String?
    @NSManaged var toTwitterUsername: String?
    @NSManaged var toUserId: String?
    @NSManaged var fromUserId: String?

    @NSManaged var time: NSDate


    class var className: String {
        get {
            return "Transaction"
        }
    }

    var className: String {
        return Favorite.className
    }

    static var lookupProperty: String {
        get {
            return "txid"
        }
    }

    var lookupValue: String {
        get {
            return self.txid!
        }
    }

    func updateEntityWithJSON(json: JSON) {

    }

    func updateEntityWithDynamoModel(dynamoObject: DynamoUpdatable) {
        if let transaction = dynamoObject as? DynamoTransaction {
            txid = transaction.txid
            amount = transaction.amount
            fee = transaction.fee
            confirmations = transaction.confirmations

            fromTwitterId = transaction.FromTwitterID
            toTwitterId = transaction.ToTwitterID

            fromUserId = transaction.FromUserID
            toUserId = transaction.ToUserID


            fromTwitterUsername = transaction.FromTwitterUsername
            toTwitterUsername = transaction.ToTwitterUsername

            time = NSDate(timeIntervalSince1970: NSTimeInterval(transaction.time!.doubleValue))
        }
    }

    class func fetch(txid: String, context: NSManagedObjectContext, completion: (transaction:Transaction) -> Void) {
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        mapper.load(DynamoTransaction.self, hashKey: txid, rangeKey: nil).continueWithBlock { (task) -> AnyObject! in
            if let dynamoTransaction = task.result as? DynamoTransaction {
                let transaction = Transaction.entityWithDYNAMO(Transaction.self, model: dynamoTransaction, context: context)
                completion(transaction: transaction!)
            }
            return nil
        }
    }

}