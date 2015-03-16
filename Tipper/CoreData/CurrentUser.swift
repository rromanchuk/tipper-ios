//
//  Tipper.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/10/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
import CoreData
import TwitterKit
import SwiftyJSON

class CurrentUser: NSManagedObject, CoreDataUpdatable {

    @NSManaged var twitterUserId: String?
    @NSManaged var twitterAuthToken: String?
    @NSManaged var twitterAuthSecret: String?
    @NSManaged var amazonIdentifier: String
    @NSManaged var twitterUsername: String
    @NSManaged var amazonToken: String
    @NSManaged var bitcoinAddress: String?
    @NSManaged var satoshi: NSNumber?
    @NSManaged var phone: String

    class func currentUser(context: NSManagedObjectContext) -> CurrentUser {
        if let _currentUser = CurrentUser.first(CurrentUser.self, context: context) {
            return _currentUser
        } else {
            let _currentUser = CurrentUser.create(CurrentUser.self, context: context)
            _currentUser.writeToDisk()
            return _currentUser
        }
    }

    func authenticate(provider: TwitterAuth, completion: (() ->Void))  {
        println("\(className)::\(__FUNCTION__)")
        API.sharedInstance.register(self.twitterUsername, completion: { (json, error) -> Void in
            println("\(json)")
            self.amazonIdentifier = json["identity_id"].stringValue
            self.amazonToken = json["token"].stringValue
            self.bitcoinAddress = json["bitcoin_address"].stringValue
            self.satoshi = json["bitcoin_balance"]["satoshi"].intValue
            self.writeToDisk()
            provider.identityId = self.amazonIdentifier
            provider.token = self.amazonToken
            completion()
        })

    }


    func twitterAuthenticationWithTKSession(session: TWTRSession) {
        self.twitterAuthToken = session.authToken
        self.twitterAuthSecret = session.authTokenSecret
        self.twitterUserId = session.userID
        self.twitterUsername = session.userName
    }


    var isTwitterAuthenticated: Bool {
        get {
            return self.twitterUserId != nil
        }
    }


    // MARK: CoreDataUpdatable

    class var className: String {
        return "CurrentUser"
    }

    static var lookupProperty: String {
        get {
            return "uuid"
        }
    }


    var className: String {
        return CurrentUser.className
    }

    func updateEntityWithJSON(json: JSON) {
        println("\(className)::\(__FUNCTION__)")
    }

    func updateEntityWithDynamoModel(dynamoModel: DynamoUpdatable) {
        println("\(className)::\(__FUNCTION__)")
    }

//    func updateEntityWithDynamoModel(dynamoObject: DynamoUpdatable){
//
//    }


}
