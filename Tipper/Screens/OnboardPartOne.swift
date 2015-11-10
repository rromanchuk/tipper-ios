//
//  OnboardPartOne.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/26/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import TwitterKit
import Crashlytics

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
            if let session = session where error == nil {
                log.info("Twitter login complete:\(session)")
                self.provider.logins = ["api.twitter.com": "\(session.authToken);\(session.authTokenSecret)"]
                self.currentUser.twitterAuthenticationWithTKSession(session)
                self.refreshProvider(session)
            } else {
                log.warning("[ERROR] Twitter login failed \(error)")
                SwiftSpinner.hide({ () -> Void in
                    let alert = UIAlertController(title: "Opps", message: "Something went wrong connecting to your Twitter account. Please verify your Twitter account is properly connected in iOS settings.", preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(defaultAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        }
    }

    // Update cognito with updated twitter tokens
    private func refreshProvider(twitterSession: TWTRAuthSession) {
        log.verbose("")
        provider.refresh().continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in

            if task.error == nil, let identifier = task.result as? String {
                log.info("Cognito refresh() finished")
                self.currentUser.cognitoIdentity = identifier
                self.currentUser.save()
                self.loadUser(self.currentUser.twitterUserId!)
            } else {
                SwiftSpinner.hide({ () -> Void in
                    log.verbose("[ERROR] provider refresh() failed: \(task.error)")
                    let alert = UIAlertController(title: "Opps", message: "Something bad happened. Try again?", preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(defaultAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
            return nil
        })
    }

    // Load the social information from twitter
    private func loadUser(twitterUserId: String) {
        log.verbose("")
        TWTRAPIClient(userID: twitterUserId).loadUserWithID(twitterUserId, completion: { (user, error) -> Void in
            if let user = user where error == nil {
                log.verbose("twitter user loaded: \(user)")
                self.currentUser.profileImage = user.profileImageURL
                self.currentUser.twitterUsername = user.screenName
                self.authenticate()
            } else if let error = error {
                log.warning("[ERROR] Could not load twitter information. \(error)")
                SwiftSpinner.hide({ () -> Void in
                    let alert = UIAlertController(title: "Opps", message: error.localizedDescription, preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(defaultAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        })
    }

    // Find or create or dynamo user
    private func authenticate() {
        log.verbose("")
        self.currentUser.authenticate() { (errorMessage) -> Void in
            if let errorMessage = errorMessage {
                log.warning("[ERROR]")
                SwiftSpinner.hide({ () -> Void in
                    let alert = UIAlertController(title: "Opps", message: errorMessage, preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(defaultAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                })
 
            } else {
                log.verbose("\(self.className)::\(__FUNCTION__) authenticate callback")
                Debug.isBlocking()
                SwiftSpinner.hide(nil)
                self.currentUser.registerForRemoteNotificationsIfNeeded()
                (self.parentViewController as! OnboardingPageControllerViewController).autoAdvance()
            }
        }
    }



}
