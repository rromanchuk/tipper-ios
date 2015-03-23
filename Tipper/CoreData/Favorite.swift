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
    @NSManaged var fromUsername: String
    @NSManaged var toUsername: String
    @NSManaged var toTwitterId: String
    @NSManaged var fromTwitterId: String
    @NSManaged var fromBitcoinAddress: String?
    @NSManaged var toBitcoinAddress: String?
    @NSManaged var tweetText: String?
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

    class func entityWithTWTR(tweet: TWTRTweet, context: NSManagedObjectContext) -> Favorite? {
        let request = NSFetchRequest(entityName: "Favorite")
        request.predicate = NSPredicate(format: "favoriteId == %@", tweet.tweetID)
        var error: NSError? = nil
        let results = context.executeFetchRequest(request, error: &error)
        if let _error = error {
            println("ERROR: \(_error)")
        }

        if (results == nil) {
            return nil
        } else if (results?.count == 0) {
            let entityObj = Favorite.create(Favorite.self, context: context)

            entityObj.updateEntityWithTWTR(tweet)
            return entityObj
        } else {
            let entityObj = results?.last as? Favorite
            entityObj?.updateEntityWithTWTR(tweet)
            return entityObj
        }
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
        self.fromUsername = dynamoFavorite.FromUsername!
        self.toUsername = dynamoFavorite.ToUsername!
        self.fromTwitterId = dynamoFavorite.FromTwitterUserID!
        self.toTwitterId = dynamoFavorite.ToTwitterUserID!
        self.fromBitcoinAddress = dynamoFavorite.FromBitcoinAddress
        self.toBitcoinAddress = dynamoFavorite.ToBitcoinAddress
        self.tweetText = dynamoFavorite.TweetText
        
    }



}