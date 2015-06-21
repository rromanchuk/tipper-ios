//
//  Tipper.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/10/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import TwitterKit

let TwitterDateFormatter: NSDateFormatter = {
    let df = NSDateFormatter()
    df.dateFormat = "eee, MMM dd HH:mm:ss ZZZZ yyyy"
    return df
}()



class Favorite: NSManagedObject, CoreDataUpdatable {
    @NSManaged var objectId: String
    @NSManaged var fromUserId: String
    @NSManaged var toUserId: String
    @NSManaged var tweetId: String
    @NSManaged var toTwitterId: String
    @NSManaged var toTwitterUsername: String
    @NSManaged var fromTwitterId: String
    @NSManaged var fromTwitterUsername: String
    @NSManaged var txid: String?
    @NSManaged var createdAt: NSDate
    @NSManaged var twitterJSON: [String: AnyObject]?
    @NSManaged var didLeaveTip: Bool
    @NSManaged var daySectionString: String

    class var className: String {
        get {
            return "Favorite"
        }
    }

    var className: String {
        return Favorite.className
    }

    static var lookupProperty: String {
        get {
            return "objectId"
        }
    }

    var lookupValue: String {
        get {
            return self.objectId
        }
    }

    class func dateForTwitterDate(date: String) -> NSDate {
        return TwitterDateFormatter.dateFromString(date)!
    }

    func updateEntityWithJSON(json: JSON) {
        //println("\(className)::\(__FUNCTION__) \(json)")
        self.tweetId = json["id_str"].stringValue
        self.twitterJSON = json.dictionaryObject
    }

    func updateEntityWithTWTR(tweet: TWTRTweet) {
        //println("\(className)::\(__FUNCTION__) \(tweet)")
        //self.twitterJSON = tweet
        self.tweetId = tweet.tweetID
    }

    func updateEntityWithDynamoModel(dynamoObject: DynamoUpdatable) {
        //println("\(className)::\(__FUNCTION__) ")
        let dynamoFavorite = dynamoObject as! DynamoFavorite
        if let tweetId = dynamoFavorite.TweetID {
            self.tweetId = tweetId
        }

        self.objectId = dynamoFavorite.ObjectID!

        if let fromUserId = dynamoFavorite.FromUserID {
            self.fromUserId = fromUserId
        }

        if let toUserId = dynamoFavorite.ToUserID {
            self.toUserId = toUserId
        }

        if let txid = dynamoFavorite.txid {
            self.txid = txid
        }

        println("Dynamo favorite model DidLeaveTip: \(dynamoFavorite.DidLeaveTip) objectId:\(dynamoFavorite.ObjectID)")
        if let didLeaveTip = dynamoFavorite.DidLeaveTip {
            self.didLeaveTip = true
        }

        self.createdAt = NSDate(timeIntervalSince1970: NSTimeInterval(dynamoFavorite.CreatedAt!.doubleValue))

        /*
        Sections are organized by month and year. Create the section identifier
        as a string representing the number (year * 10000 + month * 100 + day);
        this way they will be correctly ordered chronologically regardless of
        the actual name of the month.
        */
        let calendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = .CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay
        let components: NSDateComponents = calendar.components(unitFlags, fromDate: self.createdAt) //calendar.component(unitFlags, fromDate: self.createdAt)

        //calendar.components((.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay),
            //fromDate:self.createdAt)

        self.daySectionString = "\(components.year * 10000 + components.month * 100 + components.day)"

            //[NSString stringWithFormat:@"%d", [components year] * 10000 + [components month] * 100  + [components day]];


        if let jsonString = dynamoFavorite.TweetJSON, data = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
            let json = JSON(data: data)
            self.tweetId = json["id"].stringValue
            self.twitterJSON = json.dictionaryObject
        }

        if let toTwitterID = dynamoFavorite.ToTwitterID, fromTwitterID = dynamoFavorite.FromTwitterID {
            self.toTwitterId = toTwitterID
            self.fromTwitterId = fromTwitterID
        }


        if let toTwitterUsername = dynamoFavorite.ToTwitterUsername {
            self.toTwitterUsername = toTwitterUsername
        }

        if let fromTwitterUsername = dynamoFavorite.FromTwitterUsername {
            self.fromTwitterUsername = fromTwitterUsername
        }
    }



}