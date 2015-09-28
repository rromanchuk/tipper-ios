//
//  OnboardingViewController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/26/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import TwitterKit

class OnboardingViewController: UIViewController {
    
    var provider: AWSCognitoCredentialsProvider!
    var currentUser: CurrentUser!
    var className = "OnboardingViewController"
    var managedObjectContext: NSManagedObjectContext?
    var market: Market?
    var twitterSession: TWTRAuthSession? = nil
    weak var onboardingDelegate: OnboardingDelegate?

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var twitterLoginButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(className)::\(__FUNCTION__)")
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive:", name: UIApplicationWillResignActiveNotification, object: UIApplication.sharedApplication())
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didTapLogin(sender: UIButton) {
        onboardingDelegate?.didTapButton(sender)
    }
    
    @IBAction func didTapTOS(sender: UITapGestureRecognizer) {
        UIApplication.sharedApplication().openURL(NSURL(string:Config.get("PRIVACY_URL"))!)
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

    
    
     //MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PageViewEmbed" {
            let vc = segue.destinationViewController as! OnboardingPageControllerViewController
            vc.managedObjectContext = self.managedObjectContext
            vc.currentUser = self.currentUser
            vc.containerController = self
            vc.provider = self.provider
            //vc.onboardingDelegate = self
            onboardingDelegate = vc
        } else if (segue.identifier == "Home") {
            let vc = segue.destinationViewController as! HomeController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
        }
    }
    
    func applicationWillResignActive(aNotification: NSNotification) {
        print("\(className)::\(__FUNCTION__)")
        SwiftSpinner.hide(nil)
    }
    
}


protocol OnboardingDelegate:class {
    func didTapButton(sender: UIButton)
}