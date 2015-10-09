//
//  Transaction+Updateable.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 10/7/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation

extension TIPPERSettings: AWSModelUpdateable {
    func lookupProperty() -> String {
        return TIPPERTransaction.lookupProperty()
    }

    class func lookupProperty() -> String {
        return "version"
    }

    func lookupValue() -> String {
        return self.Version
    }

    func asObject() -> AnyObject {
        return self
    }
    
}

extension TIPPERTransaction: AWSModelUpdateable {
    func lookupProperty() -> String {
        return TIPPERTransaction.lookupProperty()
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


extension TIPPERMarket: AWSModelUpdateable {
    func lookupProperty() -> String {
        return TIPPERMarket.lookupProperty()
    }

    class func lookupProperty() -> String {
        return "btc"
    }

    func lookupValue() -> String {
        return self.btc
    }

    func asObject() -> AnyObject {
        return self
    }
    
}