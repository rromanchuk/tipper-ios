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
            //            self.container.hidden = false
            //            self.twitterIdLabel.text = currentUser?.twitterUserId
            //            self.phoneLabel.text = currentUser?.phone
            //            self.bitcoinAdressLabel.text = ""
            performSegueWithIdentifier("SetupPay", sender: self)
        } else {
            //self.container.hidden = true
            let authenticateButton = DGTAuthenticateButton(authenticationCompletion: {
                (session: DGTSession!, error: NSError!) in
                if (error != nil) {
                    self.currentUser?.twitterAuthenticationWithSession(session)
                    UserSync.sharedInstance.sync(self.currentUser!)
                    self.performSegueWithIdentifier("SetupPay", sender: self)
                }

            })

            authenticateButton.center = self.view.center
            self.view.addSubview(authenticateButton)
            
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
