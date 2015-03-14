//
//  API.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/8/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation

public class API {

    
    let className = "API"
    public static let sharedInstance: API = API()

    let manager: Manager = {
        var headers = Manager.defaultHTTPHeaders
        headers["Accept"] = "application/json"
        //headers["User-Agent"] = "\(Device.bundleName)/\(Device.appVersion).\(Device.bundleVersion) (iOS \(Device.osVersion))" // Today/1.5.0.3945 (iOS 8.3)

        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = headers

        return Manager(configuration: configuration)
    }()

    func call(req: Request, completion: ((json: JSON, error: NSError?) -> Void)?) {
        //println("\(className)::\(__FUNCTION__) req:\(req)")

        req.validate().responseSwiftyJSON( { (request, response, JSON, error) -> Void in
            //println(TTTURLRequestFormatter.cURLCommandFromURLRequest(request))
            //println("API Call: request:\(request), response:\(response), JSON:\(JSON), error:\(error)")
            if error != nil {
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

    func register(token: String, completion: ((json: JSON, error: NSError?) -> Void)!) {
        self.call(self.manager.request(Router.Register(token)), completion: completion)
    }

    func charge(token: String, completion: ((json: JSON, error: NSError?) -> Void)!) {
        self.call(self.manager.request(Router.Charge(token)), completion: completion)
    }

    func favorites(completion: ((json: JSON, error: NSError?) -> Void)!) {
        self.call(self.manager.request(Router.Favorites), completion: completion)
    }



}