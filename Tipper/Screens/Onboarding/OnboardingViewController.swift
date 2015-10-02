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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func didTapLogin(sender: UIButton) {
        onboardingDelegate?.didTapButton(sender)
    }
    
    @IBAction func didTapTOS(sender: UITapGestureRecognizer) {
        UIApplication.sharedApplication().openURL(NSURL(string:Config.get("PRIVACY_URL"))!)
    }

    
     //MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PageViewEmbed" {
            let vc = segue.destinationViewController as! OnboardingPageControllerViewController
            vc.managedObjectContext = self.managedObjectContext
            vc.currentUser = self.currentUser
            vc.containerController = self
            vc.provider = self.provider
            vc.market = self.market
            onboardingDelegate = vc
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