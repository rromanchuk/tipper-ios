//
//  TipCell.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 6/5/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import Haneke
import TwitterKit
import AWSSQS

enum TipCellType: Int {
    case Sent
    case Received
}

class TipCell: UITableViewCell {
    let className = "TipCell"

    @IBOutlet weak var tipActionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var networkImage: UIImageView!
    @IBOutlet weak var tipAmount: UILabel!
    @IBOutlet weak var tipAmountBTC: UILabel!
    @IBOutlet weak var tipButton: UIButton!

    @IBOutlet weak var tipArrow: UIImageView!
    private var _favorite: Favorite?
    lazy var formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter
    }()

    var currentUser: CurrentUser?
    var type: TipCellType = .Sent

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    var favorite:Favorite! {
        set {
            _favorite = newValue

            setupTipAmount()
            
            log.info(" \(_favorite?.fromTwitterId)  == \(currentUser?.twitterUserId)")
            log.info("favorite: \(favorite)")
            log.info("user: \(currentUser!)")

            if _favorite?.fromTwitterId  == currentUser?.twitterUserId {
                if let urlString = favorite.toTwitterProfileImage, url = NSURL(string: urlString) {
                    userProfileImage.hnk_setImageFromURL(url)
                }
                usernameLabel.text = "@\(_favorite!.toTwitterUsername)"
                if _favorite!.didLeaveTip {
                    tipArrow.hidden = false
                    tipArrow.image = UIImage(named: "down-arrow")
                    tipActionLabel.text = "You tipped \(favorite.toTwitterUsername)"
                    tipButton.hidden = true
                    tipAmount.hidden = false
                    tipAmountBTC.hidden = false
                } else {
                    tipArrow.hidden = true
                    tipActionLabel.text = "You favorited \(favorite.toTwitterUsername)"
                    tipButton.hidden = false
                    tipAmount.hidden = true
                    tipAmountBTC.hidden = true
                }

            } else {
                if let urlString = _favorite!.fromTwitterProfileImage, url = NSURL(string: urlString) {
                    userProfileImage.hnk_setImageFromURL(url)
                }
                tipArrow.image = UIImage(named: "up-arrow")
                tipButton.hidden = true
                tipActionLabel.text = "\(_favorite!.fromTwitterUsername) sent you a tip"
                tipAmount.hidden = false
                tipAmountBTC.hidden = false
                usernameLabel.text = "@\(_favorite!.fromTwitterUsername)"
            }

            timeLabel.text = formatter.stringFromDate(_favorite!.createdAt)
        }

        get {
            return _favorite
        }
    }

    func setupTipAmount() {
        if let currentUser = currentUser {
            let string = "a\(Settings.sharedInstance.tipAmountUBTC!)"
            let labelAttributes = NSMutableAttributedString(string: string)
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "coiner", size: 18.0)!, range: NSMakeRange(0,1))
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol", size: 18.0)!, range: NSMakeRange(1, string.characters.count - 1))
            labelAttributes.addAttribute(NSKernAttributeName, value:-5.0, range: NSMakeRange(0, 1))
            labelAttributes.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, string.characters.count))
            tipAmount.attributedText = labelAttributes;
            
            if let tipAmount = Settings.sharedInstance.tipAmount {
                tipAmountBTC.text = "BTC \(tipAmount)"
            }
            
        }
    }

    @IBAction func userDidTip(sender: UIButton) {
        log.verbose("")
        tipButton.backgroundColor = UIColor.grayColor()
        favorite.didLeaveTip = true

        let sqs = AWSSQS.defaultSQS()
        let request = AWSSQSSendMessageRequest()

        if let currentUser = currentUser {
            let tipDict = ["TweetID": favorite.tweetId, "FromTwitterID": currentUser.twitterUserId!, "ToTwitterID": favorite.toTwitterId ]
            let jsonTipDict = try? NSJSONSerialization.dataWithJSONObject(tipDict, options: [])
            let json: String = NSString(data: jsonTipDict!, encoding: NSUTF8StringEncoding) as! String


            request.messageBody = json
            request.queueUrl = Config.get("SQS_NEW_TIP")
            sqs.sendMessage(request).continueWithBlock { (task) -> AnyObject! in
                log.info("Result: \(task.result) Error \(task.error), Exception: \(task.exception)")
                if (task.error != nil) {
                    log.error("ERROR: \(task.error)")
                }
                return nil
            }
            
        }
    }




}
