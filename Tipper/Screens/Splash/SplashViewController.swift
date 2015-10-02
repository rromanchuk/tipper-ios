//
//  SplashViewController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 10/2/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    var provider: AWSCognitoCredentialsProvider!
    var currentUser: CurrentUser!
    var className = "OnboardingViewController"
    var managedObjectContext: NSManagedObjectContext?
    var market: Market?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if currentUser.isTwitterAuthenticated {
            self.performSegueWithIdentifier("Home", sender: self)
        } else {
            self.performSegueWithIdentifier("Onboarding", sender: self)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func done(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("\(className)::\(__FUNCTION__) identifier: \(segue.identifier) \(segue.sourceViewController)")
        if segue.identifier == "ExitFromOnboarding" {
        }
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


    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Home" {
            let vc = segue.destinationViewController as! HomeController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market

        } else if segue.identifier == "Onboarding" {
            let vc = segue.destinationViewController as! OnboardingViewController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
            vc.provider = provider
        }
    }


}
