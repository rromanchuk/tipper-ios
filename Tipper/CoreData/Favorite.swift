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
    @NSManaged var toTwitterProfileImage: String?
    @NSManaged var fromTwitterId: String
    @NSManaged var fromTwitterUsername: String
    @NSManaged var fromTwitterProfileImage: String?
    @NSManaged var txid: String?
    @NSManaged var createdAt: NSDate
    @NSManaged var tippedAt: NSDate?
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
        self.tweetId = json["id_str"].stringValue
    }

    func updateEntityWithTWTR(tweet: TWTRTweet) {
        self.tweetId = tweet.tweetID
    }

    func updateEntityWithDynamoModel(dynamoObject: DynamoUpdatable) {
        let dynamoFavorite = dynamoObject as! DynamoFavorite
        if let tweetId = dynamoFavorite.TweetID {
            self.tweetId = tweetId
        }

        self.objectId = dynamoFavorite.ObjectID!
        self.tweetId = self.objectId

        if let fromUserId = dynamoFavorite.FromUserID {
            self.fromUserId = fromUserId
        }

        if let toUserId = dynamoFavorite.ToUserID {
            self.toUserId = toUserId
        }

        if let txid = dynamoFavorite.txid {
            self.txid = txid
        }

        if let _ = dynamoFavorite.DidLeaveTip {
            self.didLeaveTip = true
        }

        self.createdAt = NSDate(timeIntervalSince1970: NSTimeInterval(dynamoFavorite.CreatedAt!.doubleValue))

        if let tippedAt = dynamoFavorite.TippedAt {
            self.tippedAt = NSDate(timeIntervalSince1970: NSTimeInterval(tippedAt))
        } else {
            self.tippedAt = self.createdAt
        }

        /*
        Sections are organized by month and year. Create the section identifier
        as a string representing the number (year * 10000 + month * 100 + day);
        this way they will be correctly ordered chronologically regardless of
        the actual name of the month.
        */
        let calendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [.Year, .Month, .Day]
        let components: NSDateComponents = calendar.components(unitFlags, fromDate: self.tippedAt!) //calendar.component(unitFlags, fromDate: self.createdAt)

        //calendar.components((.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay),
            //fromDate:self.createdAt)

        self.daySectionString = "\(components.year * 10000 + components.month * 100 + components.day)"

            //[NSString stringWithFormat:@"%d", [components year] * 10000 + [components month] * 100  + [components day]];

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

        if let fromTwitterProfileImage = dynamoFavorite.FromTwitterProfileImage {
            self.fromTwitterProfileImage = fromTwitterProfileImage
        }

        if let toTwitterProfileImage = dynamoFavorite.ToTwitterProfileImage {
            self.toTwitterProfileImage = toTwitterProfileImage
        }
    }



}