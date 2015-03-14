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

class CurrentUser: NSManagedObject, CoreDataUpdatable {

    @NSManaged var twitterUserId: String?
    @NSManaged var twitterAuthToken: String?
    @NSManaged var twitterAuthSecret: String?
    @NSManaged var amazonIdentifier: String
    @NSManaged var twitterUsername: String
    @NSManaged var amazonToken: String
    @NSManaged var bitcoinAddress: String?
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
        API.sharedInstance.register(self.twitterUserId!, completion: { (json, error) -> Void in
            println("\(json)")
            self.amazonIdentifier = json["identity_id"].string!
            self.amazonToken = json["token"].string!
            self.writeToDisk()
            provider.identityId = self.amazonIdentifier
            provider.token = self.amazonToken
            completion()
        })

    }

    func twitterAuthentication() {
        println("\(className)::\(__FUNCTION__)")
        Digits.sharedInstance().authenticateWithCompletion { (session, error) -> Void in
            println("DigitsCallback")
            self.twitterAuthToken = session.authToken
            self.twitterAuthSecret = session.authTokenSecret
            self.phone = session.phoneNumber
            self.twitterUserId = session.userID
        }
    }

    func twitterAuthenticationWithSession(session: DGTSession) {
        println("DigitsCallback")
        self.twitterAuthToken = session.authToken
        self.twitterAuthSecret = session.authTokenSecret
        self.phone = session.phoneNumber

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
