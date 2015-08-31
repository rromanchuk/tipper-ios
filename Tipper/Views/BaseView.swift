//
//  BaseView.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 8/31/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class BaseView: UIView {
    
    override func awakeFromNib() {
        backgroundColor = UIColor.brandColor()
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
