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
    let KeychainBitcoinAccount: String = "tips.coinbit.tipper.bitcoinaddress"
    lazy var mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()


    //@NSManaged var twitterUserId: String?
    @NSManaged var twitterAuthToken: String?
    @NSManaged var twitterAuthSecret: String?
    @NSManaged var twitterUsername: String!
    @NSManaged var cognitoIdentity: String?
    @NSManaged var cognitoToken: String?

    //@NSManaged var bitcoinAddress: String?
    @NSManaged var bitcoinBalanceSatoshi: String?
    @NSManaged var bitcoinBalanceMBTC: String?
    @NSManaged var bitcoinBalanceBTC: String?

    @NSManaged var endpointArn: String?
    @NSManaged var deviceToken: String?

    @NSManaged var marketValue: Tipper.Market?

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
                if let _token = SSKeychain.passwordForService(KeychainTokenAccount, account:KeychainAccount) {
                    self.token = _token
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
            SSKeychain.setPassword(newValue, forService: KeychainTokenAccount, account: KeychainAccount)
            NSUbiquitousKeyValueStore.defaultStore().setString(newValue, forKey: KeychainTokenAccount)
        }
    }

    var bitcoinAddress: String? {
        get {
            self.willAccessValueForKey("bitcoinAddress")
            if let _bitcoinAddress = self.primitiveValueForKey("bitcoinAddress") as! String? {
                return _bitcoinAddress
            } else {
                if let _bitcoinAddress = SSKeychain.passwordForService(KeychainBitcoinAccount, account:KeychainAccount) {
                    self.bitcoinAddress = _bitcoinAddress
                    return _bitcoinAddress
                } else if let _bitcoinAddress = NSUbiquitousKeyValueStore.defaultStore().stringForKey(KeychainBitcoinAccount) {
                    self.bitcoinAddress = _bitcoinAddress
                    return _bitcoinAddress
                } else {
                    return nil
                }
            }
        }
        set {
            self.willChangeValueForKey("bitcoinAddress")
            self.setPrimitiveValue(newValue, forKey: "bitcoinAddress")
            self.didChangeValueForKey("bitcoinAddress")
            SSKeychain.setPassword(newValue, forService: KeychainBitcoinAccount, account: KeychainAccount)
            NSUbiquitousKeyValueStore.defaultStore().setString(newValue, forKey: KeychainBitcoinAccount)
        }
    }


    func authenticate(provider: TwitterAuth, completion: (() ->Void))  {
        println("\(className)::\(__FUNCTION__)")
        API.sharedInstance.register(self.twitterUsername, twitterId: self.twitterUserId!, twitterAuth: self.twitterAuthToken!, twitterSecret: self.twitterAuthSecret!, completion: { (json, error) -> Void in
            println("\(json)")
            if (error == nil) {
                self.updateEntityWithJSON(json)
                provider.identityId = self.cognitoIdentity
                provider.token = self.cognitoToken!
                completion()
            }
        })
    }

    func registerForRemoteNotificationsIfNeeded() {
        if deviceToken == nil {
            let types = UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert
            let notificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)

            UIApplication.sharedApplication().registerForRemoteNotifications()
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        }
    }

    func updateCognitoIdentity(provider: TwitterAuth, completion: (() ->Void))  {
        API.sharedInstance.cognito(self.twitterUserId!) { (json, error) -> Void in
            if (error == nil) {
                self.updateEntityWithJSON(json)
                provider.identityId = self.cognitoIdentity
                provider.token = self.cognitoToken!
                completion()
            }

        }
    }

    func twitterAuthenticationWithTKSession(session: TWTRSession) {
        self.twitterAuthToken = session.authToken
        self.twitterAuthSecret = session.authTokenSecret
        self.twitterUserId = session.userID
        self.twitterUsername = session.userName
    }

    var isTwitterAuthenticated: Bool {
        get {
            return self.twitterUserId != nil && self.token != nil && self.bitcoinAddress != nil
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
        println("\(className)::\(__FUNCTION__) json:\(json)")
        self.twitterUserId = json["TwitterUserID"].stringValue
        self.twitterUsername = json["TwitterUsername"].stringValue
        self.bitcoinAddress = json["BitcoinAddress"].string
        self.cognitoIdentity = json["CognityIdentity"].string
        self.cognitoToken = json["CognitoToken"].string
        self.bitcoinBalanceBTC = json["BitcoinBalanceBTC"].stringValue
        self.bitcoinBalanceSatoshi = json["BitcoinBalanceSatoshi"].stringValue
        self.bitcoinBalanceMBTC =  json["BitcoinBalanceMBTC"].stringValue
        self.token = json["token"].stringValue
    }


    func updateBalanceUSD(completion: () ->Void) {
        if let btc = bitcoinBalanceBTC {
            API.sharedInstance.market("\(btc)", completion: { (json, error) -> Void in
                self.marketValue = Market.entityWithJSON(Market.self, json: json, context: self.managedObjectContext!)!
                completion()
            })
        }
    }

    func pushToDynamo() {
        println("\(className)::\(__FUNCTION__)")
        mapper.load(DynamoUser.self, hashKey: self.twitterUserId, rangeKey: nil).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            println("error \(task.error)")
            let dynamoUser: DynamoUser = task.result as! DynamoUser
            self.updateEntityWithDynamoModel(dynamoUser)
            return nil
        })
    }

    func refreshWithDynamo() {
        println("\(className)::\(__FUNCTION__)")
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        mapper.load(DynamoUser.self, hashKey: self.twitterUserId, rangeKey: nil).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            println("error \(task.error)")
            let dynamoUser: DynamoUser = task.result as! DynamoUser
            self.updateEntityWithDynamoModel(dynamoUser)
            return nil
        })
    }

    func updateTwitterAuthentication() {
        println("\(className)::\(__FUNCTION__)")
        let user = DynamoUser.new()
        user.TwitterUserID = twitterUserId
        user.TwitterAuthToken = twitterAuthToken
        user.TwitterAuthSecret = twitterAuthSecret
        user.EndpointArn = endpointArn
        mapper.save(user, configuration: defaultDynamoConfiguration)
    }

    lazy var defaultDynamoConfiguration: AWSDynamoDBObjectMapperConfiguration = {
        let config = AWSDynamoDBObjectMapperConfiguration()
        config.saveBehavior = .UpdateSkipNullAttributes
        return config
    }()

    func updateEntityWithDynamoModel(dynamoModel: DynamoUpdatable) {
        println("\(className)::\(__FUNCTION__) model:\(dynamoModel)")
        let user = dynamoModel as! DynamoUser
        self.twitterUserId = user.TwitterUserID
        self.twitterUsername = user.TwitterUsername
        self.twitterAuthToken = user.TwitterAuthToken
        self.twitterAuthSecret = user.TwitterAuthSecret
        self.bitcoinAddress = user.BitcoinAddress
       // self.bitcoinBalanceBTC  = user.BitcoinBalanceBTC!
        //self.bitcoinBalanceSatoshi = user.BitcoinBalanceSatoshi!
        //self.bitcoinBalanceMBTC = user.BitcoinBalanceMBTC!

        if let endpoint = user.EndpointArn {
             self.endpointArn = endpoint
        }

        if let deviceToken = user.DeviceToken {
            self.deviceToken = deviceToken
        }
    }

}
