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

class TipCell: UITableViewCell {

    @IBOutlet weak var tipActionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var networkImage: UIImageView!
    @IBOutlet weak var tipAmount: UILabel!
    @IBOutlet weak var tipAmountBTC: UILabel!
    @IBOutlet weak var tipButton: UIButton!

    private var _favorite: Favorite?
    var currentUser: CurrentUser?

    
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
            let twt = TWTRTweet(JSONDictionary: _favorite!.twitterJSON)

            setupTipAmount()
            usernameLabel.text = _favorite?.toTwitterUsername
            tipAmountBTC.text = currentUser?.settings?.tipAmount

            //userProfileImage.hnk_setImageFromURL(nil)

            if _favorite!.didLeaveTip {
                tipActionLabel.text = "You tipped Marcus"
                tipButton.hidden = true
            } else {
                tipActionLabel.text = "You favorited Marcus"
                tipButton.hidden = false
            }
        }

        get {
            return _favorite
        }
    }

    func setupTipAmount() {
        if let currentUser = currentUser {
            let string = "a\(currentUser.settings!.tipAmountUBTC)"
            let labelAttributes = NSMutableAttributedString(string: string)
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "coiner", size: 18.0)!, range: NSMakeRange(0,1))
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol", size: 18.0)!, range: NSMakeRange(1, count(string) - 1))
            labelAttributes.addAttribute(NSKernAttributeName, value:-5.0, range: NSMakeRange(0, 1))
            labelAttributes.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, count(string)))
            tipAmount.attributedText = labelAttributes;
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
            request.queueUrl = ***REMOVED***
            sqs.sendMessage(request).continueWithBlock { (task) -> AnyObject! in
                if (task.error != nil) {
                    println("ERROR: \(task.error)")
                }
                return nil
            }
            
        }
    }




}
