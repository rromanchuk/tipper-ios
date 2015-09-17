//
//  NotificationCell.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/16/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

enum NotificationCellType: Int {
    case LowBalance
    case TipSent
    case TipReceived
}

class NotificationCell: UITableViewCell {

    @IBOutlet weak var notificationTitleLabel: UILabel!
    @IBOutlet weak var notificationTextLabel: UILabel!
    @IBOutlet weak var notificationImage: UIImageView!
    
    private var _notification: Notification?
    
    var notification:Notification? {
        set {
            _notification = newValue
            
            notificationTitleLabel.text = _notification?.text
            
        }
        get {
            return _notification
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
