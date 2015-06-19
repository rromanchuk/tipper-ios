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
    let KeychainUserIDAccount: String = "tips.coinbit.tipper.userID"
    lazy var mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()


    @NSManaged var twitterAuthToken: String?
    @NSManaged var twitterAuthSecret: String?
    @NSManaged var twitterUsername: String!
    @NSManaged var cognitoIdentity: String?
    @NSManaged var cognitoToken: String?
    @NSManaged var profileImage: String?

    @NSManaged var bitcoinBalanceBTC: String?

    @NSManaged var endpointArn: String?
    @NSManaged var deviceToken: String?

    @NSManaged var marketValue: Tipper.Market?
    @NSManaged var settings: Tipper.Settings?

    class func currentUser(context: NSManagedObjectContext) -> CurrentUser {
        if let _currentUser = CurrentUser.first(CurrentUser.self, context: context) {
            return _currentUser
        } else {

            let _currentUser = CurrentUser.create(CurrentUser.self, context: context)
            let _settings = NSEntityDescription.insertNewObjectForEntityForName("Settings", inManagedObjectContext: context) as! Settings
            _currentUser.settings = _settings
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

    var userId: String? {
        get {
            self.willAccessValueForKey("userId")
            if let _userId = self.primitiveValueForKey("userId") as! String? {
                return _userId
            } else {
                if let _userId = SSKeychain.passwordForService(KeychainUserIDAccount, account:KeychainAccount) {
                    self.userId = _userId
                    return _userId
                } else if let _userId = NSUbiquitousKeyValueStore.defaultStore().stringForKey(KeychainUserIDAccount) {
                    self.userId = _userId
                    return _userId
                } else {
                    return nil
                }
            }
        }
        set {
            self.willChangeValueForKey("userId")
            self.setPrimitiveValue(newValue, forKey: "userId")
            self.didChangeValueForKey("userId")
            SSKeychain.setPassword(newValue, forService: KeychainUserIDAccount, account: KeychainAccount)
            NSUbiquitousKeyValueStore.defaultStore().setString(newValue, forKey: KeychainUserIDAccount)
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
        API.sharedInstance.register(self.twitterUsername, twitterId: self.twitterUserId!, twitterAuth: self.twitterAuthToken!, twitterSecret: self.twitterAuthSecret!, profileImage: self.profileImage!, completion: { (json, error) -> Void in
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
        //self.profileImage = session.
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
            return "userId"
        }
    }

    var className: String {
        return CurrentUser.className
    }

    var balanceAsUBTC:String {
        get {
            if let btcBalance = self.bitcoinBalanceBTC {
                let balanceFloat = (btcBalance as NSString).floatValue
                let uBTCFloat = balanceFloat / 0.00000100
                return "\(Int(uBTCFloat))"
            } else {
                return "0"
            }
        }
    }

    var mbtc:String {
        get {
            if let btcBalance = self.bitcoinBalanceBTC {
                let balanceFloat = (btcBalance as NSString).floatValue
                let uBTCFloat = balanceFloat / 0.00100000
                return "\(Int(uBTCFloat))"
            } else {
                return "0"
            }

        }
    }

    func updateEntityWithJSON(json: JSON) {
        println("\(className)::\(__FUNCTION__) json:\(json)")
        self.twitterUserId      = json["TwitterUserID"].stringValue
        self.userId             = json["UserID"].stringValue
        self.twitterUsername    = json["TwitterUsername"].stringValue
        self.bitcoinAddress     = json["BitcoinAddress"].string
        self.cognitoIdentity    = json["CognitoIdentity"].string
        self.cognitoToken       = json["CognitoToken"].string

        if let balance = json["BitcoinBalanceBTC"].string {
            self.bitcoinBalanceBTC = balance
        }

        if let token = json["token"].string {
            self.token = token
        }

    }


    func updateBalanceUSD(completion: () ->Void) {
        if let btc = bitcoinBalanceBTC where (btc as NSString).doubleValue > 0.0 {
            API.sharedInstance.market("\(btc)", completion: { (json, error) -> Void in
                if error == nil {
                    self.marketValue = Market.entityWithJSON(Market.self, json: json, context: self.managedObjectContext!)!
                }
                completion()
            })
        } else {
            let json = JSON(["total": ["amount": "0.00"], "subtotal": ["amount": "0.00"], "btc": ["amount": "0.00"]])
            self.marketValue = Market.entityWithJSON(Market.self, json: json, context: self.managedObjectContext!)
            completion()
        }
    }

    func pushToDynamo() {
        println("\(className)::\(__FUNCTION__)")
        if isTwitterAuthenticated {
            let user = DynamoUser.new()
            user.TwitterUserID      = twitterUserId
            user.TwitterAuthToken   = twitterAuthToken
            user.TwitterAuthSecret  = twitterAuthSecret
            user.EndpointArn        = endpointArn
            mapper.save(user, configuration: defaultDynamoConfiguration)
        }
    }

    func withdrawBalance(toAddress: NSString, completion: (error: NSError?) -> Void) {
        println("\(className)::\(__FUNCTION__)")
        completion(error: nil)

        let sqs = AWSSQS.defaultSQS()
        let request = AWSSQSSendMessageRequest()

        var tipDict = ["TwitterUserID": self.uuid!, "ToBitcoinAddress": toAddress, "UserID": userId! ]
        let jsonTipDict = NSJSONSerialization.dataWithJSONObject(tipDict, options: nil, error: nil)
        let json: String = NSString(data: jsonTipDict!, encoding: NSUTF8StringEncoding) as! String


        request.messageBody = json
        request.queueUrl = "***REMOVED***e"
        sqs.sendMessage(request).continueWithBlock { (task) -> AnyObject! in
            if (task.error != nil) {
                println("ERROR: \(task.error)")
                completion(error: task.error)
            } else {
                completion(error: nil)
            }
            return nil
        }
    }

    func refetchFeeds(completion: (error: NSError?) -> Void) {
        println("\(className)::\(__FUNCTION__)")
        completion(error: nil)

        let sqs = AWSSQS.defaultSQS()
        let request = AWSSQSSendMessageRequest()

        var tipDict = ["TwitterUserID": self.uuid!, "UserID": userId! ]
        let jsonTipDict = NSJSONSerialization.dataWithJSONObject(tipDict, options: nil, error: nil)
        let json: String = NSString(data: jsonTipDict!, encoding: NSUTF8StringEncoding) as! String


        request.messageBody = json
        request.queueUrl = "***REMOVED***"
        sqs.sendMessage(request).continueWithBlock { (task) -> AnyObject! in
            if (task.error != nil) {
                println("ERROR: \(task.error)")
                completion(error: task.error)
            } else {
                completion(error: nil)
            }
            return nil
        }

    }


    func refreshWithServer(completion: (error: NSError?) -> Void) {
        API.sharedInstance.me({ (json, error) -> Void in
            if (error == nil) {
                self.updateEntityWithJSON(json)
                self.writeToDisk()
            }
            completion(error: error)
        })
    }

    func refreshWithDynamo() {
        println("\(className)::\(__FUNCTION__)")
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        mapper.load(DynamoUser.self, hashKey: self.userId, rangeKey: nil).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            println("error \(task.error)")
            let dynamoUser: DynamoUser = task.result as! DynamoUser
            self.updateEntityWithDynamoModel(dynamoUser)
            return nil
        })
    }

    lazy var defaultDynamoConfiguration: AWSDynamoDBObjectMapperConfiguration = {
        let config = AWSDynamoDBObjectMapperConfiguration()
        config.saveBehavior = .UpdateSkipNullAttributes
        return config
    }()

    func updateEntityWithDynamoModel(dynamoModel: DynamoUpdatable) {
        println("\(className)::\(__FUNCTION__) model:\(dynamoModel)")
        let user                    = dynamoModel as! DynamoUser
        self.userId                 = user.UserID
        self.twitterUserId          = user.TwitterUserID
        self.twitterUsername        = user.TwitterUsername
        self.twitterAuthToken       = user.TwitterAuthToken
        self.twitterAuthSecret      = user.TwitterAuthSecret
        self.bitcoinAddress         = user.BitcoinAddress


        if let endpoint = user.EndpointArn {
             self.endpointArn = endpoint
        }

        if let deviceToken = user.DeviceToken {
            self.deviceToken = deviceToken
        }
    }

    func resetIdentifiers() {
        println("\(className)::\(__FUNCTION__)")
        SSKeychain.deletePasswordForService(KeychainUserAccount, account: KeychainAccount)
        SSKeychain.deletePasswordForService(KeychainTokenAccount, account: KeychainAccount)
        SSKeychain.deletePasswordForService(KeychainBitcoinAccount, account: KeychainAccount)
        SSKeychain.deletePasswordForService(KeychainUserIDAccount, account: KeychainAccount)

        NSUbiquitousKeyValueStore.defaultStore().removeObjectForKey(KeychainUserAccount)
        NSUbiquitousKeyValueStore.defaultStore().removeObjectForKey(KeychainTokenAccount)
        NSUbiquitousKeyValueStore.defaultStore().removeObjectForKey(KeychainBitcoinAccount)
        NSUbiquitousKeyValueStore.defaultStore().removeObjectForKey(KeychainUserIDAccount)

        NSUbiquitousKeyValueStore.defaultStore().synchronize()
        self.destroy()
        self.writeToDisk()
        Twitter.sharedInstance().logOut()
    }


}
