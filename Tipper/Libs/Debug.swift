//
//  Debug.swift
//  Today
//
//  Created by Ryan Romanchuk on 2/23/15.
//  Copyright (c) 2015 Frontback. All rights reserved.
//

import Foundation
class Debug {
    class func isBlocking() {
        if !NSThread.isMainThread() {
            NSException(name:"Thread assertion", reason:"Not on main thread.", userInfo:nil).raise()
        }
    }

    class func nonBlocking() {
        if NSThread.isMainThread() {
            NSException(name:"Running on main thread.", reason:"Not on main thread.", userInfo:nil).raise()
        }
    }
}