//
//  CurrentUser+Extension.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/8/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
import CoreLocation
import TwitterKit

extension CurrentUser: CoreDataUpdatable {
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
        self.twitterUserId = session.userID
    }

    func twitterAuthenticationWithTKSession(session: TWTRSession) {
        println("DigitsCallback")
        self.twitterAuthToken = session.authToken
        self.twitterAuthSecret = session.authTokenSecret
        //self.phone = session.phoneNumber
        self.twitterUserId = session.userID
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

    var className: String {
        return CurrentUser.className
    }

    func updateEntityWithJSON(json: JSON) {

    }

    class var lookupProperty: String {
        return "uuid"
    }
}