//
//  Segues.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 11/11/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
enum CustomModalSegues: String {
    case Notifications        = "DidTapNotifications"
    case Account              = "DidTapAccountSegue"
}

enum CustomPushSegues: String {
    case TipDetails     = "TipDetails"
}

enum ExitSegues: String {
    case ToHomeFromAccount = "ExitToHomeFromAccount"
    case ToSplash = "BackToSplash"
}