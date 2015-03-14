//
//  TwitterAuth.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/6/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
//import TwitterKit

public class TwitterAuth : AWSAbstractIdentityProvider {
    var newLogins: [ NSObject : AnyObject ]!
    var currentUser: CurrentUser
    var className = "TwitterAuth"

    init(currentUser: CurrentUser) {
        self.currentUser = currentUser
        super.init()
        var dict  = NSMutableDictionary()
        dict.setObject("temp", forKey: "com.checkthis.today")
        self.logins = dict as [NSObject : AnyObject]

    }

    var newToken: String!

    override public var token: String {
        get {
            return newToken
        }
        set {
            newToken = newValue
        }
    }

    override public func getIdentityId() -> BFTask! {
        println("\(className)::\(__FUNCTION__)")
        if (self.identityId != nil) {
            return BFTask(result: self.identityId)
        } else {
            return BFTask(result: nil).continueWithBlock({ (task) -> AnyObject! in
                if (self.identityId == nil) {
                    return self.refresh()
                }
                return nil
            })
        }
    }


    override public func refresh() -> BFTask! {
        println("\(className)::\(__FUNCTION__) \(currentUser) ---------------------------------------------")
        let task = BFTaskCompletionSource()
        if currentUser.isTwitterAuthenticated {
             println("is authenticated")
            currentUser.authenticate(self, completion: { () -> Void in
                task.setResult(self.identityId)
                //UserSync.sharedInstance.sync(self.currentUser)
            })
        } else {
            task.setError(nil)
        }


        return task.task
    }

    override public var logins: [ NSObject : AnyObject ]! {
        get {
            return newLogins
        }
        set {
            newLogins = newValue
        }
    }

    override public var identityPoolId: String {
        get {
            return "***REMOVED***"
        }
    }

    override public func clear() {
        super.clear()
        println("\(className)::\(__FUNCTION__)")
    }

    
}