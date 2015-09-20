//
//  NotificationCell.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/16/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

enum NotificationCellType: String {
    case LowBalance     = "low_balance"
    case TipSent        = "user_sent_tip"
    case TipReceived    = "user_received_tip"
    case Withdrawal     = "withdrawal_event"
    case FundEvent      = "fund_event"
    case TipConfirmed   = "tip_confirmed"

    func titleText() -> String {
        switch self {
        case .LowBalance:
            return "Insufficient funds."
        case .TipSent:
            return "Tip sent."
        case .TipReceived:
            return "You’ve been tipped."
        case .Withdrawal:
            return "Withdrawal event completed."
        case .FundEvent:
            return "Funding event completed."
        case .TipConfirmed:
            return "Transaction confirmed."
        }
    }
    
    func image() -> String {
        switch self {
        case .LowBalance:
            return "problem"
        case .TipSent:
            return "tip-received"
        case .TipReceived:
            return "tip-received"
        case .Withdrawal:
            return "fund-event"
        case .FundEvent:
            return "fund-event"
        case .TipConfirmed:
            return "transaction-confirmed"
        }
    }
}

class NotificationCell: UITableViewCell {

    @IBOutlet weak var notificationTitleLabel: UILabel!
    @IBOutlet weak var notificationTextLabel: UILabel!
    @IBOutlet weak var notificationImage: UIImageView!
    @IBOutlet weak var indicatorView: NotificationSeenIndicator!
    
    private var _notification: Notification?
    
    var notification:Notification? {
        set {
            _notification = newValue
            if let notificationType = NotificationCellType(rawValue: _notification!.type) {
                notificationTitleLabel.text = notificationType.titleText()
                notificationTextLabel.text = _notification?.text
                notificationImage.image = UIImage(named: notificationType.image())
                if notification?.seenAt == nil {
                    indicatorView.hidden = false
                } else {
                    indicatorView.hidden = true
                }
                
            }
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
