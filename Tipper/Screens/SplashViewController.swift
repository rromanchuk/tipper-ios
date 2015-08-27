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

    @IBOutlet weak var twitterLoginButton: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()

        var gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.colorWithRGB(0x7BD5AA, alpha: 1.0).CGColor, UIColor.colorWithRGB(0x5BAB85, alpha: 1.0).CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
        
        twitterLoginButton.layer.borderWidth = 1.0
        twitterLoginButton.layer.borderColor = UIColor.whiteColor().CGColor
        println("\(className)::\(__FUNCTION__) \(managedObjectContext)")
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("\(className)::\(__FUNCTION__)")
        if (currentUser.isTwitterAuthenticated) {
            SwiftSpinner.hide(completion: nil)
            performSegueWithIdentifier("Home", sender: self)
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
        UIApplication.sharedApplication().openURL(NSURL(string:Config.get("PRIVACY_URL"))!)
    }

    @IBAction func didTapLogin(sender: TWTRLogInButton) {
        SwiftSpinner.show("Logging you in...")
        Twitter.sharedInstance().logInWithCompletion { session, error in
            Debug.isBlocking()
            if (session != nil) {
                println("signed in as \(session.userName)")
                self.provider.logins = ["api.twitter.com": "\(session.authToken);\(session.authTokenSecret)"]
                self.currentUser.twitterAuthenticationWithTKSession(session)
                
                self.provider.refresh().continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
                    println("provider refresh() finished result: \(task.result) error? \(task.error)")
                    if task.error == nil, let identifier = task.result as? String {
                        self.currentUser.cognitoIdentity = identifier
                        //self.currentUser.writeToDisk()
                        Twitter.sharedInstance().APIClient.loadUserWithID(session.userID, completion: { (user, error) -> Void in
                            Debug.isBlocking()
                            if let user = user {
                                self.currentUser.authenticate( { () -> Void in
                                    println("\(self.className)::\(__FUNCTION__) authenticate callback")
                                    Debug.isBlocking()
                                    SwiftSpinner.hide(completion: nil)
                                    self.currentUser.registerForRemoteNotificationsIfNeeded()
                                    self.performSegueWithIdentifier("Home", sender: self)
                                })
                            }
                        })
                        
                    } else {
                        SwiftSpinner.showWithDelay(4.0, title: "There was a problem logging in.", animated: true)
                    }
                    
                    // todo
                    return nil
                })
            } else {
                SwiftSpinner.hide(completion: nil)
                println("error: \(error.localizedDescription)");
            }
        }
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
