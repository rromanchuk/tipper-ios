//
//  UserSync.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/9/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
public class UserSync {

    public static let sharedInstance: UserSync = UserSync()

    lazy var client: AWSCognito = {
        let _client = AWSCognito.defaultCognito()
        _client.conflictHandler = { (datasetName, conflict) -> AWSCognitoResolvedConflict in
            return conflict.resolveWithLocalRecord()
        }
        return _client
    }()

    lazy var userProfile: AWSCognitoDataset = {
        return self.client.openOrCreateDataset("Profile")
    }()

    func sync(currentUser: CurrentUser) {
        userProfile.setString(currentUser.twitterUserId, forKey: "TwitterUserId")
        if let bitcoinAddress = currentUser.bitcoinAddress {
            userProfile.setString(bitcoinAddress, forKey: "BitcoinAddress")
        }

        //userProfile.setString(currentUser.phone, forKey: "Phone")
        userProfile.setString(currentUser.twitterAuthToken, forKey: "TwitterAuthToken")
        userProfile.synchronize()
    }
}
