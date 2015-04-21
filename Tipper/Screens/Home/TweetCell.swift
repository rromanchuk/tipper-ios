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

    var currentUser: CurrentUser!
    var favorite: Favorite!

    @IBOutlet weak var tipConfirmedButton: UIButton!
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

    @IBAction func userDidTip(sender: UIButton) {
        let sqs = AWSSQS.defaultSQS()
        let request = AWSSQSSendMessageRequest()

        println("favorite:\(favorite), currentUser:\(currentUser)")
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
