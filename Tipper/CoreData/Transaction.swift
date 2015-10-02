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


    @NSManaged var txid: String!
    @NSManaged var amount: NSNumber?
    @NSManaged var category: String?
    @NSManaged var fee: NSNumber?
    @NSManaged var confirmations: NSNumber?

    @NSManaged var fromTwitterId: String?
    @NSManaged var toTwitterId: String?
    @NSManaged var fromTwitterUsername: String?
    @NSManaged var toTwitterUsername: String?
    @NSManaged var toUserId: String?
    @NSManaged var fromUserId: String?

    @NSManaged var time: NSDate

    class func get(txid: String) {

        TIPPERTipperClient.defaultClient().transactionGet(txid).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            log.verbose("Transaction fetch \(task.result), \(task.error) exception: \(task.exception)")
            if let transaction = task.result as? TIPPERTransaction {
                log.verbose("Transaction  \(transaction)")
            }

            return nil;
        })
    }


    class var className: String {
        get {
            return "Transaction"
        }
    }

    var className: String {
        return Transaction.className
    }

    static var lookupProperty: String {
        get {
            return "txid"
        }
    }

    var lookupValue: String {
        get {
            return self.txid
        }
    }

    func updateEntityWithJSON(json: JSON) {
        log.verbose("")
    }

    func updateEntityWithDynamoModel(dynamoObject: DynamoUpdatable) {
        log.verbose("")
        if let transaction = dynamoObject as? DynamoTransaction {
            self.txid = transaction.txid
            self.amount = transaction.amount
            self.fee = transaction.fee
            self.confirmations = transaction.confirmations

            self.fromTwitterId = transaction.FromTwitterID
            self.toTwitterId = transaction.ToTwitterID

            self.fromUserId = transaction.FromUserID
            self.toUserId = transaction.ToUserID


            self.fromTwitterUsername = transaction.FromTwitterUsername
            self.toTwitterUsername = transaction.ToTwitterUsername

            self.time = NSDate(timeIntervalSince1970: NSTimeInterval(transaction.time!.doubleValue))
        }
    }

    
}