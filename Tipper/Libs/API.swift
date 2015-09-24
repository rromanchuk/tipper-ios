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
        //println("\(className)::\(__FUNCTION__) req:\(req)")
        //req.res
        
        req.responseJSON { (request, response, json) -> Void in
            
            if let response = response where response == 401 {
                print("Received 401 UNAUTHORIZED FROM USER")
                NSNotificationCenter.defaultCenter().postNotificationName("UNAUTHORIZED_USER", object: nil)
                completion?(json: nil, error: nil)
            } else {
                if let jsonData = json.value {
                    completion?(json: JSON(jsonData), error: nil)
                }
            }
        }
    }
    
    func register(username: String, twitterId: String, twitterAuth: String, twitterSecret: String, profileImage: String, completion: ((json: JSON, error: NSError?) -> Void)!) {
        print("\(className)::\(__FUNCTION__)")
        self.call(self.manager.request(Router.Register(username, twitterId, twitterAuth, twitterSecret, profileImage)), completion: completion)
    }
    
    func autotip(completion: ((json: JSON, error: NSError?) -> Void)!) {
        print("\(className)::\(__FUNCTION__)")
        self.call(self.manager.request(Router.AutoTip), completion: completion)
    }

    func disconnect(completion: ((json: JSON, error: NSError?) -> Void)!) {
        print("\(className)::\(__FUNCTION__)")
        self.call(self.manager.request(Router.Disconnect), completion: completion)
    }

    func connect(completion: ((json: JSON, error: NSError?) -> Void)!) {
        print("\(className)::\(__FUNCTION__)")
        self.call(self.manager.request(Router.Connect), completion: completion)
    }

    func address(completion: ((json: JSON, error: NSError?) -> Void)!) {
        print("\(className)::\(__FUNCTION__)")
        self.call(self.manager.request(Router.Address), completion: completion)
    }

    func charge(token: String, amount: String, completion: ((json: JSON, error: NSError?) -> Void)!) {
        print("\(className)::\(__FUNCTION__)")
        self.call(self.manager.request(Router.Charge(token, amount)), completion: completion)
    }

    func favorites(completion: ((json: JSON, error: NSError?) -> Void)!) {
        print("\(className)::\(__FUNCTION__)")
        self.call(self.manager.request(Router.Favorites), completion: completion)
    }

    func me(completion: ((json: JSON, error: NSError?) -> Void)!) {
        print("\(className)::\(__FUNCTION__)")
        self.call(self.manager.request(Router.Me), completion: completion)
    }

    func settings(completion: ((json: JSON, error: NSError?) -> Void)!) {
        print("\(className)::\(__FUNCTION__)")
        self.call(self.manager.request(Router.Settings), completion: completion)
    }

    func market(btc: String, completion: ((json: JSON, error: NSError?) -> Void)!) {
        print("\(className)::\(__FUNCTION__)")
        self.call(self.manager.request(Router.MarketPrice(btc)), completion: completion)
    }

    func balance(completion: ((json: JSON, error: NSError?) -> Void)!) {
        print("\(className)::\(__FUNCTION__)")
        self.call(self.manager.request(Router.Balance), completion: completion)
    }

}