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

    lazy var currencyFormatter: NSNumberFormatter =  {
        var _formatter = NSNumberFormatter()
        _formatter.numberStyle = .CurrencyStyle
        _formatter.currencySymbol = ""
        _formatter.maximumFractionDigits = 0
        return _formatter
    }()

    lazy var mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()


    @NSManaged var twitterUsername: String!
    @NSManaged var profileImage: String?

    @NSManaged var bitcoinBalanceBTC: NSNumber?
    @NSManaged var createdAt: NSDate?
    @NSManaged var updatedAt: NSDate?

    @NSManaged var endpointArn: String?
    @NSManaged var deviceToken: String?
    @NSManaged var cognitoIdentity: String?

    @NSManaged var marketValue: Tipper.Market?
    @NSManaged var admin: NSNumber?
    @NSManaged var lastReceivedEvaluatedKey: NSNumber?
    @NSManaged var automaticTippingEnabled: NSNumber?

    class func currentUser(context: NSManagedObjectContext) -> CurrentUser {
        if let _currentUser = CurrentUser.first(CurrentUser.self, context: context) {
            return _currentUser
        } else {
            let _currentUser = CurrentUser.create(CurrentUser.self, context: context)
            _currentUser.writeToDisk()
            return _currentUser
        }
    }

    var twitterUserId: String? {
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
            return twitterUserId
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


    func authenticate(session: TWTRSession, completion: (() ->Void))  {
        print("\(className)::\(__FUNCTION__)")
        DynamoUser.findByTwitterId( Twitter.sharedInstance().session()!.userID, completion: { (user) -> Void in
            Debug.isBlocking()
            if let dynamoUser = user {
                dynamoUser.TwitterAuthToken = session.authToken
                dynamoUser.TwitterAuthSecret = session.authTokenSecret
                dynamoUser.TwitterUsername = session.userName
                dynamoUser.IsActive = "X"
                dynamoUser.ProfileImage = self.profileImage
                dynamoUser.UpdatedAt = Int(NSDate().timeIntervalSince1970)
                self.updateEntityWithDynamoModel(dynamoUser)
                self.mapper.save(dynamoUser, configuration: self.defaultDynamoConfiguration).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
                    API.sharedInstance.connect({ (json, error) -> Void in
                        completion()
                    })
                    return nil
                })
            } else  {
                let dynamoUser = DynamoUser()
                dynamoUser.UserID = NSUUID().UUIDString
                dynamoUser.TwitterAuthToken = session.authToken
                dynamoUser.TwitterAuthSecret = session.authTokenSecret
                dynamoUser.TwitterUserID = session.userID
                dynamoUser.TwitterUsername = session.userName
                dynamoUser.CreatedAt = Int(NSDate().timeIntervalSince1970)
                dynamoUser.UpdatedAt = Int(NSDate().timeIntervalSince1970)
                dynamoUser.IsActive = "X"
                dynamoUser.ProfileImage = self.profileImage
                dynamoUser.CognitoIdentity = self.cognitoIdentity
                self.mapper.save(dynamoUser, configuration: self.defaultDynamoConfiguration).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
                    API.sharedInstance.address({ (json, error) -> Void in
                        if error == nil {
                            dynamoUser.BitcoinAddress     = json["BitcoinAddress"].string
                            self.bitcoinAddress  = json["BitcoinAddress"].string
                            self.mapper.save(dynamoUser, configuration: self.defaultDynamoConfiguration)
                        }
                        self.updateEntityWithDynamoModel(dynamoUser)
                        API.sharedInstance.connect({ (json, error) -> Void in
                            //print("\(className)::\(__FUNCTION__)")
                            completion()
                        })
                    })
                    return nil
                })
            }
        })

    }

    func registerForRemoteNotificationsIfNeeded() {
        print("\(className)::\(__FUNCTION__)")
        let types: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Sound, UIUserNotificationType.Alert]
        let notificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)

        UIApplication.sharedApplication().registerForRemoteNotifications()
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }


    func twitterAuthenticationWithTKSession(session: TWTRSession) {
        self.twitterUserId = session.userID
        self.twitterUsername = session.userName
    }

    var isTwitterAuthenticated: Bool {
        get {
            return Twitter.sharedInstance().session() != nil && self.twitterUserId != nil && self.bitcoinAddress != nil && self.userId != nil
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
                let uBTCFloat = btcBalance.doubleValue / 0.00000100
                return currencyFormatter.stringFromNumber(NSNumber(double: uBTCFloat))!
                //return "\(Int(uBTCFloat))"
            } else {
                return "0"
            }
        }
    }

    var mbtc:String {
        get {
            if let btcBalance = self.bitcoinBalanceBTC {
                let uBTCFloat = btcBalance.doubleValue / 0.00100000
                return "\(Int(uBTCFloat))"
            } else {
                return "0"
            }

        }
    }

    func updateBTCBalance(completion: ()->Void) {
        print("\(className)::\(__FUNCTION__)")
        API.sharedInstance.balance { (json, error) -> Void in
            if let satoshisString = json["balance"].string, satoshis = Int(satoshisString) {
                self.bitcoinBalanceBTC = Double(satoshis) / 0.00000001
                self.updateBalanceUSD { () -> Void in }
            }
            completion()
        }
    }

    func updateBalanceUSD(completion: () ->Void) {
        if let btc = bitcoinBalanceBTC where btc > 0.0 {
            API.sharedInstance.market("\(btc)", completion: { (json, error) -> Void in
                if let moc = self.managedObjectContext where error == nil {
                    self.marketValue = Market.entityWithJSON(Market.self, json: json, context: moc)!
                }
                completion()
            })
        } else {
            let json = JSON(["total": ["amount": "0.00"], "subtotal": ["amount": "0.00"], "btc": ["amount": "0.00"]])
            if let moc = self.managedObjectContext {
                self.marketValue = Market.entityWithJSON(Market.self, json: json, context: moc)
            }
            completion()
        }
    }

    func pushToDynamo() {
        print("\(className)::\(__FUNCTION__)")
        if isTwitterAuthenticated {
            mapper.load(DynamoUser.self, hashKey: userId, rangeKey: nil).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
                print("\(self.className)::\(__FUNCTION__) error:\(task.error), exception:\(task.exception)")
                if (task.error == nil) {
                    let user:DynamoUser = task.result as! DynamoUser
                    user.EndpointArn        = self.endpointArn
                    user.TwitterUserID      = self.twitterUserId
                    user.TwitterAuthToken   = Twitter.sharedInstance().session()!.authToken
                    user.TwitterAuthSecret  = Twitter.sharedInstance().session()!.authTokenSecret
                    user.BitcoinBalanceBTC  = self.bitcoinBalanceBTC
                    user.CognitoIdentity    = self.cognitoIdentity
                    user.AutomaticTippingEnabled = self.automaticTippingEnabled
                    self.mapper.save(user, configuration: self.defaultDynamoConfiguration).continueWithBlock({ (task) -> AnyObject! in
                        print("\(self.className)::\(__FUNCTION__) error:\(task.error), exception:\(task.exception)")
                        return nil
                    })
                }
                return nil
            })

        }
    }


    func withdrawBalance(toAddress: NSString, completion: (error: NSError?) -> Void) {
        print("\(className)::\(__FUNCTION__)")
        completion(error: nil)

        let sqs = AWSSQS.defaultSQS()
        let request = AWSSQSSendMessageRequest()

        let tipDict = ["TwitterUserID": self.uuid!, "ToBitcoinAddress": toAddress, "UserID": userId! ]
        let jsonTipDict = try? NSJSONSerialization.dataWithJSONObject(tipDict, options: [])
        let json: String = NSString(data: jsonTipDict!, encoding: NSUTF8StringEncoding) as! String


        request.messageBody = json
        request.queueUrl = Config.get("SQS_TRANSFER_OUT")
        sqs.sendMessage(request).continueWithBlock { (task) -> AnyObject! in
            if (task.error != nil) {
                print("ERROR: \(task.error)")
                completion(error: task.error)
            } else {
                completion(error: nil)
            }
            return nil
        }
    }

    func refetchFeeds(completion: (error: NSError?) -> Void) {
        print("\(className)::\(__FUNCTION__)")
        completion(error: nil)

        let sqs = AWSSQS.defaultSQS()
        let request = AWSSQSSendMessageRequest()

        let tipDict = ["TwitterUserID": self.uuid!, "UserID": userId! ]
        let jsonTipDict = try? NSJSONSerialization.dataWithJSONObject(tipDict, options: [])
        let json: String = NSString(data: jsonTipDict!, encoding: NSUTF8StringEncoding) as! String


        request.messageBody = json
        request.queueUrl = Config.get("SQS_FETCH_FAVORITES")
        sqs.sendMessage(request).continueWithBlock { (task) -> AnyObject! in
            if (task.error != nil) {
                print("ERROR: \(task.error)")
                completion(error: task.error)
            } else {
                completion(error: nil)
            }
            return nil
        }

    }


