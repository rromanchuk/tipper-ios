//
//  OnboardPartTwo.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/27/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class OnboardPartTwo: UIViewController, StandardViewController {
    
    var provider: AWSCognitoCredentialsProvider!
    var currentUser: CurrentUser!
    var className = "OnboardPartOne"
    var managedObjectContext: NSManagedObjectContext?
    var market: Market!
    weak var onboardingDelegate: OnboardingViewController?
    weak var containerController: OnboardingViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(className)::\(__FUNCTION__)")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func didTapButton(sender: UIButton) {
        print("\(className)::\(__FUNCTION__)")
        (self.parentViewController as! OnboardingPageControllerViewController).autoAdvance()
    }
    
}
