//
//  CoreDataUpdatable.swift
//  Today
//
//  Created by Ryan Romanchuk on 2/23/15.
//  Copyright (c) 2015 Frontback. All rights reserved.
//

import Foundation

protocol CoreDataUpdatable {
//    func updateEntityWithRestModel(restModel: Dictionary<String, AnyObject>)
    func updateEntityWithJSON(json: JSON)
//    func updateEntityWithDynamoModel(dynamoModel: AWSDynamoDBObjectModel)

    /// The CoreData column that should be used for lookup
    static var lookupProperty: String { get }
//    static var restModelLookupValue: String { get }

    /// Swift doesn't have very friendly introspection at the moment. NSManagedObject extension needs to ask itself what its entity string is
    ///
    /// :returns: String The NSManagedObject's entity name
    static var className: String { get }
}
//
//protocol DynamoCoreDataUpdatable {
//    /// The CoreData column that should be used for lookup
//    var dynamoModelLookupValue: String { get }
//
//}