//
//  TweetCell.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/26/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import TwitterKit

class TweetCell: UITableViewCell {

    @IBOutlet weak var tweetView: TWTRTweetView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
