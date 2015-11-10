//
//  OnboardPartFive.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/27/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class OnboardPartFive: GAITrackedViewController, StandardViewController {
    var provider: AWSCognitoCredentialsProvider!
    var currentUser: CurrentUser!
    var className = "OnboardPartFive"
    var managedObjectContext: NSManagedObjectContext?
    var market: Market!
    weak var containerController: OnboardingViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didTapButton(sender: UIButton) {
        log.verbose("")
        API.sharedInstance.autotip({ (json, error) -> Void in
            //
        })
        (parentViewController as! OnboardingPageControllerViewController).autoAdvance()
    }
    
}
