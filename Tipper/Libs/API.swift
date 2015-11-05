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
        debugPrint(req)
        req.responseJSON { (request, response, json) -> Void in
            
            if let response = response where response == 401 {
                log.error("Received 401 UNAUTHORIZED FROM USER")
                NSNotificationCenter.defaultCenter().postNotificationName("UNAUTHORIZED_USER", object: nil)
                completion?(json: nil, error: nil)
            } else {
                if let jsonData = json.value {
                    completion?(json: JSON(jsonData), error: nil)
                }
            }
        }
    }
    
    func autotip(completion: ((json: JSON, error: NSError?) -> Void)!) {
        log.verbose("")
        self.call(self.manager.request(Router.AutoTip), completion: completion)
    }

    func disconnect(completion: ((json: JSON, error: NSError?) -> Void)!) {
        log.verbose("")
        self.call(self.manager.request(Router.Disconnect), completion: completion)
    }

    func connect(completion: ((json: JSON, error: NSError?) -> Void)!) {
        log.verbose("")
        self.call(self.manager.request(Router.Connect), completion: completion)
    }

    func charge(token: String, amount: String, completion: ((json: JSON, error: NSError?) -> Void)!) {
        log.verbose("")
        self.call(self.manager.request(Router.Charge(token, amount)), completion: completion)
    }


    func market(btc: String, completion: ((json: JSON, error: NSError?) -> Void)!) {
        //log.verbose()
        self.call(self.manager.request(Router.MarketPrice(btc)), completion: completion)
    }

    func balance(completion: ((json: JSON, error: NSError?) -> Void)!) {
        log.verbose("")
        self.call(self.manager.request(Router.Balance), completion: completion)
    }
}