//
//  OnboardPartThree.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/27/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import PassKit
import Stripe
import ApplePayStubs

class OnboardPartThree: GAITrackedViewController, UINavigationControllerDelegate, StandardViewController { //PKPaymentAuthorizationViewControllerDelegate, STPCheckoutViewControllerDelegate
    var provider: AWSCognitoCredentialsProvider!
    var currentUser: CurrentUser!
    var className = "OnboardPartThree"
    var managedObjectContext: NSManagedObjectContext?
    var market: Market!
    weak var onboardingDelegate: OnboardingViewController?
    weak var containerController: OnboardingViewController?
    
    lazy var paymentController : PaymentController = {
       PaymentController(withMarket: self.market)
    }()
    
    @IBOutlet weak var stripeButton: UIButton!
    @IBOutlet weak var applePayButton: UIButton!
    @IBOutlet weak var welcomeToTipperLabel: UILabel!
    @IBOutlet weak var tipAmountLabel: UILabel!
    @IBOutlet weak var fundAmountLabel: UILabel!
    
    @IBOutlet weak var btcConversionLabel: UILabel!
    @IBOutlet weak var ubtcExchangeLabel: UILabel!
    @IBOutlet weak var usdExchangeLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        updateBTCSpotPrice()
        updateMarketData()
        paymentController.walletDelegate = self

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateMarketData() {
        log.verbose("")

        if let fundAmount = Settings.sharedInstance.fundAmount, fundAmountUBTC =  Settings.sharedInstance.fundAmountUBTC {
            btcConversionLabel.text = "(\(fundAmount) Bitcoin)"
            ubtcExchangeLabel.text = fundAmountUBTC
        }

        if let amount = market.amount {
            usdExchangeLabel.text = amount
        }
    }

    func updateBTCSpotPrice() {
        log.verbose("")
        market.update { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.updateMarketData()
            })
        }
    }

    
    
    @IBAction func didTapPay(sender: UIButton) {
        log.verbose("")
        paymentController.pay()
    }
    
    
    func didTapButton(sender: UIButton) {
        log.verbose("")
        didTapPay(sender)
    }
    
    
    @IBAction func didTapSkip(sender: UIButton) {
        (parentViewController as! OnboardingPageControllerViewController).autoAdvance()
    }

}
