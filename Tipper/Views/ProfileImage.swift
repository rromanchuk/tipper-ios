//
//  ProfileImage.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 10/7/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class ProfileImage: UIImageView {

    override func awakeFromNib() {
        layer.cornerRadius = 20.0
        layer.masksToBounds = true
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
