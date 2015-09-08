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
    var twitterSession: TWTRAuthSession? = nil

    @IBOutlet weak var twitterLoginButton: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()

        var gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.colorWithRGB(0x7BD5AA, alpha: 1.0).CGColor, UIColor.colorWithRGB(0x5BAB85, alpha: 1.0).CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
        
//        twitterLoginButton.layer.borderWidth = 1.0
//        twitterLoginButton.layer.borderColor = UIColor.whiteColor().CGColor
        println("\(className)::\(__FUNCTION__) \(managedObjectContext)")

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive:", name: UIApplicationWillResignActiveNotification, object: UIApplication.sharedApplication())
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("\(className)::\(__FUNCTION__) isTwitterAuthenticated \(currentUser.isTwitterAuthenticated)")
        if (currentUser.isTwitterAuthenticated) {
            SwiftSpinner.hide(completion: nil)
            performSegueWithIdentifier("Home", sender: self)
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "Home") {
            let vc = segue.destinationViewController as! HomeController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
        } else if (segue.identifier == "Onboarding") {
            let vc = segue.destinationViewController as! OnboardNavigationController
            let topVc = vc.topViewController as! OnboardFundingViewController
            topVc.managedObjectContext = managedObjectContext
            topVc.currentUser = currentUser
            topVc.market = market
        }
    }

    @IBAction func didTapTOS(sender: UITapGestureRecognizer) {
        UIApplication.sharedApplication().openURL(NSURL(string:Config.get("PRIVACY_URL"))!)
    }

    @IBAction func didTapLogin(sender: TWTRLogInButton) {
        println("\(className)::\(__FUNCTION__)")
        logInWithCompletion()
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
    
    @IBAction func done(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("\(className)::\(__FUNCTION__) identifier: \(segue.identifier) \(segue.sourceViewController)")
        if segue.identifier == "ExitFromOnboarding" {
        }
    }


    // MARK: Application lifecycle

    func applicationWillResignActive(aNotification: NSNotification) {
        println("\(className)::\(__FUNCTION__)")
        SwiftSpinner.hide(completion: nil)
    }


    private func logInWithCompletion() {
        println("\(className)::\(__FUNCTION__)")
        Twitter.sharedInstance().logInWithCompletion { (session, error) -> Void in
            SwiftSpinner.show("Logging you in...")
            if error == nil {
                self.provider.logins = ["api.twitter.com": "\(session.authToken);\(session.authTokenSecret)"]
                self.currentUser.twitterAuthenticationWithTKSession(session)
                self.refreshProvider(session)
            } else {
                SwiftSpinner.showWithDelay(2.0, title: error.localizedDescription, animated: true)
            }
        }
    }

    private func refreshProvider(twitterSession: TWTRAuthSession) {
        println("\(className)::\(__FUNCTION__)")
        provider.refresh().continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            println("provider refresh() finished result: \(task.result) error? \(task.error)")
            if task.error == nil, let identifier = task.result as? String {
                self.currentUser.cognitoIdentity = identifier
                self.currentUser.save()
                self.loadUser(self.currentUser.twitterUserId!)
            } else {
                SwiftSpinner.showWithDelay(2.0, title: "Something bad happened. Try again?", animated: true)
            }
            return nil
        })
    }

    private func loadUser(twitterUserId: String) {
        println("\(className)::\(__FUNCTION__)")
        Twitter.sharedInstance().APIClient.loadUserWithID(twitterUserId, completion: { (user, error) -> Void in
            if let user = user where error == nil {
                self.currentUser.profileImage = user.profileImageURL
                self.authenticate()
            } else if let error = error {
                SwiftSpinner.showWithDelay(2.0, title: error.localizedDescription, animated: true)
            }
        })
    }

    private func authenticate() {
        println("\(className)::\(__FUNCTION__)")
        self.currentUser.authenticate( { () -> Void in
            println("\(self.className)::\(__FUNCTION__) authenticate callback")
            Debug.isBlocking()
            SwiftSpinner.hide(completion: nil)
            self.currentUser.registerForRemoteNotificationsIfNeeded()
            self.currentUser.writeToDisk()
            self.performSegueWithIdentifier("Onboarding", sender: self)
            //self.performSegueWithIdentifier("Home", sender: self)
        })
    }
}
