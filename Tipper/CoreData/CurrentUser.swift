//
//  Tipper.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/10/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
import CoreData

class CurrentUser: NSManagedObject {

    @NSManaged var twitterUserId: String?
    @NSManaged var twitterAuthToken: String?
    @NSManaged var twitterAuthSecret: String?
    @NSManaged var amazonIdentifier: String
    @NSManaged var amazonToken: String
    @NSManaged var bitcoinAddress: String?
    @NSManaged var phone: String

}
