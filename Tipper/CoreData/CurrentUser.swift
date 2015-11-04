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
import AWSDynamoDB
import SSKeychain
import AWSSQS
import Crashlytics

class CurrentUser: NSManagedObject, CoreDataUpdatable, ModelCoredataMapable {
    let KeychainAccount: String = "tips.coinbit.tipper"
    let KeychainTwitterIDAccount: String = "tips.coinbit.tipper.twitterID"
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
    @NSManaged var twitterAuthToken: String!
    @NSManaged var twitterAuthSecret: String!
    @NSManaged var profileImage: String?

    @NSManaged var bitcoinBalanceBTC: NSNumber?
    @NSManaged var createdAt: NSDate?
    @NSManaged var updatedAt: NSDate?
    @NSManaged var deepCrawledAt: NSDate?

    @NSManaged var endpointArns: NSSet?
    @NSManaged var cognitoIdentity: String?

    @NSManaged var marketValue: Tipper.Market?
    @NSManaged var admin: NSNumber?
    @NSManaged var lastReceivedEvaluatedKey: NSNumber?
    @NSManaged var automaticTippingEnabled: NSNumber?
    @NSManaged var deviceTokens: NSSet?

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
                if let _twitterUserId = SSKeychain.passwordForService(KeychainTwitterIDAccount, account:KeychainAccount) {
                    self.twitterUserId = _twitterUserId
                    return _twitterUserId
                } else if let _twitterUserId = NSUbiquitousKeyValueStore.defaultStore().stringForKey(KeychainTwitterIDAccount) {
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
            SSKeychain.setPassword(newValue, forService: KeychainTwitterIDAccount, account: KeychainAccount)
            NSUbiquitousKeyValueStore.defaultStore().setString(newValue, forKey: KeychainTwitterIDAccount)
        }
    }

    var uuid: String? {
        get {
            return userId
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


    func authenticate(completion: ((errorMessage: String?) ->Void))  {
        log.verbose("")
        DynamoUser.findByTwitterId(twitterUserId!, completion: { (user) -> Void in
            Debug.isBlocking()
            if let dynamoUser = user {
                self.updateEntityWithModel(dynamoUser)
                self.pushTokens()
                
                Answers.logLoginWithMethod("Twitter",
                    success: true,
                    customAttributes: nil)
                completion(errorMessage: nil)
////                self.mapper.save(dynamoUser, configuration: self.defaultDynamoConfiguration).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
////                    log.verbose("DynamoUser save")
////                    if let _automaticTippingEnabled = self.automaticTippingEnabled where _automaticTippingEnabled.boolValue {
////                        API.sharedInstance.connect({ (json, error) -> Void in
////                            log.verbose("calling completion")
////                            Debug.isBlocking()
////                            completion()
////                        })
////                    } else {
////                        log.verbose("calling completion")
////                       completion()
////                    }
//                
//                    return nil
//                })
            } else  {
                self.register({ (errorMessage) -> Void in
                    Answers.logSignUpWithMethod("Twitter",
                        success: errorMessage == nil,
                        customAttributes: nil)
                    completion(errorMessage: errorMessage)
                })
            }
        })

    }
    
    func register(completion: ((errorMessage: String?) ->Void)) {
        log.verbose("")
        userId = NSUUID().UUIDString
        createdAt = NSDate()
        automaticTippingEnabled = NSNumber(bool: true)
        writeToDisk()
        API.sharedInstance.address({ (json, error) -> Void in
            log.verbose("Setting Address: \(json)")
            if error == nil {
                self.bitcoinAddress     = json["BitcoinAddress"].string
                self.writeToDisk()
                self.pushLocal({ (errorMessage) -> Void in
                    API.sharedInstance.connect({ (json, error) -> Void in
                        
                    })
                    completion(errorMessage: nil)
                })
            } else {
                log.error("\(error)")
            }
        })

    }
    
    
    func pushTokens() {
        let dynamoUser = DynamoUser()
        dynamoUser.UserID = userId
        dynamoUser.TwitterAuthSecret = twitterAuthSecret
        dynamoUser.TwitterAuthToken = twitterAuthToken
        dynamoUser.AutomaticTippingEnabled = automaticTippingEnabled?.boolValue
        
        self.mapper.save(dynamoUser, configuration: self.defaultDynamoConfiguration).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
            if task.error == nil {
            
            } else {
                
            }
            return nil
        })

    }
    
    func pushLocal(completion: ((errorMessage: String?) ->Void)) {
        log.verbose("")
        let dynamoUser = DynamoUser()
        dynamoUser.UserID = userId
        dynamoUser.TwitterAuthSecret = twitterAuthSecret
        dynamoUser.TwitterAuthToken = twitterAuthToken
        dynamoUser.AutomaticTippingEnabled = automaticTippingEnabled?.boolValue
        dynamoUser.BitcoinAddress = bitcoinAddress
        dynamoUser.CognitoIdentity = cognitoIdentity
        
        
        if let createdAt = createdAt {
            dynamoUser.CreatedAt = Int(createdAt.timeIntervalSince1970)
        }
        
        
        if let updatedAt = updatedAt {
            dynamoUser.UpdatedAt = Int(updatedAt.timeIntervalSince1970)
        }
        
        
        self.mapper.save(dynamoUser, configuration: self.defaultDynamoConfiguration).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
            if task.error == nil {
                completion(errorMessage: nil)
            } else {
                completion(errorMessage: "Problem saving local data to dynamo")
            }
            return nil
        })
        
    }

    func registerForRemoteNotificationsIfNeeded() {
        log.verbose("")
        let types: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Sound, UIUserNotificationType.Alert]
        let notificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)

        UIApplication.sharedApplication().registerForRemoteNotifications()
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }


    func twitterAuthenticationWithTKSession(session: TWTRSession) {
        
        self.twitterUserId = session.userID
        self.twitterUsername = session.userName
        self.twitterAuthToken = session.authToken
        self.twitterAuthSecret = session.authTokenSecret
        log.info("currentUser: \(self)")
        self.save()
        writeToDisk()
    }

    var isTwitterAuthenticated: Bool {
        get {
            log.info("twitterUserId: \(self.twitterUserId), bitcoinAddress: \(self.bitcoinAddress), userId: \(userId)")
            // && self.bitcoinAddress != nil
            return self.twitterUserId != nil && self.userId != nil && self.bitcoinAddress != nil && Twitter.sharedInstance().sessionStore.sessionForUserID(twitterUserId!) != nil
        }
    }

    // MARK: CoreDataUpdatable

    class var className: String {
        return "CurrentUser"
    }


    static func lookupProperty() -> String {
        return CurrentUser.lookupProperty()
    }

    func lookupProperty() -> String {
        return "userId"
    }

    func lookupValue() -> String {
        return self.uuid!
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
        log.verbose("")
        TIPPERTipperClient.defaultClient().addressBalanceGet(self.bitcoinAddress!).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            if let _balance = task.result as? TIPPERBalance, satoshisString = _balance.balance, satoshis = Int(satoshisString) {
                log.verbose("_balance: \(_balance), satoshisString: \(satoshisString), satoshis: \(satoshis)")
                self.bitcoinBalanceBTC = Double(satoshis) * 0.00000001
                log.verbose("Saving balance \(self.bitcoinBalanceBTC)")
                self.save()
            }
            completion()
            return nil
        })
    }

    func updateBalanceUSD(completion: () ->Void) {
        log.verbose("")
        if let btc = bitcoinBalanceBTC where btc.doubleValue > 0.0 {
            TIPPERTipperClient.defaultClient().marketGet("\(btc.doubleValue)").continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
                log.verbose("Market fetch \(btc) \(task.result), \(task.error) exception: \(task.exception)")
                if let moc = self.managedObjectContext, _market = task.result as? TIPPERMarket where task.error == nil {
                    if let _marketEntity = Market.entityWithModel(Market.self, model: _market, context: moc) where _market.btc != nil {
                        _marketEntity.save()
                        self.marketValue = _marketEntity
                        self.save()
                    }
                } else {
                    log.warning("[ERROR] Failed to fetch market data \(task.error)")
                }
                completion()
                return nil
            })
            
        } else {
            let market = TIPPERMarket()
            market.amount = "0.00"
            market.btc = "0.00"
            market.subtotalAmount = "0.00"
            if let moc = managedObjectContext {
                self.marketValue = Market.entityWithModel(Market.self, model: market, context: moc)
                self.save()
            }

            completion()
        }
    }

    func pushToDynamo() {
        if isTwitterAuthenticated {
            log.verbose("self:\(self)")
            mapper.load(DynamoUser.self, hashKey: userId, rangeKey: nil).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
                log.verbose("\(self.className)::\(__FUNCTION__) error:\(task.error), exception:\(task.exception)")
                if (task.error == nil) {
                    let user:DynamoUser = task.result as! DynamoUser
                    self.pushToDynamo(user, completion: nil)

                } else {
                    if task.error.code == 10 {
                        NSNotificationCenter.defaultCenter().postNotificationName("UNAUTHORIZED_USER", object: nil)
                    }
                    log.error("error: \(task.error)")
                }
                return nil
            })

        }
    }

    func pushToDynamo(user:DynamoUser, completion: (()->Void)?) {
        user.TwitterUserID              = self.twitterUserId
        user.TwitterAuthToken           = self.twitterAuthToken
        user.TwitterAuthSecret          = self.twitterAuthSecret
        user.BitcoinBalanceBTC          = self.bitcoinBalanceBTC
        user.CognitoIdentity            = self.cognitoIdentity
        user.AutomaticTippingEnabled    = self.automaticTippingEnabled?.boolValue
        user.DeviceTokens               = self.deviceTokens
        user.EndpointArns               = self.endpointArns
        user.IsActive                   = "X"
        user.ProfileImage               = self.profileImage


        if let _bitcoinAddress = self.bitcoinAddress {
            user.BitcoinAddress = _bitcoinAddress
        }
        user.UpdatedAt                  = Int(NSDate().timeIntervalSince1970)


        self.mapper.save(user, configuration: self.defaultDynamoConfiguration).continueWithBlock({ (task) -> AnyObject! in
            log.verbose("\(self.className)::\(__FUNCTION__) error:\(task.error), exception:\(task.exception)")
            completion?()
            return nil
        })
    }

    func withdrawBalance(toAddress: NSString, completion: (error: NSError?) -> Void) {
        log.verbose("")
        completion(error: nil)

        let sqs = AWSSQS.defaultSQS()
        let request = AWSSQSSendMessageRequest()

        let tipDict = ["TwitterUserID": self.twitterUserId!, "ToBitcoinAddress": toAddress, "UserID": userId! ]
        let jsonTipDict = try? NSJSONSerialization.dataWithJSONObject(tipDict, options: [])
        let json: String = NSString(data: jsonTipDict!, encoding: NSUTF8StringEncoding) as! String


        request.messageBody = json
        request.queueUrl = Config.get("SQS_TRANSFER_OUT")
        sqs.sendMessage(request).continueWithBlock { (task) -> AnyObject! in
            if (task.error != nil) {
                log.error("ERROR: \(task.error)")
                completion(error: task.error)
            } else {
                completion(error: nil)
            }
            return nil
        }
    }

    func refreshWithDynamo(completion: (error: NSError?) -> Void) {
        log.verbose("")
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let task = mapper.load(DynamoUser.self, hashKey: self.userId!, rangeKey: nil, configuration: self.defaultDynamoConfiguration)
        log.verbose("taskResult: \(task.result)")
        if let currentUser = task.result as? DynamoUser {
            updateEntityWithModel(currentUser)
            save()
        } else {
            log.error("\(task.error), \(task.exception)")
        }
        completion(error: task.error)
    }

    lazy var defaultDynamoConfiguration: AWSDynamoDBObjectMapperConfiguration = {
        let config = AWSDynamoDBObjectMapperConfiguration()
        config.saveBehavior = .UpdateSkipNullAttributes
        return config
    }()


    func turnOffAutoTipping(completion: (error: NSError?) -> Void) {
        log.verbose("")
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
        log.verbose("")
        Twitter.sharedInstance().sessionStore.logOutUserID(twitterUserId!)
        (UIApplication.sharedApplication().delegate as! AppDelegate).resetCognitoCredentials()
        SSKeychain.deletePasswordForService(KeychainTwitterIDAccount, account: KeychainAccount)
        SSKeychain.deletePasswordForService(KeychainTokenAccount, account: KeychainAccount)
        SSKeychain.deletePasswordForService(KeychainBitcoinAccount, account: KeychainAccount)
        SSKeychain.deletePasswordForService(KeychainUserIDAccount, account: KeychainAccount)

        NSUbiquitousKeyValueStore.defaultStore().removeObjectForKey(KeychainTwitterIDAccount)
        NSUbiquitousKeyValueStore.defaultStore().removeObjectForKey(KeychainTokenAccount)
        NSUbiquitousKeyValueStore.defaultStore().removeObjectForKey(KeychainBitcoinAccount)
        NSUbiquitousKeyValueStore.defaultStore().removeObjectForKey(KeychainUserIDAccount)
        NSUbiquitousKeyValueStore.defaultStore().synchronize()
        self.destroy()
        self.writeToDisk()

    }

    func updateEntityWithModel(model: Any) {
        
        if let user = model as? DynamoUser {
            log.verbose("DynamoUser: \(user)")
            self.userId                 = user.UserID
            self.twitterUserId          = user.TwitterUserID
            self.twitterUsername        = user.TwitterUsername
            self.bitcoinAddress         = user.BitcoinAddress
            self.profileImage           = user.ProfileImage


            if let _admin = user.Admin {
                self.automaticTippingEnabled = NSNumber(bool: _admin)
            } else {
                self.automaticTippingEnabled = NSNumber(bool: false)
            }

            if let _automaticTippingEnabled = user.AutomaticTippingEnabled {
                self.automaticTippingEnabled = NSNumber(bool: _automaticTippingEnabled)
            } else {
                self.automaticTippingEnabled = NSNumber(bool: true)
            }


            self.bitcoinBalanceBTC      = user.BitcoinBalanceBTC

            if let createdAt = user.CreatedAt?.doubleValue {
                self.createdAt              = NSDate(timeIntervalSince1970: createdAt)
            }

            if let updatedAt = user.UpdatedAt?.doubleValue {
                self.updatedAt              = NSDate(timeIntervalSince1970: updatedAt)
            }

            if let _deviceTokens = user.DeviceTokens {
                self.deviceTokens = _deviceTokens
            }
            
            if let _endpointArns = user.EndpointArns {
                self.endpointArns = _endpointArns
            }

        }
    }


}
