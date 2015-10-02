//
//  Router.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/8/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
import TwitterKit
import SwiftyJSON
import Alamofire

let APIRoot = Config.get("API_ROOT_URL")

enum Router: URLRequestConvertible {

    static var links = [String: String]()

    case Disconnect
    case Connect
    case Address
    case Charge(String, String)
    case MarketPrice(String)
    case Balance
    case AutoTip

    var method: Alamofire.Method {
        switch self {
        case .Address, .Connect:
            return .POST
        case .Charge,.AutoTip:
            return .POST
        case .MarketPrice,.Balance:
            return .GET
        case .Disconnect:
            return .DELETE
        }
    }


    var URL: String {
        switch self {
        case .Disconnect:
            return "\(APIRoot)/disconnect"
        case .Connect:
            return "\(APIRoot)/connect"
        case .Address:
            return "\(APIRoot)/address"
        case .Charge:
            return "\(APIRoot)/charges"
        case .AutoTip:
            return "\(APIRoot)/autotip"
        case .MarketPrice:
            return "https://api.coinbase.com/v1/prices/buy"
        case .Balance:
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            return "https://bitcoin.toshi.io/api/v0/addresses/\(CurrentUser.currentUser(delegate.managedObjectContext).bitcoinAddress!)" //https://bitcoin.toshi.io/api/v0/addresses/1G8f1EeFKq1ueXCSHJ8zwoZ6YBCrnCpaAP

        }
    }


    var URLParameters: [String: String] {
        switch self {
        case .Charge(let token, let amount):
            return ["stripeToken": token, "amount": amount]
        case .MarketPrice(let btc):
            return ["qty": btc]
        default:
            return [String: String]()
        }
    }


    var JSONparameters: [String: AnyObject] {
        switch self {
        case .Charge(let token, let amount):
            return ["stripeToken": token, "amount": amount]
        case .MarketPrice(let btc):
            return ["qty": btc]
        default:
            return [String: AnyObject]()
        }
    }


    // MARK: URLRequestConvertible

    var URLRequest: NSMutableURLRequest {
        
        let URLString = URL
        
        
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URLString)!)
        mutableURLRequest.HTTPMethod = method.rawValue
        
        switch self {
        case .MarketPrice, .Balance:
            // Does't need authentication
            break
        default:
            
            // Set authentication header
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let currentUser = CurrentUser.currentUser(delegate.managedObjectContext)
            if let uuid = currentUser.twitterUserId, token = Twitter.sharedInstance().sessionStore.session()?.authToken {
                let authString = "\(uuid):\(token)"
                log.verbose("authString\(authString)")
                let base64EncodedString = authString.dataUsingEncoding(NSUTF8StringEncoding)!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
                mutableURLRequest.setValue("Basic \(base64EncodedString)", forHTTPHeaderField: "Authorization")
            }
        }
        
        switch method {
        case .POST, .PUT, .PATCH:
            return ParameterEncoding.JSON.encode(mutableURLRequest, parameters: JSONparameters).0
        default:
            return ParameterEncoding.URL.encode(mutableURLRequest, parameters: URLParameters).0
        }
    }
}

class StringTemplate {

    class func render(var str: String, dict: [String: String]) -> String {
        for (key, value) in dict {
            str = str.stringByReplacingOccurrencesOfString(":\(key)", withString: value)
        }
        return str
    }

}