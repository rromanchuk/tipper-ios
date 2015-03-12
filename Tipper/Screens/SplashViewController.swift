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
    var provider: TwitterAuth?
    var currentUser: CurrentUser?
    var className = "SplashViewController"
    var managedObjectContext: NSManagedObjectContext?

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (currentUser!.isTwitterAuthenticated) {

            performSegueWithIdentifier("SetupPay", sender: self)
        } else {
            //self.container.hidden = true
//            let authenticateButton = DGTAuthenticateButton(authenticationCompletion: {
//                (session: DGTSession!, error: NSError!) in
//                if (error != nil) {
//                    self.currentUser?.twitterAuthenticationWithSession(session)
//                    UserSync.sharedInstance.sync(self.currentUser!)
//                    self.performSegueWithIdentifier("SetupPay", sender: self)
//                }
//
//            })
            let logInButton = TWTRLogInButton(logInCompletion:
                { (session, error) in
                    if (session != nil) {
                        println("signed in as \(session.userName)");
                        self.currentUser?.twitterAuthenticationWithTKSession(session)
                        UserSync.sharedInstance.sync(self.currentUser!)
                        self.performSegueWithIdentifier("SetupPay", sender: self)
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
            let vc = segue.destinationViewController as! ApplePayViewController
            vc.managedObjectContext = self.managedObjectContext
            vc.currentUser = self.currentUser

        }
    }
}
