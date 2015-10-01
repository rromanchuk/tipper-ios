//
//  AppDelegate.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/4/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics
import TwitterKit
import SwiftyJSON
import Stripe

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let className = "AppDelegate"
    var currentUser: CurrentUser!
    var provider: AWSCognitoCredentialsProvider!
    var market: Market!
    weak var notificationsDelegate: NotificationMessagesDelegate?

    private var _privateWriterContext: NSManagedObjectContext?
    private var _managedObjectContext: NSManagedObjectContext?
    private var _persistentStoreCoordinator: NSPersistentStoreCoordinator?
    private var _managedObjectModel: NSManagedObjectModel?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        print("\(className)::\(__FUNCTION__)")
        Fabric.with([Crashlytics(), Twitter()])
        Config.dump()
        AWSLogger.defaultLogger().logLevel = .Error
        let _ = AWSMobileAnalytics(forAppId: Config.get("AWS_ANALYTICS_ID"))
        
        // Configure tracker from GoogleService-Info.plist.
//        var configureError:NSError?
//        GGLContext.sharedInstance().configureWithError(&configureError)
//        assert(configureError == nil, "Error configuring Google services: \(configureError)")


        NSUbiquitousKeyValueStore.defaultStore().synchronize()
        

        Stripe.setDefaultPublishableKey(Config.get("STRIPE_PUBLISHABLE"))
        setupFirstController()


        print("\(className)::\(__FUNCTION__) currentUser:\([currentUser])")

        

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "UNAUTHORIZED_USER", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cognitoIdentityDidChange:", name: AWSCognitoIdentityIdChangedNotification, object: nil)

        return true
    }

    func setupFirstController() {
        currentUser = CurrentUser.currentUser(managedObjectContext)

        print("\(className)::\(__FUNCTION__) currentUser:\([currentUser])")


        provider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: Config.get("COGNITO_POOL"))
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: provider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration

        TIPPERTipperClient.defaultClient().APIKey = Config.get("AWS_API_GATEWAY_KEY")
        
        market = NSEntityDescription.insertNewObjectForEntityForName("Market", inManagedObjectContext: managedObjectContext) as! Market
        market.save()

        let firstController = window?.rootViewController as! OnboardingViewController
        firstController.currentUser = CurrentUser.currentUser(managedObjectContext)
        firstController.provider = provider
        firstController.managedObjectContext = managedObjectContext
        firstController.market = market


    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
         print("\(className)::\(__FUNCTION__)")
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("\(className)::\(__FUNCTION__)")
        writeToDisk()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        print("\(className)::\(__FUNCTION__)")
        //UIApplication.sharedApplication().applicationIconBadgeNumber = 0

    }

    func setApplicationBadgeNumber(number: UInt) {
        print("\(className)::\(__FUNCTION__)")
        UIApplication.sharedApplication().applicationIconBadgeNumber = Int(number)
    }

    func incrementApplicationtBadgeNumber() {
        print("\(className)::\(__FUNCTION__) current badge count is \(UIApplication.sharedApplication().applicationIconBadgeNumber)")
        
        let num = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        setApplicationBadgeNumber(UInt(num))
    }


    func applicationDidBecomeActive(application: UIApplication) {
        print("\(className)::\(__FUNCTION__)")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        refresh()
        //incrementApplicationtBadgeNumber()
    }

    func refresh() {
        print("\(className)::\(__FUNCTION__) balance: \(currentUser.balanceAsUBTC)")
        
        
        if currentUser.isTwitterAuthenticated {
            DynamoNotification.refresh(currentUser.userId!)
            provider.logins = ["api.twitter.com": "\(Twitter.sharedInstance().sessionStore.session()!.authToken);\(Twitter.sharedInstance().sessionStore.session()!.authTokenSecret)"]
            currentUser.refreshWithDynamo { [weak self] (error) -> Void in
                self?.currentUser.updateBTCBalance({ () -> Void in
                    self?.provider.getIdentityId().continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
                        if task.error == nil, let identity = task.result as? String {
                            print("\(self?.className)::\(__FUNCTION__) Just fetched cognito identity and is \(identity)")
                            self?.currentUser.cognitoIdentity = identity
                        }
                        self?.currentUser?.pushToDynamo()
                        return nil
                    })
                })
                self?.currentUser.registerForRemoteNotificationsIfNeeded()
            }
        }
        
        Settings.get()
        market.update { () -> Void in }
    }


    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        writeToDisk()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("\(className)::\(__FUNCTION__)")
        NSNotificationCenter.defaultCenter().postNotificationName("didFailToRegisterForRemoteNotificationsWithError", object: nil)
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("\(className)::\(__FUNCTION__)")
        NSNotificationCenter.defaultCenter().postNotificationName("didRegisterForRemoteNotificationsWithDeviceToken", object: nil)
        
        let deviceTokenString = "\(deviceToken)"
            .stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString:"<>"))
            .stringByReplacingOccurrencesOfString(" ", withString: "")
        print("deviceTokenString: \(deviceTokenString)")
        
        
        let deviceTokenSet = NSMutableSet(objects: deviceTokenString)
        if let deviceTokens = currentUser!.deviceTokens?.allObjects {
            print("currentUser!.deviceTokens?: \(deviceTokens)")
            deviceTokenSet.addObjectsFromArray(deviceTokens)
        }
        print("deviceTokenSet: \(deviceTokenSet)")
        currentUser?.deviceTokens = deviceTokenSet
        
        registerTokens(currentUser.deviceTokens!.allObjects)
    }
    
    
    func registerTokens(tokens: NSArray) {
        print("\(className)::\(__FUNCTION__) tokens:\(tokens)")
        let sns = AWSSNS.defaultSNS()
        let request = AWSSNSCreatePlatformEndpointInput()
        request.platformApplicationArn = Config.get("SNS_ENDPOINT")
        
        for token in tokens {
            request.token = token as! String 
            sns.createPlatformEndpoint(request).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
                if task.error != nil {
                    print("Error: \(task.error)")
                } else {
                    let createEndpointResponse = task.result as! AWSSNSCreateEndpointResponse
                    print("endpointArn: \(createEndpointResponse.endpointArn)")
                    let endpointArnSet = NSMutableSet(objects: createEndpointResponse.endpointArn)
                    if let endPoints = self.currentUser.endpointArns?.allObjects {
                        endpointArnSet.addObjectsFromArray(endPoints)
                    }
                    self.currentUser?.endpointArns = endpointArnSet
                    self.currentUser?.pushToDynamo()
                    self.gerneralSubscriptionChannel(task)
                    print("admin? \(self.currentUser?.admin)")
                    if let admin = self.currentUser?.admin where admin.boolValue {
                        self.adminSubscriptionChannel(task)
                    }
                    
                }
                
                return nil
            })

        }
    }

    func gerneralSubscriptionChannel(task: AWSTask!) {
        print("\(className)::\(__FUNCTION__)")
        let sns = AWSSNS.defaultSNS()

        let createEndpointResponse = task.result as! AWSSNSCreateEndpointResponse
        print("endpointArn: \(createEndpointResponse.endpointArn)")
        let request = AWSSNSSubscribeInput()
        request.endpoint = createEndpointResponse.endpointArn
        request.protocols = "application"
        request.topicArn = Config.get("AWS_GENERAL_SNS")
        sns.subscribe(request).continueWithBlock({ (task) -> AnyObject! in
            print("\(task.result) \(task.error)")
            return nil
        })
        
    }


    func adminSubscriptionChannel(task: AWSTask!) {
        print("\(className)::\(__FUNCTION__)")
        let sns = AWSSNS.defaultSNS()
        let createEndpointResponse = task.result as! AWSSNSCreateEndpointResponse
        print("endpointArn: \(createEndpointResponse.endpointArn)")

        let request = AWSSNSSubscribeInput()
        request.endpoint = createEndpointResponse.endpointArn
        request.protocols = "application"
        request.topicArn = Config.get("AWS_ADMIN_SNS")
        sns.subscribe(request).continueWithBlock({ (task) -> AnyObject! in
            print("\(task.result) \(task.error)")
            return nil
        })

    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject: AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

        print("\(className)::\(__FUNCTION__) userInfo:\(userInfo)")
        var messageJSON: JSON?

        if let message = userInfo["message"] as? [String: AnyObject]  {
            if application.applicationState == .Active {
                messageJSON = JSON(message)

            } else {
                incrementApplicationtBadgeNumber()
            }
        }

        if let favorite = userInfo["favorite"] as? [String: AnyObject],
            user = userInfo["user"] as? [String: AnyObject],
            currentUser = currentUser {
                let favoriteJSON = JSON(favorite)
                let userJSON = JSON(user)

                if let tweetId = favoriteJSON["TweetID"].string,
                    fromTwitterId = favoriteJSON["FromTwitterID"].string,
                    bitcoinBalance = userJSON["BitcoinBalanceBTC"].number {
                        currentUser.bitcoinBalanceBTC = bitcoinBalance
                        DynamoFavorite.fetch(tweetId, fromTwitterId: fromTwitterId, context: managedObjectContext, completion: { () -> Void in
                            completionHandler(.NewData)
                        })
                        processMessage(messageJSON)
                } else {
                    completionHandler(.NoData)
                }
        } else if let user = userInfo["user"] as? [String: AnyObject]  {
            let userJSON = JSON(user)
            if let bitcoinBalance = userJSON["BitcoinBalanceBTC"].number {
                currentUser.bitcoinBalanceBTC = bitcoinBalance
                processMessage(messageJSON)
            }

        } else {
            processMessage(messageJSON)
            completionHandler(.NoData)
        }
    }

    private var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid

    func registerBackgroundTask() {
        backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
            [unowned self] in
            self.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }

    func endBackgroundTask() {
        if self.backgroundTask != UIBackgroundTaskInvalid {
            UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
            backgroundTask = UIBackgroundTaskInvalid
        }
    }
    
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]?) -> Void)) {
        print("\(className)::\(__FUNCTION__) userInfo:\(userInfo)")
        registerBackgroundTask()
        if currentUser != nil && currentUser.isTwitterAuthenticated {
            reply(["balance": currentUser.balanceAsUBTC])
        } else {
           reply(["balance": "0"])
        }
        //
        
        endBackgroundTask()
    }

