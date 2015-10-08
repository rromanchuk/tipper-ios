//
//  CoreDataUpdatable.swift
//  Today
//
//  Created by Ryan Romanchuk on 2/23/15.
//  Copyright (c) 2015 Frontback. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol CoreDataUpdatable {


    // The CoreData column that should be used for lookup
    static var lookupProperty: String { get }

    // Swift doesn't have very friendly introspection at the moment. NSManagedObject extension needs to ask itself what its entity string is
    //
    // :returns: String The NSManagedObject's entity name
    static var className: String { get }
    func updateEntityWithModel(model: Any)
}

protocol DynamoUpdatable {

    // The CoreData column that should be used for lookup
    static func lookupProperty() -> String
    func lookupProperty() -> String
    func lookupValue() -> String

    // Swift doesn't have very friendly introspection at the moment. NSManagedObject extension needs to ask itself what its entity string is
    //
    // :returns: String The NSManagedObject's entity name
}


protocol AWSModelUpdateable : DynamoUpdatable {
//    static func lookupProperty() -> String
//    func lookupProperty() -> String
//    func lookupValue() -> String
    func asObject() -> AnyObject
}
