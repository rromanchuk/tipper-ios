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
    var provider: AWSCognitoCredentialsProvider!
    var currentUser: CurrentUser!
    var className = "SplashViewController"
    var managedObjectContext: NSManagedObjectContext?
    var market: Market?

    @IBOutlet weak var twitterLoginButton: TWTRLogInButton!


    override func viewDidLoad() {
        super.viewDidLoad()

        var gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.colorWithRGB(0x7BD5AA, alpha: 1.0).CGColor, UIColor.colorWithRGB(0x5BAB85, alpha: 1.0).CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
        println("\(className)::\(__FUNCTION__) \(managedObjectContext)")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("\(className)::\(__FUNCTION__)")
        if (currentUser.isTwitterAuthenticated) {

            performSegueWithIdentifier("Home", sender: self)
        } else {

            twitterLoginButton.logInCompletion = { (session, error) in
                if (session != nil) {
                    println("signed in as \(session.userName)");
                    self.provider.logins = ["api.twitter.com": "\(session.authToken);\(session.authTokenSecret)"]
                    self.currentUser.twitterAuthenticationWithTKSession(session)
                    self.currentUser.cognitoIdentity = self.provider.identityId
                    self.currentUser.writeToDisk()

                    Twitter.sharedInstance().APIClient.loadUserWithID(session.userID, completion: { (user, error) -> Void in
                        if let user = user {
                            self.currentUser.authenticate( { () -> Void in
                                //UserSync.sharedInstance.sync(self.currentUser)
                                self.currentUser.registerForRemoteNotificationsIfNeeded()
                                self.performSegueWithIdentifier("Home", sender: self)
                            })
                        }
                    })

                } else {
                    println("error: \(error.localizedDescription)");
                }

            }

        }

    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "Home") {
            let vc = segue.destinationViewController as! HomeController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market

        }
    }

    @IBAction func didTapTOS(sender: UITapGestureRecognizer) {
        UIApplication.sharedApplication().openURL(NSURL(string:"https://www.coinbit.tips/privacy")!)
    }

    @IBAction func unwindToSplash(unwindSegue: UIStoryboardSegue) {
        println("\(className)::\(__FUNCTION__)")
        if let blueViewController = unwindSegue.sourceViewController as? HomeController {
            println("Coming from HomeController")
        }
        else if let redViewController = unwindSegue.sourceViewController as? TipDetailsViewController {
            println("Coming from TipDetailsViewController")
        }
        (UIApplication.sharedApplication().delegate as! AppDelegate).setupFirstController()
    }

}
