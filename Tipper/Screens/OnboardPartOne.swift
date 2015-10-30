//
//  OnboardPartOne.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/26/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import TwitterKit

class OnboardPartOne: UIViewController, StandardViewController {
    
    var provider: AWSCognitoCredentialsProvider!
    var currentUser: CurrentUser!
    var className = "OnboardPartOne"
    var managedObjectContext: NSManagedObjectContext?
    var market: Market!
    weak var containerController: OnboardingViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.verbose("")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func didTapButton(sender: UIButton) {
        log.verbose("")
        logInWithCompletion()
    }
    
    @IBAction func didTapTOS(sender: UITapGestureRecognizer) {
        UIApplication.sharedApplication().openURL(NSURL(string:Config.get("PRIVACY_URL"))!)
    }
    
    @IBAction func unwindToSplash(unwindSegue: UIStoryboardSegue) {
        log.verbose("")
        if let _ = unwindSegue.sourceViewController as? HomeController {
            log.verbose("Coming from HomeController")
        }
        else if let _ = unwindSegue.sourceViewController as? TipDetailsViewController {
            log.verbose("Coming from TipDetailsViewController")
        }
        (UIApplication.sharedApplication().delegate as! AppDelegate).setupFirstController()
    }
    
    
    // MARK: Application lifecycle
    
    func applicationWillResignActive(aNotification: NSNotification) {
        log.verbose("")
        SwiftSpinner.hide(nil)
    }
    
    
    private func logInWithCompletion() {
        log.verbose("")
        SwiftSpinner.show("Logging you in...")
        Twitter.sharedInstance().logInWithCompletion { (session, error) -> Void in
            log.info("session:\(session), error: \(error)")
            if let session = session where error == nil {
                self.provider.logins = ["api.twitter.com": "\(session.authToken);\(session.authTokenSecret)"]
                self.currentUser.twitterAuthenticationWithTKSession(session)
                self.refreshProvider(session)
            } else {
                SwiftSpinner.hide({ () -> Void in
                    let alert = UIAlertController(title: "Opps", message: "Something went wrong connecting to your Twitter account. Please verify your Twitter account is properly connected in iOS settings.", preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(defaultAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    private func refreshProvider(twitterSession: TWTRAuthSession) {
        log.verbose("")
        provider.refresh().continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            log.verbose("provider refresh() finished result: \(task.result) error? \(task.error)")
            if task.error == nil, let identifier = task.result as? String {
                self.currentUser.cognitoIdentity = identifier
                self.currentUser.save()
                self.loadUser(self.currentUser.twitterUserId!)
            } else {
                SwiftSpinner.hide({ () -> Void in
                    let alert = UIAlertController(title: "Opps", message: "Something bad happened. Try again?", preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(defaultAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
            return nil
        })
    }
    
    private func loadUser(twitterUserId: String) {
        log.verbose("")
        TWTRAPIClient(userID: twitterUserId).loadUserWithID(twitterUserId, completion: { (user, error) -> Void in
            if let user = user where error == nil {
                self.currentUser.profileImage = user.profileImageURL
                self.currentUser.twitterUsername = user.screenName
                self.authenticate()
            } else if let error = error {
                SwiftSpinner.hide({ () -> Void in
                    let alert = UIAlertController(title: "Opps", message: error.localizedDescription, preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(defaultAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        })
    }
    
    private func authenticate() {
        log.verbose("")
        self.currentUser.authenticate() { () -> Void in
            log.verbose("\(self.className)::\(__FUNCTION__) authenticate callback")
            Debug.isBlocking()
            SwiftSpinner.hide(nil)
            self.currentUser.registerForRemoteNotificationsIfNeeded()
            self.currentUser.writeToDisk()
            (self.parentViewController as! OnboardingPageControllerViewController).autoAdvance()
            
        }
    }



}
