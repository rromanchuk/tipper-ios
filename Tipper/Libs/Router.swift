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


    case Register(String, String, String, String)
    case Cognito(String)
    case Charge(String, String)
    case Favorites
    case Me
    case Settings
    case MarketPrice(String)


    var method: Alamofire.Method {
        switch self {
        case .Register:
            return .POST
        case .Cognito:
            return .POST
        case .Charge:
            return .POST
        case .Favorites,.Me:
            return .GET
        case .MarketPrice:
            return .GET
        case .Settings:
            return .GET
        }
    }


    var URL: String {
        switch self {
        case .Register,.Me:
            return "\(APIRoot)/me"
        case .Charge:
            return "\(APIRoot)/charges"
        case .Cognito:
            return "\(APIRoot)/cognito"
        case .Favorites:
            return "https://api.twitter.com/1.1/favorites/list.json"
        case .MarketPrice:
            return "https://api.coinbase.com/v1/prices/buy"
        case .Settings:
            return "\(APIRoot)/settings"
        }
    }


    var URLParameters: [String: String] {
        switch self {
        case .Register(let username, let twitterId, let twitterAuth, let twitterSecret):
            return ["username": username, "twitter_id": twitterId, "twitter_auth_token": twitterAuth, "twitter_auth_secret": twitterSecret]
        case .Cognito(let twitterId):
            return ["twitter_id": twitterId]
        case .Charge(let token, let amount):
            return ["stripeToken": token, "amount": amount]
        case .Favorites:
            return ["count": "200", "include_entities": "false"]
        case .MarketPrice(let btc):
            return ["qty": btc]
        default:
            return [String: String]()
        }
    }


    var JSONparameters: [String: AnyObject] {
        switch self {
        case .Register(let username, let twitterId, let twitterAuth, let twitterSecret):
            return ["username": username, "twitter_id": twitterId, "twitter_auth_token": twitterAuth, "twitter_auth_secret": twitterSecret]
        case .Cognito(let twitterId):
            return ["twitter_id": twitterId]
        case .Charge(let token, let amount):
            return ["stripeToken": token, "amount": amount]
        case .MarketPrice(let btc):
            return ["qty": btc]
        default:
            return [String: AnyObject]()
        }
    }


    // MARK: URLRequestConvertible

    var URLRequest: NSURLRequest {

        var URLString = URL

        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URLString)!)
        mutableURLRequest.HTTPMethod = method.rawValue

        switch self {
        case .Register, .MarketPrice, .Settings:
            // Does't need authentication
            break
        case .Favorites:
            return Twitter.sharedInstance().APIClient.URLRequestWithMethod(method.rawValue, URL: URLString, parameters: URLParameters, error: nil)
        default:

            // Set authentication header
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let currentUser = CurrentUser.currentUser(delegate.managedObjectContext!)
            if let uuid = currentUser.uuid, token = currentUser.token {
                let authString = "\(uuid):\(token)"
                println("authString\(authString)")
                let base64EncodedString = authString.dataUsingEncoding(NSUTF8StringEncoding)!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
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