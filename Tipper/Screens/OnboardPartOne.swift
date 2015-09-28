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
        print("\(className)::\(__FUNCTION__)")
        containerController?.twitterLoginButton.setTitle("Sign in to Twitter", forState: .Normal)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func didTapButton(sender: UIButton) {
        print("\(className)::\(__FUNCTION__)")
        logInWithCompletion()
    }
    
    
    
    @IBAction func unwindToSplash(unwindSegue: UIStoryboardSegue) {
        print("\(className)::\(__FUNCTION__)")
        if let _ = unwindSegue.sourceViewController as? HomeController {
            print("Coming from HomeController")
        }
        else if let _ = unwindSegue.sourceViewController as? TipDetailsViewController {
            print("Coming from TipDetailsViewController")
        }
        (UIApplication.sharedApplication().delegate as! AppDelegate).setupFirstController()
    }
    
    @IBAction func done(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("\(className)::\(__FUNCTION__) identifier: \(segue.identifier) \(segue.sourceViewController)")
        if segue.identifier == "ExitFromOnboarding" {
        }
    }

    
    
    // MARK: Application lifecycle
    
    func applicationWillResignActive(aNotification: NSNotification) {
        print("\(className)::\(__FUNCTION__)")
        SwiftSpinner.hide(nil)
    }
    
    
    private func logInWithCompletion() {
        print("\(className)::\(__FUNCTION__)")
        Twitter.sharedInstance().logInWithCompletion { (session, error) -> Void in
            print("\(self.className)::\(__FUNCTION__) session:\(session), error: \(error)")
            SwiftSpinner.show("Logging you in...")
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
        print("\(className)::\(__FUNCTION__)")
        provider.refresh().continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            print("provider refresh() finished result: \(task.result) error? \(task.error)")
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
        print("\(className)::\(__FUNCTION__)")
        Twitter.sharedInstance().APIClient.loadUserWithID(twitterUserId, completion: { (user, error) -> Void in
            if let user = user where error == nil {
                self.currentUser.profileImage = user.profileImageURL
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
        print("\(className)::\(__FUNCTION__)")
        self.currentUser.authenticate(Twitter.sharedInstance().session()!) { () -> Void in
            print("\(self.className)::\(__FUNCTION__) authenticate callback")
            Debug.isBlocking()
            SwiftSpinner.hide(nil)
            self.currentUser.registerForRemoteNotificationsIfNeeded()
            self.currentUser.writeToDisk()
            (self.parentViewController as! OnboardingPageControllerViewController).autoAdvance()
        }
    }



}
