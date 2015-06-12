//
//  API.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/8/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public class API {

    
    let className = "API"
    public static let sharedInstance: API = API()

    let manager: Manager = {
        var headers = Manager.defaultHTTPHeaders
        headers["Accept"] = "application/json"

        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = headers

        return Manager(configuration: configuration)
    }()

    func call(req: Request, completion: ((json: JSON, error: NSError?) -> Void)?) {
        println("\(className)::\(__FUNCTION__) req:\(req)")

        req.validate().responseSwiftyJSON( { (request, response, JSON, error) -> Void in
            println(TTTURLRequestFormatter.cURLCommandFromURLRequest(request))
            //println("API Call: request:\(request), response:\(response), JSON:\(JSON), error:\(error)")
            if let error = error {
                if let response = response where response == 401 {
                    println("Received 401 UNAUTHORIZED FROM USER")
                    NSNotificationCenter.defaultCenter().postNotificationName("UNAUTHORIZED_USER", object: nil)
                }

                completion?(json: nil, error: error)
            } else {
                completion?(json: JSON, error: nil)
            }
        })

        //        debugPrintln(req)
    }



//    func cognitoIdentity() {
//        request(.GET, "http://httpbin.org/get", parameters: ["foo": "bar"])
//            .responseSwiftyJSON { (request, response, json, error) in
//                println(json)
//                println(error)
//        }
////        .responseSwiftyJSON { (request, response, JSON, error) in
////            println(request)
////            println(response)
////            println(error)
////            //completion()
////        }
//    }

    func register(username: String, twitterId: String, twitterAuth: String, twitterSecret: String, profileImage: String, completion: ((json: JSON, error: NSError?) -> Void)!) {
        println("\(className)::\(__FUNCTION__)")
        self.call(self.manager.request(Router.Register(username, twitterId, twitterAuth, twitterSecret, profileImage)), completion: completion)
    }

    func charge(token: String, amount: String, completion: ((json: JSON, error: NSError?) -> Void)!) {
        println("\(className)::\(__FUNCTION__)")
        self.call(self.manager.request(Router.Charge(token, amount)), completion: completion)
    }

    func favorites(completion: ((json: JSON, error: NSError?) -> Void)!) {
        println("\(className)::\(__FUNCTION__)")
        self.call(self.manager.request(Router.Favorites), completion: completion)
    }

    func me(completion: ((json: JSON, error: NSError?) -> Void)!) {
        println("\(className)::\(__FUNCTION__)")
        self.call(self.manager.request(Router.Me), completion: completion)
    }

    func settings(completion: ((json: JSON, error: NSError?) -> Void)!) {
        println("\(className)::\(__FUNCTION__)")
        self.call(self.manager.request(Router.Settings), completion: completion)
    }

    func cognito(twitterId: String,  completion: ((json: JSON, error: NSError?) -> Void)!) {
        println("\(className)::\(__FUNCTION__)")
        self.call(self.manager.request(Router.Cognito(twitterId)), completion: completion)
    }

    func market(btc: String, completion: ((json: JSON, error: NSError?) -> Void)!) {
        println("\(className)::\(__FUNCTION__)")
        self.call(self.manager.request(Router.MarketPrice(btc)), completion: completion)
    }

}