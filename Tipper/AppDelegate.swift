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


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let className = "AppDelegate"
    var privateWriterContext: NSManagedObjectContext?
    var currentUser: CurrentUser!
    var provider: TwitterAuth?
    var market: Market!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        // Override point for customization after application launch.
        Config.dump()
        TWTRTweetView.appearance().primaryTextColor = UIColor.whiteColor()
        TWTRTweetView.appearance().backgroundColor = UIColor.colorWithRGB(0xC1DBCE, alpha: 1.0)


        Fabric.with([Crashlytics(), Twitter()])
        NSUbiquitousKeyValueStore.defaultStore().synchronize()
        

        Stripe.setDefaultPublishableKey(Config.get("STRIPE_PUBLISHABLE"))
        currentUser = CurrentUser.currentUser(managedObjectContext!)
        

        currentUser.writeToDisk()

        println("\(className)::\(__FUNCTION__) currentUser:\([currentUser])")

        AWSLogger.defaultLogger().logLevel = .Error
        provider = TwitterAuth(currentUser: currentUser)
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityProvider: provider, unauthRoleArn: Config.get("COGNITO_UNAUTH_ARN"), authRoleArn: Config.get("COGNITO_AUTH_ARN"))

        let defaultServiceConfiguration = AWSServiceConfiguration(
            region: AWSRegionType.USEast1,
            credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().setDefaultServiceConfiguration(defaultServiceConfiguration)


        let mobileAnalyticsConfiguration = AWSMobileAnalyticsConfiguration()
        mobileAnalyticsConfiguration.transmitOnWAN = true

        let analytics = AWSMobileAnalytics(forAppId: Config.get("AWS_ANALYTICS_ID"), configuration: mobileAnalyticsConfiguration, completionBlock: nil)

        market = NSEntityDescription.insertNewObjectForEntityForName("Market", inManagedObjectContext: managedObjectContext!) as! Market
        market.writeToDisk()

        let firstController = window?.rootViewController as! SplashViewController
        firstController.currentUser = currentUser
        firstController.provider = provider
        firstController.managedObjectContext = managedObjectContext
        firstController.market = market

       
        return true
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
        if currentUser.isTwitterAuthenticated {
            currentUser.updateTwitterAuthentication()
            currentUser.refreshWithDynamo()
            currentUser.registerForRemoteNotificationsIfNeeded()
        }        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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
        request.platformApplicationArn = "arn:aws:sns:us-east-1:080383581145:app/APNS_SANDBOX/TipperBeta"
        sns.createPlatformEndpoint(request).continueWithBlock { (task: BFTask!) -> AnyObject! in
            if task.error != nil {
                println("Error: \(task.error)")
            } else {
                let createEndpointResponse = task.result as! AWSSNSCreateEndpointResponse
                println("endpointArn: \(createEndpointResponse.endpointArn)")
                self.currentUser?.endpointArn = createEndpointResponse.endpointArn

            }
            
            return nil
        }
    }

    // MARK: - Core Data stack


    func resetCoreData() {
        let storeURL = applicationDocumentsDirectory.URLByAppendingPathComponent("Tipper.sqlite")
        NSFileManager.defaultManager().removeItemAtURL(storeURL, error: nil)
        persistentStoreCoordinator = nil
        managedObjectContext = nil
    }

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.checkthis.today" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Tipper", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Tipper.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil

            NSFileManager.defaultManager().removeItemAtURL(url, error:nil)
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error)
        }

        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        self.privateWriterContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        self.privateWriterContext!.persistentStoreCoordinator = coordinator

        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.parentContext = self.privateWriterContext
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support
    func writeToDisk() {
        saveContext()
        if let privateMoc = self.privateWriterContext {
            var error: NSError? = nil
            if privateMoc.hasChanges && !privateMoc.save(&error) {
                NSLog("Unresolved error \(error), \(error!.userInfo)")
            }
        }

    }

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }


}

