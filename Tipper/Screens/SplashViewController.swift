//
//  SplashViewController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/10/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
import TwitterKit

class SplashViewController: UIViewController {
    var provider: TwitterAuth!
    var currentUser: CurrentUser!
    var className = "SplashViewController"
    var managedObjectContext: NSManagedObjectContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        println("\(className)::\(__FUNCTION__) \(managedObjectContext)")

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("\(className)::\(__FUNCTION__)")
        if (currentUser.isTwitterAuthenticated) {

            performSegueWithIdentifier("SetupPay", sender: self)
        } else {

            let logInButton = TWTRLogInButton(logInCompletion:
                { (session, error) in
                    if (session != nil) {
                        println("signed in as \(session.userName)");
                        self.currentUser.twitterAuthenticationWithTKSession(session)
                        self.currentUser.writeToDisk()
                        self.currentUser.authenticate(self.provider, completion: { () -> Void in
                            UserSync.sharedInstance.sync(self.currentUser)
                            let types = UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert
                            let notificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)

                            UIApplication.sharedApplication().registerForRemoteNotifications()
                            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
                            self.performSegueWithIdentifier("SetupPay", sender: self)
                        })
                    } else {
                        println("error: \(error.localizedDescription)");
                    }
            })
            logInButton.center = self.view.center
            self.view.addSubview(logInButton)

            
        }

    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "SetupPay") {
            let vc = segue.destinationViewController as! TipperTabBarController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser

        }
    }
}
