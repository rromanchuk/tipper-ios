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

    @NSManaged var favoriteId: String
    @NSManaged var createdAt: NSDate
    @NSManaged var twitterJSON: [String: AnyObject]?


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
            return "favoriteId"
        }
    }

    var lookupValue: String {
        get {
            return self.favoriteId
        }
    }

    class func dateForTwitterDate(date: String) -> NSDate {
        return TwitterDateFormatter.dateFromString(date)!
    }

    func updateEntityWithJSON(json: JSON) {
        println("\(className)::\(__FUNCTION__) \(json)")
        self.favoriteId = json["id_str"].stringValue
        self.twitterJSON = json.dictionaryObject
    }

    func updateEntityWithTWTR(tweet: TWTRTweet) {
        println("\(className)::\(__FUNCTION__) \(tweet)")
        //self.twitterJSON = tweet
        self.favoriteId = tweet.tweetID
    }


    func updateEntityWithDynamoModel(dynamoObject: DynamoUpdatable) {
        println("\(className)::\(__FUNCTION__) ")
        let dynamoFavorite = dynamoObject as! DynamoFavorite
        self.favoriteId = dynamoFavorite.FavoriteID!
        self.createdAt = NSDate(timeIntervalSince1970: NSTimeInterval(dynamoFavorite.CreatedAt!.doubleValue))
        if let jsonString =   dynamoFavorite.TweetJSON, data = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
            let json = JSON(data: data)
            self.favoriteId = json["id"].stringValue
            self.twitterJSON = json.dictionaryObject
        }
        
    }



}