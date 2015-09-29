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
    
    @IBOutlet weak var welcomeToTipperLabel: UILabel!
    @IBOutlet weak var tipAmountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(className)::\(__FUNCTION__)")
        setupLabel()
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

    func setupLabel() {
        let labelAttributes = NSMutableAttributedString(attributedString: welcomeToTipperLabel.attributedText!)
        labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol-Regular", size: 33.0)!, range: (welcomeToTipperLabel.text! as NSString).rangeOfString("Welcome to "))
        labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol-Regular", size: 33.0)!, range: (welcomeToTipperLabel.text! as NSString).rangeOfString("!"))
        labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol-Bold", size: 33.0)!, range: (welcomeToTipperLabel.text! as NSString).rangeOfString("Tipper"))
        welcomeToTipperLabel.attributedText = labelAttributes

        let tipAmountString = "Tips are a\(Settings.sharedInstance.tipAmountUBTC!) (~$0.10) by default."
        let tipAmountAttributes = NSMutableAttributedString(string: tipAmountString)
        tipAmountAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "coiner", size: 17.0)!, range: NSMakeRange((tipAmountString as NSString).rangeOfString("a500").location, 1))
        tipAmountLabel.attributedText = tipAmountAttributes

    }
    
}
