//
//  OnboardingPageControllerViewController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/26/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import PassKit
import Stripe
import ApplePayStubs

class OnboardingPageControllerViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, OnboardingDelegate {
    var provider: AWSCognitoCredentialsProvider!
    var currentUser: CurrentUser!
    var className = "OnboardingPageControllerViewController"
    var managedObjectContext: NSManagedObjectContext?
    var market: Market?
    let ApplePayMerchantID = Config.get("APPLE_PAY_MERCHANT")
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]


    weak var containerController: OnboardingViewController?
    weak var onboardingDelegate: OnboardingDelegate?
    
    
    lazy var pages: [UIViewController] = [self.storyboard!.instantiateViewControllerWithIdentifier("OnboardPartOne"),
        self.storyboard!.instantiateViewControllerWithIdentifier("OnboardPartTwo"),
        self.storyboard!.instantiateViewControllerWithIdentifier("OnboardPartThree"),
        self.storyboard!.instantiateViewControllerWithIdentifier("OnboardPartFour"),
        self.storyboard!.instantiateViewControllerWithIdentifier("OnboardPartFive")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        reset()
    }
    
    func setupViewControllers() {
        for page in pages {
            (page as! StandardViewController).managedObjectContext = managedObjectContext
            (page as! StandardViewController).currentUser = currentUser
            (page as! StandardViewController).market = market
            (page as! StandardViewController).provider = provider
            (page as! StandardViewController).containerController = containerController
            
        }
    }

    func reset() {
        setupViewControllers()
        self.setViewControllers([self.pages[0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        setupLabels(pendingViewControllers[0])
    }
    
    func autoAdvance() {
        log.verbose("")
        let vc = viewControllers![0]
        let idx = pages.indexOf(vc)!
        
        if let userId = currentUser.userId where userId == "4efe5374-bb7a-40af-b1b1-c543ff81caad" {
            containerController?.performSegueWithIdentifier("ExitToSplash", sender: self)
            return
        }
        
        if (idx + 1) < pages.count {
            let newController = pages[idx + 1]
            setupLabels(newController)
            self.setViewControllers([newController], direction: .Forward, animated: true, completion: nil)
        } else if (idx + 1) == pages.count {
            containerController?.performSegueWithIdentifier("ExitToSplash", sender: self)
        }
    }

    func setupLabels(pendingViewControllers: UIViewController) {
        if let _ = pendingViewControllers as? OnboardPartTwo {
            containerController?.twitterLoginButton.setImage(nil, forState: .Normal)
            containerController?.pageControl.hidden = false
            containerController?.pageControl.currentPage = 0
            containerController?.twitterLoginButton.setTitle("Next", forState: .Normal)
        } else if let _ = pendingViewControllers as? OnboardPartThree {
            containerController?.pageControl.hidden = false
            containerController?.pageControl.currentPage = 1
            let paymentRequest = Stripe.paymentRequestWithMerchantIdentifier(ApplePayMerchantID)

            if PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks) && Stripe.canSubmitPaymentRequest(paymentRequest) {
                if let userId = currentUser.userId where userId == "4efe5374-bb7a-40af-b1b1-c543ff81caad" {
                    containerController?.twitterLoginButton.setImage(UIImage(named: "apple-pay-temp"), forState: .Normal)
                    containerController?.twitterLoginButton.setTitle(nil, forState: .Normal)
                } else {
                    containerController?.twitterLoginButton.setTitle("Buy with Pay", forState: .Normal)
                }
            } else {
                log.verbose("ApplePay not supported")
                if let userId = currentUser.userId where userId == "4efe5374-bb7a-40af-b1b1-c543ff81caad" {
                    containerController?.twitterLoginButton.setImage(nil, forState: .Normal)
                }
                containerController?.twitterLoginButton.setTitle("Buy with Credit Card", forState: .Normal)
            }


        } else if let _ = pendingViewControllers as? OnboardPartFour {
            containerController?.twitterLoginButton.setImage(nil, forState: .Normal)
            containerController?.pageControl.currentPage = 2
            containerController?.twitterLoginButton.setTitle("Allow Notifications", forState: .Normal)
        } else if let _ = pendingViewControllers as? OnboardPartFive {
            containerController?.pageControl.currentPage = 3
            containerController?.twitterLoginButton.setTitle("Next", forState: .Normal)
        } else if let _ = pendingViewControllers as? OnboardPartOne {
            containerController?.twitterLoginButton.setTitle("  Sign in with Twitter", forState: .Normal)
        }

    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        //log.verbose("\(className)::\(__FUNCTION__) currentIndex: \(pages.indexOf(viewController)!),  allPages: \(self.pages.count)")
        if let currentIndex = pages.indexOf(viewController) {
            let newIndex = currentIndex - 1
            if newIndex == 0 {
                return nil
            }else if newIndex > 0 {
                return pages[newIndex]
            } else {
                return nil
            }
            
        } else {
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        log.verbose("\(className)::\(__FUNCTION__) currentIndex: \(pages.indexOf(viewController)!),  allPages: \(self.pages.count)")
        if let currentIndex = pages.indexOf(viewController) {
            let newIndex = currentIndex + 1
            if newIndex == 1 {
                return nil
            } else if newIndex < pages.count {
                return pages[newIndex]
            } else {
                return nil
            }

        } else {
            return nil
        }
    }

    // MARK: OnboardingDelegate
    func didTapButton(sender: UIButton) {
        log.verbose("")
        (viewControllers![0] as! StandardViewController).didTapButton(sender)
    }
   
}

protocol StandardViewController:class {
    var currentUser: CurrentUser! {get set}
    var market: Market! {get set}
    var managedObjectContext: NSManagedObjectContext? {get set}
    var provider: AWSCognitoCredentialsProvider! {get set}
    weak var containerController: OnboardingViewController? {get set}
    func didTapButton(sender: UIButton)
}