//    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
//        println("\(className)::\(__FUNCTION__)")
//        registerBackgroundTask()
//        reply(["balance": self.currentUser.balanceAsUBTC])
//        endBackgroundTask()
//
////        // 1
////        if let userInfo = userInfo, request = userInfo["request"] as? String where currentUser.isTwitterAuthenticated {
////            if request == "balance" {
////                // 2
////                currentUser.refreshWithDynamo({ (error) -> Void in
////                    Debug.isBlocking()
////                    if error == nil{
////                        reply(["balance": self.currentUser.balanceAsUBTC])
////                        if self.backgroundTask != UIBackgroundTaskInvalid {
////                            self.endBackgroundTask()
////                        }
////                    } else {
////                        reply([:])
////                        if self.backgroundTask != UIBackgroundTaskInvalid {
////                            self.endBackgroundTask()
////                        }
////                    }
////                })
////                // 3
////                return
////            }
////            reply([:])
////        }
////        
////        // 4
////        reply([:])
//    }

    func processMessage(message:JSON?) {
        print("\(className)::\(__FUNCTION__)")
        if let message = message {
            let title = message["title"].stringValue
            let subtitle = message["subtitle"].stringValue
            let type = message["type"].stringValue

            switch (type) {
            case "error":
                notificationsDelegate?.didReceiveNotificationAlert(title, subtitle:subtitle, type: .Error)
            case "success":
                notificationsDelegate?.didReceiveNotificationAlert(title, subtitle:subtitle, type: .Success)
            default:
                break;
            }
        }
    }

    // MARK: - Core Data stack

    func logout() {
        print("\(className)::\(__FUNCTION__)")
        currentUser.resetIdentifiers()
        resetCoreData()
        NSNotificationCenter.defaultCenter().postNotificationName("BACK_TO_SPLASH", object: nil)
    }

    func resetCognitoCredentials() {
        print("\(className)::\(__FUNCTION__)")
        self.provider.clearKeychain()
    }
    
    func cognitoIdentityDidChange(notficiation: NSNotification) {
        print("\(className)::\(__FUNCTION__)")
        
        if let userInfo = notficiation.userInfo, identifier = userInfo[AWSCognitoNotificationNewId] as? String {
            print("\(className)::\(__FUNCTION__) New cognito identifier: \(identifier)")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.currentUser.cognitoIdentity = identifier
                self.currentUser.pushToDynamo()
            })
        }
    }

    func resetCoreData() {
        print("\(className)::\(__FUNCTION__) ****************************")
        let storeURL = applicationDocumentsDirectory.URLByAppendingPathComponent("Tipper.sqlite")
        do {
            try NSFileManager.defaultManager().removeItemAtURL(storeURL)
        } catch _ {
        }
        _persistentStoreCoordinator = nil
        _managedObjectContext = nil
        _privateWriterContext = nil
        _managedObjectModel = nil
        setupFirstController()
        NSNotificationCenter.defaultCenter().postNotificationName("CoreDataReset", object: nil)
    }

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.checkthis.today" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
    }()

    var managedObjectModel: NSManagedObjectModel {
        get {
            if _managedObjectModel == nil {
                // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
                let modelURL = NSBundle.mainBundle().URLForResource("Tipper", withExtension: "momd")!
                _managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
            }
            return _managedObjectModel!
        }
    }

    var persistentStoreCoordinator: NSPersistentStoreCoordinator  {
        get {
            // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
            // Create the coordinator and store
            if _persistentStoreCoordinator == nil {
                _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
                let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Tipper.sqlite")
                var error: NSError? = nil
                var failureReason = "There was an error creating or loading the application's saved data."
                do {
                    try _persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
                } catch let error2 as NSError {
                    error = error2
                    _persistentStoreCoordinator = nil

                    do {
                        try NSFileManager.defaultManager().removeItemAtURL(url)
                    } catch _ {
                    }
                    _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
                    do {
                        try _persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
                    } catch let error1 as NSError {
                        error = error1
                    }
                }

            }
            return _persistentStoreCoordinator!
        }
    }

    var managedObjectContext: NSManagedObjectContext  {
        get {
            if _managedObjectContext == nil {
                _privateWriterContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
                _privateWriterContext!.persistentStoreCoordinator = persistentStoreCoordinator
                _managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
                _managedObjectContext!.parentContext = _privateWriterContext!
            }
            return _managedObjectContext!
        }
    }

    // MARK: - Core Data Saving support
    func writeToDisk() {
        print("\(className)::\(__FUNCTION__)")
        saveContext()
        if let privateMoc = _privateWriterContext {
            var error: NSError? = nil
            if privateMoc.hasChanges {
                do {
                    try privateMoc.save()
                } catch let error1 as NSError {
                    error = error1
                    print("Unresolved error \(error), \(error!.userInfo)")
                }
            }
        }

    }

    func saveContext () {
        var error: NSError? = nil
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error1 as NSError {
                error = error1
                print("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }


}

protocol NotificationMessagesDelegate:class {
    func didReceiveNotificationAlert(message: String, subtitle: String, type: TSMessageNotificationType)
}

