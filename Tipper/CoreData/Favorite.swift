//
//  Tipper.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/10/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
import CoreData



class Favorite: NSManagedObject {

    @NSManaged var favoriteId: String
    @NSManaged var fromUsername: String
    @NSManaged var toUsername: String
    @NSManaged var toTwitterId: String
    @NSManaged var fromTwitterId: String
    @NSManaged var fromBitcoinAddress: String?
    @NSManaged var toBitcoinAddress: String?
    @NSManaged var tweetText: String?
    @NSManaged var createdAt: NSDate


}