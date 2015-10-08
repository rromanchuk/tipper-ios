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

    func updateEntityWithModel(model: Any) {
        if let transaction = model as? TIPPERTransaction {
            log.verbose("Transaction  \(transaction)")
            self.txid = transaction.txid
            self.confirmations = transaction.confirmations
            self.fee = transaction.fee
            self.amount = transaction.tip_amount
            self.fromUserId = transaction.FromUserID
            self.toUserId = transaction.ToUserID
            self.fromTwitterId = transaction.FromTwitterID
            self.toTwitterId = transaction.ToTwitterID
//            self.fromTwitterUsername = transaction.F
//            self.toTwitterUsername = transaction.ToTwitterUsername

            self.time = NSDate(timeIntervalSince1970: NSTimeInterval(transaction.time!.doubleValue))

        }
    }



    
}


//@property (nonatomic, strong) NSString *txid;
//
//
//@property (nonatomic, strong) NSString *relayed_by;
//
//
//@property (nonatomic, strong) NSString *ToBitcoinAddress;
//
//
//@property (nonatomic, strong) NSString *FromBitcoinAddress;
//
//
//@property (nonatomic, strong) NSString *ToTwitterID;
//
//
//@property (nonatomic, strong) NSString *FromTwitterID;
//
//
//@property (nonatomic, strong) NSString *ToUserID;
//
//
//@property (nonatomic, strong) NSString *FromUserID;
//
//
//@property (nonatomic, strong) NSNumber *confirmations;
//
//
//@property (nonatomic, strong) NSNumber *time;
//
//
//@property (nonatomic, strong) NSNumber *size;
//
//
//@property (nonatomic, strong) NSNumber *fee;
//
//
//@property (nonatomic, strong) NSNumber *tip_amount;
//
//
//@property (nonatomic, strong) NSString *category;
