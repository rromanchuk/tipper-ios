//
//  Transaction+Updateable.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 10/7/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
extension TIPPERTransaction: AWSModelUpdateable {
    func lookupProperty() -> String {
        return DynamoTransaction.lookupProperty()
    }

    class func lookupProperty() -> String {
        return "txid"
    }

    func lookupValue() -> String {
        return self.txid!
    }

    func asObject() -> AnyObject {
        return self 
    }

}