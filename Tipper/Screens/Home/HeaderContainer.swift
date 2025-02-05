//
//  HeaderContainer.swift
//  
//
//  Created by Ryan Romanchuk on 6/13/15.
//
//

import UIKit
import MessageUI

enum ActiveScreenType: Int {
    case NotificationsScreen
    case AccountScreen
    case Unknown
}


class HeaderContainer: UIViewController, MFMailComposeViewControllerDelegate, RefreshControlDelegate {
    let className = "HeaderContainer"
    
    private var displayUSD = false
    var managedObjectContext: NSManagedObjectContext!
    var currentUser: CurrentUser!
    var market: Market!
    var activeScreenType: ActiveScreenType = .Unknown
    weak var containerDelegate : ContainerDelegate?

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var closeButtonRight: UIButton!
    @IBOutlet weak var closeButtonLeft: UIButton!
    @IBOutlet weak var notificationBadge: NotficationBadge!
    @IBOutlet weak var notificationCountLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        log.verbose("")
        displayUSD = false
        
        refreshHeader()
        updateMarkets()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive:", name: UIApplicationWillResignActiveNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: UIApplication.sharedApplication())

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        log.verbose("")
    }
    

    func refreshHeader() {
        log.verbose("")

        switch activeScreenType {
        case .AccountScreen:
            closeButtonLeft.hidden = false
            notificationsButton.hidden = true
            accountButton.tintColor = UIColor.whiteColor()
            notificationsButton.tintColor = UIColor.whiteColor()
            notificationBadge.hidden = true
            setHeaderTitle("Account")
        case .NotificationsScreen:
            closeButtonRight.hidden = false
            accountButton.hidden = true
            notificationsButton.tintColor = UIColor.whiteColor()
            notificationBadge.hidden = true
            setHeaderTitle("Notifications")
        case .Unknown:
            closeButtonLeft.hidden = true
            closeButtonRight.hidden = true
            notificationsButton.hidden = false
            accountButton.hidden = false
            accountButton.tintColor = UIColor.colorWithRGB(0x387652, alpha: 1.0)
            notificationsButton.tintColor = UIColor.colorWithRGB(0x387652, alpha: 1.0)
            setBalance()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateMarkets()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        needsToUpdateNotifications()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didTapClose(sender: UIButton) {
        log.verbose("")
        containerDelegate?.didTapClose()
        //self.performSegueWithIdentifier("ExitToHome", sender: self)
    }
    
    func setBalance() {
        log.verbose("")
        if let marketValue = currentUser.marketValue, amount = marketValue.amount where displayUSD {

            let string = "$\(amount)"
            let labelAttributes = NSMutableAttributedString(string: string)
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol-Regular", size: 40.0)!, range: NSMakeRange(0, string.characters.count))
            balanceLabel.attributedText = labelAttributes
        } else {
            let string = "a\(currentUser.balanceAsUBTC)"
            let labelAttributes = NSMutableAttributedString(string: string)
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "coiner", size: 40.0)!, range: NSMakeRange(0,1))
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol-Regular", size: 40.0)!, range: NSMakeRange(1, string.characters.count - 1))
            labelAttributes.addAttribute(NSKernAttributeName, value:-5.0, range: NSMakeRange(0, 1))
            balanceLabel.attributedText = labelAttributes
        }
    }
    
    func setHeaderTitle(title: String) {
        let labelAttributes = NSMutableAttributedString(string: title)
        labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol-Regular", size: 40.0)!, range: NSMakeRange(0, title.characters.count))
        balanceLabel.attributedText = labelAttributes
    }
    
    func updateMarkets() {
        //log.verbose("")
        market.update { [weak self] () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self?.refreshHeader()
            })
        }
        currentUser.updateBalanceUSD { [weak self] () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self?.refreshHeader()
            })
        }
    }

   
    @IBAction func didTapBalance(sender: UITapGestureRecognizer) {
        log.verbose("")
        if activeScreenType == .Unknown {
            displayUSD = !displayUSD
            setBalance()
        }
    }

    @IBAction func didTapNotifications(sender: UIButton) {
        switch activeScreenType {
        case .NotificationsScreen:
            didTapClose(sender)
        case .Unknown, .AccountScreen:
           self.parentViewController!.performSegueWithIdentifier("DidTapNotifications", sender: self)
        }
        
    }

    @IBAction func didTapAccount(sender: UIButton) {
        switch activeScreenType {
        case .AccountScreen:
            didTapClose(sender)
        case .Unknown, .NotificationsScreen:
            self.parentViewController!.performSegueWithIdentifier("DidTapAccountSegue", sender: self)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    // MARK: Notifications
    
    func needsToUpdateNotifications() {
        let notificationCount = Notification.unreadCount()
        if notificationCount > 0 {
            if activeScreenType != .NotificationsScreen {
                notificationBadge.hidden = false
            }
            notificationCountLabel.text = "\(notificationCount)"
        } else {
            notificationBadge.hidden = true
        }
    }

   

    // MARK: Application lifecycle

    func applicationWillResignActive(aNotification: NSNotification) {
        log.verbose("")
    }

    func applicationDidEnterBackground(aNotification: NSNotification) {
        log.verbose("")

    }

    func applicationDidBecomeActive(aNotification: NSNotification) {
        //log.verbose("")
        updateMarkets()
        currentUser.refreshWithDynamo { [weak self] (error) -> Void in
            if (error == nil) {
                self?.updateMarkets()
                self?.refreshHeader()
            } else if let error = error where error.code == 401 {
                self?.currentUser.resetIdentifiers()
                self?.performSegueWithIdentifier("BackToSplash", sender: self)
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        log.verbose("identifier: \(segue.identifier) screenType: \(activeScreenType.rawValue)")
        
    }
    
    
}

protocol Logoutable {
    func backToSplash()
}

protocol ContainerDelegate:class {
    func didTapClose()
}
