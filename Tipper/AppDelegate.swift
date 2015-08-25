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
        println("\(className)::\(__FUNCTION__)")
        Fabric.with([Crashlytics(), Twitter()])
        Config.dump()


        NSUbiquitousKeyValueStore.defaultStore().synchronize()
        

        Stripe.setDefaultPublishableKey(Config.get("STRIPE_PUBLISHABLE"))
        setupFirstController()


        println("\(className)::\(__FUNCTION__) currentUser:\([currentUser])")

        AWSLogger.defaultLogger().logLevel = .Error
        AWSMobileAnalytics(forAppId: Config.get("AWS_ANALYTICS_ID"))

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "UNAUTHORIZED_USER", object: nil)
        //DynamoUser.findByTwitterId(currentUser.uuid!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cognitoIdentityDidChange:", name: AWSCognitoIdentityIdChangedNotification, object: nil)
        return true
    }

    func setupFirstController() {
        currentUser = CurrentUser.currentUser(managedObjectContext)

        println("\(className)::\(__FUNCTION__) currentUser:\([currentUser])")


        provider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: Config.get("COGNITO_POOL"))
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: provider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration

        

        market = NSEntityDescription.insertNewObjectForEntityForName("Market", inManagedObjectContext: managedObjectContext) as! Market
        writeToDisk()

        let firstController = window?.rootViewController as! SplashViewController
        firstController.currentUser = CurrentUser.currentUser(managedObjectContext)
        firstController.provider = provider
        firstController.managedObjectContext = managedObjectContext
        firstController.market = market


    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
         println("\(className)::\(__FUNCTION__)")
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        println("\(className)::\(__FUNCTION__)")
        writeToDisk()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        println("\(className)::\(__FUNCTION__)")
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0

    }

    func setApplicationBadgeNumber(number: UInt) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = Int(number)
    }

    func incrementApplicationtBadgeNumber() {
        var num = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        setApplicationBadgeNumber(UInt(num))
    }


    func applicationDidBecomeActive(application: UIApplication) {
        println("\(className)::\(__FUNCTION__)")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        refresh()
    }

    func refresh() {
        println("\(className)::\(__FUNCTION__)")
        
        if currentUser.isTwitterAuthenticated {
            provider.logins = ["api.twitter.com": "\(Twitter.sharedInstance().session().authToken);\(Twitter.sharedInstance().session().authTokenSecret)"]
           
            currentUser.refreshWithDynamo { [weak self] (error) -> Void in
                self?.currentUser.updateBTCBalance({ () -> Void in
                    self?.provider.getIdentityId().continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
                        if task.error == nil, let identity = task.result as? String {
                            println("\(self?.className)::\(__FUNCTION__) Just fetched cognito identity and is \(identity)")
                            self?.currentUser.cognitoIdentity = identity
                        }
                        self?.currentUser?.pushToDynamo()
                        return nil
                    })
                })
                self?.currentUser.registerForRemoteNotificationsIfNeeded()
            }
        }
        
        Settings.update(currentUser)
        market.update { [weak self] () -> Void in }
    }


    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        writeToDisk()
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        println("\(className)::\(__FUNCTION__)")
        let deviceTokenString = "\(deviceToken)"
            .stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString:"<>"))
            .stringByReplacingOccurrencesOfString(" ", withString: "")
        println("deviceTokenString: \(deviceTokenString)")
        currentUser?.deviceToken = deviceTokenString

        let sns = AWSSNS.defaultSNS()
        let request = AWSSNSCreatePlatformEndpointInput()
        request.token = deviceTokenString
        request.platformApplicationArn = Config.get("SNS_ENDPOINT")
        sns.createPlatformEndpoint(request).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            if task.error != nil {
                println("Error: \(task.error)")
            } else {
                let createEndpointResponse = task.result as! AWSSNSCreateEndpointResponse
                println("endpointArn: \(createEndpointResponse.endpointArn)")
                self.currentUser?.endpointArn = createEndpointResponse.endpointArn
                self.currentUser?.pushToDynamo()
                self.gerneralSubscriptionChannel(task)
                println("admin? \(self.currentUser?.admin)")
                if let admin = self.currentUser?.admin {
                    self.adminSubscriptionChannel(task)
                }

            }
            
            return nil
        })
    }

    func gerneralSubscriptionChannel(task: AWSTask!) {
        println("\(className)::\(__FUNCTION__)")
        let sns = AWSSNS.defaultSNS()

        let createEndpointResponse = task.result as! AWSSNSCreateEndpointResponse
        println("endpointArn: \(createEndpointResponse.endpointArn)")
        let request = AWSSNSSubscribeInput()
        request.endpoint = createEndpointResponse.endpointArn
        request.protocols = "application"
        request.topicArn = Config.get("AWS_GENERAL_SNS")
        sns.subscribe(request).continueWithBlock({ (task) -> AnyObject! in
            println("\(task.result) \(task.error)")
            return nil
        })
        
    }


    func adminSubscriptionChannel(task: AWSTask!) {
        println("\(className)::\(__FUNCTION__)")
        let sns = AWSSNS.defaultSNS()
        let createEndpointResponse = task.result as! AWSSNSCreateEndpointResponse
        println("endpointArn: \(createEndpointResponse.endpointArn)")

        let request = AWSSNSSubscribeInput()
        request.endpoint = createEndpointResponse.endpointArn
        request.protocols = "application"
        request.topicArn = Config.get("AWS_ADMIN_SNS")
        sns.subscribe(request).continueWithBlock({ (task) -> AnyObject! in
            println("\(task.result) \(task.error)")
            return nil
        })

    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject: AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

        println("\(className)::\(__FUNCTION__) userInfo:\(userInfo)")
        var messageJSON: JSON?

        if let message = userInfo["message"] as? [String: AnyObject]  {
            if application.applicationState == .Active {
                messageJSON = JSON(message)

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
        UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }

    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
        println("\(className)::\(__FUNCTION__)")

        // 1
        if let userInfo = userInfo, request = userInfo["request"] as? String {
            if request == "balance" {
                // 2
                registerBackgroundTask()
                currentUser.refreshWithServer({ (error) -> Void in
                    self.managedObjectContext.refreshObject(self.currentUser, mergeChanges: true)
                    reply(["balance": self.currentUser.balanceAsUBTC, "userId": self.currentUser.userId!, "bitcoinAddress": self.currentUser.bitcoinAddress!])
                    if self.backgroundTask != UIBackgroundTaskInvalid {
                        self.endBackgroundTask()
                    }
                })
                // 3

                return
            }
        }
        
        // 4
        reply([:])
    }

    func processMessage(message:JSON?) {
        println("\(className)::\(__FUNCTION__)")
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
        println("\(className)::\(__FUNCTION__)")
        currentUser.resetIdentifiers()
        resetCoreData()
        NSNotificationCenter.defaultCenter().postNotificationName("BACK_TO_SPLASH", object: nil)
    }

    func resetCognitoCredentials() {
        println("\(className)::\(__FUNCTION__)")
        self.provider.clearKeychain()
    }
    
    func cognitoIdentityDidChange(notficiation: NSNotification) {
        println("\(className)::\(__FUNCTION__)")
        if let userInfo = notficiation.userInfo, identifier = userInfo[AWSCognitoNotificationNewId] as? String {
            println("\(className)::\(__FUNCTION__) New cognito identifier: \(identifier)")
            self.currentUser.cognitoIdentity = identifier
            self.currentUser.pushToDynamo()
        }
        
        
    }

    func resetCoreData() {
        println("\(className)::\(__FUNCTION__) ****************************")
        let storeURL = applicationDocumentsDirectory.URLByAppendingPathComponent("Tipper.sqlite")
        NSFileManager.defaultManager().removeItemAtURL(storeURL, error: nil)
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
        return urls[urls.count-1] as! NSURL
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
                if _persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
                    _persistentStoreCoordinator = nil

                    NSFileManager.defaultManager().removeItemAtURL(url, error:nil)
                    _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
                    _persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error)
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
        println("\(className)::\(__FUNCTION__)")
        saveContext()
        if let privateMoc = _privateWriterContext {
            var error: NSError? = nil
            if privateMoc.hasChanges && !privateMoc.save(&error) {
                println("Unresolved error \(error), \(error!.userInfo)")
            }
        }

    }

    func saveContext () {
        var error: NSError? = nil
        if managedObjectContext.hasChanges && !managedObjectContext.save(&error) {
            println("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }


}

protocol NotificationMessagesDelegate:class {
    func didReceiveNotificationAlert(message: String, subtitle: String, type: TSMessageNotificationType)
}

