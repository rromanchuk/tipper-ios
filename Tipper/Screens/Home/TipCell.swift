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

enum TipCellType: Int {
    case Sent
    case Received
}

class TipCell: UITableViewCell {

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
        userProfileImage.layer.cornerRadius = 20
        userProfileImage.layer.masksToBounds = true
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    var favorite:Favorite! {
        set {
            _favorite = newValue
            let twt = TWTRTweet(JSONDictionary: _favorite!.twitterJSON)
            twt.author.profileImageLargeURL
            setupTipAmount()
            usernameLabel.text = "@\(_favorite!.toTwitterUsername)"
           

            if _favorite?.fromTwitterId  == currentUser?.uuid {
                if let urlString = twt.author.profileImageLargeURL, url = NSURL(string: urlString) {
                    userProfileImage.hnk_setImageFromURL(url)
                }

                if _favorite!.didLeaveTip {
                    tipArrow.hidden = false
                    tipArrow.image = UIImage(named: "down-arrow")
                    tipActionLabel.text = "You tipped \(twt.author.name)"
                    tipButton.hidden = true
                    tipAmount.hidden = false
                    tipAmountBTC.hidden = false
                } else {
                    tipArrow.hidden = true
                    tipActionLabel.text = "You favorited \(twt.author.name)"
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
            }

            timeLabel.text = formatter.stringFromDate(_favorite!.createdAt)
        }

        get {
            return _favorite
        }
    }

    func setupTipAmount() {
        if let currentUser = currentUser {
            let string = "a\(Settings.sharedInstance.tipAmountUBTC)"
            let labelAttributes = NSMutableAttributedString(string: string)
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "coiner", size: 18.0)!, range: NSMakeRange(0,1))
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol", size: 18.0)!, range: NSMakeRange(1, count(string) - 1))
            labelAttributes.addAttribute(NSKernAttributeName, value:-5.0, range: NSMakeRange(0, 1))
            labelAttributes.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, count(string)))
            tipAmount.attributedText = labelAttributes;
            
            if let tipAmount = Settings.sharedInstance.tipAmount {
                tipAmountBTC.text = "BTC \(tipAmount)"
            }
            
        }
    }

    @IBAction func userDidTip(sender: UIButton) {
        //println("favorite:\(favorite), currentUser:\(currentUser)")
        tipButton.backgroundColor = UIColor.grayColor()
        favorite.didLeaveTip = true

        let sqs = AWSSQS.defaultSQS()
        let request = AWSSQSSendMessageRequest()

        if let currentUser = currentUser {
            var tipDict = ["TweetID": favorite.tweetId, "FromTwitterID": currentUser.uuid!, "ToTwitterID": favorite.toTwitterId ]
            let jsonTipDict = NSJSONSerialization.dataWithJSONObject(tipDict, options: nil, error: nil)
            let json: String = NSString(data: jsonTipDict!, encoding: NSUTF8StringEncoding) as! String


            request.messageBody = json
            request.queueUrl = Config.get("SQS_NEW_TIP")
            sqs.sendMessage(request).continueWithBlock { (task) -> AnyObject! in
                println("Result: \(task.result) Error \(task.error), Exception: \(task.exception)")
                if (task.error != nil) {
                    println("ERROR: \(task.error)")
                }
                return nil
            }
            
        }
    }




}
