//
//  HeaderContainer.swift
//  
//
//  Created by Ryan Romanchuk on 6/13/15.
//
//

import UIKit
import MessageUI

class HeaderContainer: UIViewController, MFMailComposeViewControllerDelegate, RefreshControlDelegate {
    let className = "HeaderContainer"
    
    private var displayUSD = false
    var managedObjectContext: NSManagedObjectContext!
    var currentUser: CurrentUser!
    var market: Market!
    var showBalanceBTC = false

    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var walletButton: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var btcLabel: UILabel!

    lazy var actionSheet: UIAlertController = {
        let _actionController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        if let popoverController = _actionController.popoverPresentationController {
            popoverController.sourceView = self.settingsButton
            popoverController.sourceRect = self.settingsButton.bounds
        }



        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { [weak self] (action) in
            println("\(self?.className)::\(__FUNCTION__) cancelAction")
        }
        _actionController.addAction(cancelAction)

        let destroyAction = UIAlertAction(title: "Logout", style: .Destructive) { [weak self] (action) in
            println("\(self?.className)::\(__FUNCTION__) destroyAction")
            
            if let vc = self?.parentViewController as? Logoutable {
                vc.backToSplash()
            }
        }

        let disconnectAction = UIAlertAction(title: "Stop automatic tipping", style: .Destructive) { [weak self] (action) in
            println("\(self?.className)::\(__FUNCTION__) destroyAction")
            self?.currentUser.disconnect()
        }


        let feedbackAction = UIAlertAction(title: "Feedback and Support", style: .Default, handler: { [weak self] (action) -> Void in
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject("Feedback and Support")
            mailComposer.setToRecipients(["support@coinbit.tips"])
            self?.presentViewController(mailComposer, animated:true, completion: nil)
        })

        let refetchFeedAction = UIAlertAction(title: "Refetch feed", style: .Default, handler: { [weak self] (action) -> Void in
            self?.currentUser.refetchFeeds { (error) -> Void in
                println("\(error)")
            }
        })

        //_actionController.addAction(refetchFeedAction)
        _actionController.addAction(feedbackAction)
        _actionController.addAction(destroyAction)
        _actionController.addAction(disconnectAction)
        return _actionController
    }()

    

    override func viewDidLoad() {
        super.viewDidLoad()
        println("\(className)::\(__FUNCTION__)")
        displayUSD = false
        updateMarkets()


        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive:", name: UIApplicationWillResignActiveNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: UIApplication.sharedApplication())

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refreshUI()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setBalance() {
        println("\(className)::\(__FUNCTION__)")
        if let marketValue = currentUser.marketValue, amount = marketValue.amount where displayUSD {

            let string = "$\(amount)"
            let labelAttributes = NSMutableAttributedString(string: string)
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol-Regular", size: 40.0)!, range: NSMakeRange(0, count(string)))
            balanceLabel.attributedText = labelAttributes
        } else {
            let string = "a\(currentUser.balanceAsUBTC)"
            let labelAttributes = NSMutableAttributedString(string: string)
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "coiner", size: 40.0)!, range: NSMakeRange(0,1))
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol-Regular", size: 40.0)!, range: NSMakeRange(1, count(string) - 1))
            labelAttributes.addAttribute(NSKernAttributeName, value:-5.0, range: NSMakeRange(0, 1))
            balanceLabel.attributedText = labelAttributes
            if let btcBalance = currentUser.bitcoinBalanceBTC {
                btcLabel.text = "BTC \(btcBalance)"
            }

        }


    }

    func refreshUI() {
        println("\(className)::\(__FUNCTION__)")
        Debug.isBlocking()
        managedObjectContext.refreshObject(currentUser, mergeChanges: true)
        setBalance()
    }

    func updateMarkets() {
        println("\(className)::\(__FUNCTION__)")
        market.update { [weak self] () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self?.refreshUI()
            })
        }
        currentUser.updateBalanceUSD { [weak self] () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self?.refreshUI()
            })
        }
    }

    @IBAction func didTapSettings(sender: UIButton) {
        println("\(className)::\(__FUNCTION__)")
        self.presentViewController(actionSheet, animated: true) {
            // ...
        }
    }

    @IBAction func didTapBalance(sender: UITapGestureRecognizer) {
        println("\(className)::\(__FUNCTION__)")
        displayUSD = !displayUSD
        setBalance()

    }

    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismissViewControllerAnimated(true, completion:nil)
    }

   

    // MARK: Application lifecycle

    func applicationWillResignActive(aNotification: NSNotification) {
        println("\(className)::\(__FUNCTION__)")
    }

    func applicationDidEnterBackground(aNotification: NSNotification) {
        println("\(className)::\(__FUNCTION__)")

    }

    func applicationDidBecomeActive(aNotification: NSNotification) {
        println("\(className)::\(__FUNCTION__)")
        updateMarkets()
        currentUser.refreshWithDynamo { [weak self] (error) -> Void in
            if (error == nil) {
                self?.updateMarkets()
                self?.refreshUI()
            } else if let error = error where error.code == 401 {
                self?.currentUser.resetIdentifiers()
                self?.performSegueWithIdentifier("BackToSplash", sender: self)
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("\(className)::\(__FUNCTION__) identifier: \(segue.identifier)")
        if segue.identifier == "Wallet" {
            let vc = segue.destinationViewController as! WalletContainerController
            vc.managedObjectContext = managedObjectContext
            vc.currentUser = currentUser
            vc.market = market
        }
    }

}

protocol Logoutable {
    func backToSplash()
}
