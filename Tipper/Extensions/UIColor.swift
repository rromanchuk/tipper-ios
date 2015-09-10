//
//  UIColor.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/26/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
extension UIColor {
    
    class func brandColor() -> UIColor {
        return UIColor.colorWithRGB(0x5BBC84, alpha: 1.0)
    }
    /**
    Construct a UIColor using an HTML/CSS RGB formatted value and an alpha value

    - parameter rgbValue: RGB value
    - parameter alpha: color alpha value

    - returns: an UIColor instance that represent the required color
    */
    class func colorWithRGB(rgbValue : UInt, alpha : CGFloat = 1.0) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let green = CGFloat((rgbValue & 0xFF00) >> 8) / 255
        let blue = CGFloat(rgbValue & 0xFF) / 255

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    /**
    Returns a lighter color by the provided percentage

    - parameter lighting: percent percentage
    - returns: lighter UIColor
    */
    func lighterColor(percent : Double) -> UIColor {
        return colorWithBrightnessFactor(CGFloat(1 + percent));
    }

    /**
    Returns a darker color by the provided percentage

    - parameter darking: percent percentage
    - returns: darker UIColor
    */
    func darkerColor(percent : Double) -> UIColor {
        return colorWithBrightnessFactor(CGFloat(1 - percent));
    }

    /**
    Return a modified color using the brightness factor provided

    - parameter factor: brightness factor
    - returns: modified color
    */
    func colorWithBrightnessFactor(factor: CGFloat) -> UIColor {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0

        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness * factor, alpha: alpha)
        } else {
            return self;
        }
    }
}