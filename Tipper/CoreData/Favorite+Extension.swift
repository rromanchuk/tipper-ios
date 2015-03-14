//
//  File+Extension.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/14/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation

let TwitterDateFormatter: NSDateFormatter = {
    let df = NSDateFormatter()
    df.dateFormat = "eee, MMM dd HH:mm:ss ZZZZ yyyy"
    return df
}()


extension Favorite: CoreDataUpdatable {

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
        self.favoriteId = json["FavoriteID"].stringValue
        self.fromUsername = json["FromUsername"].stringValue
        self.toUsername = json["ToUsername"].stringValue
        self.fromTwitterId = json["FromTwitterUserID"].stringValue
        self.toTwitterId = json["ToTwitterUserID"].stringValue
        self.fromBitcoinAddress = json["FromBitcoinAddress"].string
        self.toBitcoinAddress = json["ToBitcoinAddress"].string
        self.tweetText = json["TweetText"].string
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