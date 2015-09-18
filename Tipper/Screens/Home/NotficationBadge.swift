//
//  NotficationBadge.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/17/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class NotficationBadge: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        layer.cornerRadius = 10
    }

}
