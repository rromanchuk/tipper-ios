//
//  TweetCell.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/26/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import TwitterKit
import SwiftyJSON

class TweetCell: UITableViewCell {

    var currentUser: CurrentUser?
    var favorite: Favorite!

    @IBOutlet weak var tipButton: UIButton!
    @IBOutlet weak var tweetView: TWTRTweetView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

    @IBAction func userDidTip(sender: UIButton) {
        tipButton.backgroundColor = UIColor.grayColor()
        favorite.didLeaveTip = true

        let sqs = AWSSQS.defaultSQS()
        let request = AWSSQSSendMessageRequest()

        //println("favorite:\(favorite), currentUser:\(currentUser)")
        if let currentUser = currentUser {
            var tipDict = ["TweetID": favorite.tweetId, "FromTwitterID": currentUser.uuid!, "ToTwitterID": favorite.toTwitterId, "FromUserID": currentUser.userId! ]
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

    func setupTipButton() {
        if let currentUser = currentUser {
            let string = "a\(currentUser.settings!.tipAmountUBTC)"
            let labelAttributes = NSMutableAttributedString(string: string)
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "coiner", size: 18.0)!, range: NSMakeRange(0,1))
            labelAttributes.addAttribute(NSFontAttributeName, value: UIFont(name: "Bariol", size: 18.0)!, range: NSMakeRange(1, count(string) - 1))
            labelAttributes.addAttribute(NSKernAttributeName, value:-5.0, range: NSMakeRange(0, 1))
            labelAttributes.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, count(string)))
            tipButton.setAttributedTitle(labelAttributes, forState: .Normal)
        }
    }
}
