//
//  Config.swift
//  Today
//
//  Created by Ryan Romanchuk on 2/18/15.
//  Copyright (c) 2015 Frontback. All rights reserved.
//

import Foundation

class Config {

    class func get(keyname:String) -> String {
        return Config.valueForKey(keyname)
    }

    class func valueForKey(keyname:String) -> String {
        // Credit to the original source for this technique at
        // http://blog.lazerwalker.com/blog/2014/05/14/handling-private-api-keys-in-open-source-ios-apps
        let text = NSBundle.mainBundle().infoDictionary?[keyname] as? String
        return text!
    }

    class func dump() {
        println("---------------- CURRENT CONFIGURATION ----------------")
        for (myKey, myValue) in NSBundle.mainBundle().infoDictionary! {
            if let value: String = myValue as? String {
                println("\(myKey) = \(value)")
            }
        }
        println("---------------- END CONFIGURATION ----------------")
    }
}