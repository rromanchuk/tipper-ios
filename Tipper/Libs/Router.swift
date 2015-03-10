//
//  Router.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/8/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation


enum Router: URLRequestConvertible {

    static var links = [String: String]()


    case Register(String)


    var method: Method {
        switch self {
        case .Register:
            return .GET
        }
    }


    var URL: String {
        switch self {
        case .Register:
            return "http://coinbit.tips/me"
        }
    }


    var URLParameters: [String: String] {
        switch self {
        case .Register(let token):
            return ["token": token]
        default:
            return [String: String]()
        }
    }


    var JSONparameters: [String: AnyObject] {
        switch self {
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
        case .Register:
            // Does't need authentication
            break
        default:
            println("")
            // Set authentication header
//            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
//            let currentUser = CurrentUser.currentUser(delegate.managedObjectContext!)
//            let authString = "\(currentUser.identifier):\(currentUser.token!)"
//            let base64EncodedString = authString.dataUsingEncoding(NSUTF8StringEncoding)!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
//            mutableURLRequest.setValue("Basic \(base64EncodedString)", forHTTPHeaderField: "Authorization")
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