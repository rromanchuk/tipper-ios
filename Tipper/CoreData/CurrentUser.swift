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
    let KeychainAccount: String = "tips.coinbit.tipper"
    let KeychainUserAccount: String = "tips.coinbit.tipper.user"
    let KeychainTokenAccount: String = "tips.coinbit.tipper.token"


    //@NSManaged var twitterUserId: String?
    @NSManaged var twitterAuthToken: String?
    @NSManaged var twitterAuthSecret: String?
    @NSManaged var amazonIdentifier: String
    @NSManaged var twitterUsername: String
    @NSManaged var amazonToken: String
    @NSManaged var bitcoinAddress: String?
    @NSManaged var satoshi: NSNumber?
    @NSManaged var phone: String
    //@NSManaged var token: String?
    @NSManaged var endpointArn: String?
    @NSManaged var deviceToken: String?

    class func currentUser(context: NSManagedObjectContext) -> CurrentUser {
        if let _currentUser = CurrentUser.first(CurrentUser.self, context: context) {
            return _currentUser
        } else {
            let _currentUser = CurrentUser.create(CurrentUser.self, context: context)
            _currentUser.writeToDisk()
            return _currentUser
        }
    }

    /// This should not be visible the outside world. We don't want anyone outside this class modifying the uuid
    private var twitterUserId: String? {
        get {
            self.willAccessValueForKey("twitterUserId")
            if let _twitterUserId = self.primitiveValueForKey("twitterUserId") as! String? {
                return _twitterUserId
            } else {
                if let _twitterUserId = SSKeychain.passwordForService(KeychainUserAccount, account:KeychainAccount) {
                    self.twitterUserId = _twitterUserId
                    return _twitterUserId
                } else if let _twitterUserId = NSUbiquitousKeyValueStore.defaultStore().stringForKey(KeychainUserAccount) {
                    self.twitterUserId = _twitterUserId
                    return _twitterUserId
                } else {
                    return nil
                }
            }
        }
        set {
            self.willChangeValueForKey("twitterUserId")
            self.setPrimitiveValue(newValue, forKey: "twitterUserId")
            self.didChangeValueForKey("twitterUserId")
            SSKeychain.setPassword(newValue, forService: KeychainUserAccount, account: KeychainAccount)
            NSUbiquitousKeyValueStore.defaultStore().setString(newValue, forKey: KeychainUserAccount)
        }
    }

    var uuid: String? {
        get {
            return twitterUserId!
        }
    }

    var token: String? {
        get {
            self.willAccessValueForKey("token")
            if let _token = self.primitiveValueForKey("token") as! String? {
                return _token
            } else {
                if let _token = SSKeychain.passwordForService(KeychainUserAccount, account:KeychainTokenAccount) {
                    self.twitterUserId = _token
                    return _token
                } else if let _token = NSUbiquitousKeyValueStore.defaultStore().stringForKey(KeychainTokenAccount) {
                    self.token = _token
                    return _token
                } else {
                    return nil
                }
            }
        }
        set {
            self.willChangeValueForKey("token")
            self.setPrimitiveValue(newValue, forKey: "token")
            self.didChangeValueForKey("token")
            SSKeychain.setPassword(newValue, forService: KeychainUserAccount, account: KeychainTokenAccount)
            NSUbiquitousKeyValueStore.defaultStore().setString(newValue, forKey: KeychainTokenAccount)
        }
    }



    func authenticate(provider: TwitterAuth, completion: (() ->Void))  {
        println("\(className)::\(__FUNCTION__)")
        API.sharedInstance.register(self.twitterUsername, twitterId: self.twitterUserId!, completion: { (json, error) -> Void in
            println("\(json)")
            if (error == nil) {
                self.amazonIdentifier = json["identity_id"].stringValue
                self.amazonToken = json["token"].stringValue
                self.bitcoinAddress = json["bitcoin_address"].stringValue
                self.satoshi = json["bitcoin_balance"]["satoshi"].intValue
                self.token = json["authentication_token"].stringValue
                self.writeToDisk()
                provider.identityId = self.amazonIdentifier
                provider.token = self.amazonToken
                completion()
            }
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
            return self.twitterUserId != nil && self.token != nil
        }
    }


    // MARK: CoreDataUpdatable

    class var className: String {
        return "CurrentUser"
    }

    static var lookupProperty: String {
        get {
            return "twitterUserId"
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
