/*
 Copyright 2010-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License").
 You may not use this file except in compliance with the License.
 A copy of the License is located at

 http://aws.amazon.com/apache2.0

 or in the "license" file accompanying this file. This file is distributed
 on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 express or implied. See the License for the specific language governing
 permissions and limitations under the License.
 */
 

#import <Foundation/Foundation.h>
#import <AWSCore/AWSCore.h>

 
@interface TIPPERUser : AWSModel

@property (nonatomic, strong) NSString *userID;


@property (nonatomic, strong) NSString *bitcoinAddress;


@property (nonatomic, strong) NSString *profileImage;


@property (nonatomic, strong) NSString *isActive;


@property (nonatomic, strong) NSString *twitterUsername;


@property (nonatomic, strong) NSString *twitterUserID;


@property (nonatomic, strong) NSNumber *createdAt;


@property (nonatomic, strong) NSNumber *updatedAt;


@property (nonatomic, strong) NSNumber *tippedFromUsAt;


@end