//    func refreshWithServer(completion: (error: NSError?) -> Void) {
//        API.sharedInstance.me({ (json, error) -> Void in
//            if (error == nil) {
//                self.updateEntityWithJSON(json)
//                self.writeToDisk()
//            }
//            completion(error: error)
//        })
//    }

    func refreshWithDynamo(completion: (error: NSError?) -> Void) {
        print("\(className)::\(__FUNCTION__)")
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        mapper.load(DynamoUser.self, hashKey: self.userId, rangeKey: nil).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            print("error \(task.error)")
            
            if let dynamoUser: DynamoUser = task.result as? DynamoUser {
                self.updateEntityWithDynamoModel(dynamoUser)
            }
            
            completion(error: task.error)
            return nil
        })
    }

    lazy var defaultDynamoConfiguration: AWSDynamoDBObjectMapperConfiguration = {
        let config = AWSDynamoDBObjectMapperConfiguration()
        config.saveBehavior = .UpdateSkipNullAttributes
        return config
    }()

    func updateEntityWithDynamoModel(dynamoModel: DynamoUpdatable) {
        print("\(className)::\(__FUNCTION__) model:\(dynamoModel)")
        let user                    = dynamoModel as! DynamoUser
        self.userId                 = user.UserID
        self.twitterUserId          = user.TwitterUserID
        self.twitterUsername        = user.TwitterUsername
        self.bitcoinAddress         = user.BitcoinAddress
        self.admin                  = user.Admin
        self.profileImage           = user.ProfileImage
        self.automaticTippingEnabled = user.AutomaticTippingEnabled

        self.bitcoinBalanceBTC      = user.BitcoinBalanceBTC
        
        if let createdAt = user.CreatedAt?.doubleValue {
            self.createdAt              = NSDate(timeIntervalSince1970: createdAt)
        }
        
        if let updatedAt = user.UpdatedAt?.doubleValue {
            self.updatedAt              = NSDate(timeIntervalSince1970: updatedAt)
        }
        

        if let endpoint = user.EndpointArn {
             self.endpointArn = endpoint
        }

        if let deviceToken = user.DeviceToken {
            self.deviceToken = deviceToken
        }
    }

    func updateEntityWithJSON(json: JSON) {
        print("\(className)::\(__FUNCTION__) json:\(json)")
        self.twitterUserId      = json["TwitterUserID"].stringValue
        self.userId             = json["UserID"].stringValue
        self.twitterUsername    = json["TwitterUsername"].stringValue
        self.bitcoinAddress     = json["BitcoinAddress"].string

        if let admin = json["Admin"].bool {
            self.admin = admin
        }

        if let profileImage = json["ProfileImage"].string {
            self.profileImage = profileImage
        }

        if let balance = json["BitcoinBalanceBTC"].string {
            let balanceAsDouble = (balance as NSString).doubleValue
            self.bitcoinBalanceBTC = balanceAsDouble
        }

        if let token = json["token"].string {
            self.token = token
        }
        
    }

    func turnOffAutoTipping(completion: (error: NSError?) -> Void) {
        print("\(className)::\(__FUNCTION__)")
        API.sharedInstance.disconnect { (json, error) -> Void in
            if error == nil {
                self.automaticTippingEnabled = NSNumber(bool: false)
            }
            completion(error: error)
        }
    }

    func turnOnAutoTipping(completion: (error: NSError?) -> Void) {
        API.sharedInstance.connect { (json, error) -> Void in
            if error == nil {
                self.automaticTippingEnabled = NSNumber(bool: true)
            }
            completion(error: error)
        }
    }

    func resetIdentifiers() {
        print("\(className)::\(__FUNCTION__)")
        (UIApplication.sharedApplication().delegate as! AppDelegate).resetCognitoCredentials()
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
