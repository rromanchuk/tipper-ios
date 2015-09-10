//
//  TintedButton.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/30/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class TintedButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        TintedButton.setup(self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        TintedButton.setup(self)
    }

    private class func setup(button: TintedButton) {
        var image = button.imageForState(.Normal)!
        image = image.imageWithRenderingMode(.AlwaysTemplate)
        button.setImage(image, forState: .Normal)
    }


}
