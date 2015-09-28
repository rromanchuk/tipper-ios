//
//  OnboardingPageControllerViewController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/26/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class OnboardingPageControllerViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, OnboardingDelegate {
    var provider: AWSCognitoCredentialsProvider!
    var currentUser: CurrentUser!
    var className = "OnboardingPageControllerViewController"
    var managedObjectContext: NSManagedObjectContext?
    var market: Market?
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
        
        
        setupViewControllers()
        self.setViewControllers([self.pages[0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        
        // Do any additional setup after loading the view.
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {

        if let _ = pendingViewControllers[0] as? OnboardPartTwo {
            containerController?.pageControl.hidden = false
            containerController?.pageControl.currentPage = 0
            containerController?.twitterLoginButton.setTitle("Next", forState: .Normal)
        } else if let _ = pendingViewControllers[0] as? OnboardPartThree {
            containerController?.pageControl.hidden = false
            containerController?.pageControl.currentPage = 1
            containerController?.twitterLoginButton.setTitle("Buy with Apple Pay", forState: .Normal)
        } else if let _ = pendingViewControllers[0] as? OnboardPartFour {
            containerController?.pageControl.currentPage = 2
            containerController?.twitterLoginButton.setTitle("Allow Notifications", forState: .Normal)
        } else if let _ = pendingViewControllers[0] as? OnboardPartFive {
            containerController?.pageControl.currentPage = 3
            containerController?.twitterLoginButton.setTitle("Next", forState: .Normal)
        } else if let _ = pendingViewControllers[0] as? OnboardPartOne {
            containerController?.twitterLoginButton.setTitle("  Sign in with Twitter", forState: .Normal)
        }
    }
    
    func autoAdvance() {
        print("\(className)::\(__FUNCTION__)")
        containerController?.twitterLoginButton.setImage(nil, forState: .Normal)
        let vc = viewControllers![0]
        let idx = pages.indexOf(vc)!
        
        if (idx + 1) < pages.count {
            self.setViewControllers([pages[idx + 1]], direction: .Forward, animated: true, completion: nil)
        } else if (idx + 1) == pages.count {
            containerController?.performSegueWithIdentifier("Home", sender: self)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        print("\(className)::\(__FUNCTION__) currentIndex: \(pages.indexOf(viewController)),  allPages: \(self.pages)")
        if let currentIndex = pages.indexOf(viewController) where (currentIndex - 1) >= pages.count {
            let newIndex = currentIndex - 1
            if newIndex == 0 {
                return nil
            }else if newIndex >= pages.count {
                return pages[newIndex]
            } else {
                return nil
            }
            
        } else {
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        print("\(className)::\(__FUNCTION__) currentIndex: \(pages.indexOf(viewController)),  allPages: \(self.pages)")
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
        print("\(className)::\(__FUNCTION__)")
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