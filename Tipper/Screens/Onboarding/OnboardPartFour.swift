//
//  OnboardPartFive.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/27/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class OnboardPartFour: GAITrackedViewController, StandardViewController {
    var provider: AWSCognitoCredentialsProvider!
    var currentUser: CurrentUser!
    var className = "OnboardPartThree"
    var managedObjectContext: NSManagedObjectContext?
    var market: Market!
    weak var containerController: OnboardingViewController?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "remoteRegistrationComplete", name: "didFailToRegisterForRemoteNotificationsWithError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "remoteRegistrationComplete", name: "didRegisterForRemoteNotificationsWithDeviceToken", object: nil)
        // Do any additional setup after loading the view.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func didTapButton(sender: UIButton) {
        log.verbose("")
        currentUser.registerForRemoteNotificationsIfNeeded()
    }
    
    func remoteRegistrationComplete() {
        log.verbose("")
        (parentViewController as? OnboardingPageControllerViewController)?.autoAdvance()
    }

}
