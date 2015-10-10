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

 
@interface TIPPERFavorite : AWSModel

@property (nonatomic, strong) NSNumber *CreatedAt;


@property (nonatomic, strong) NSString *FromTwitterID;


@property (nonatomic, strong) NSString *FromTwitterProfileImage;


@property (nonatomic, strong) NSString *FromTwitterUsername;


@property (nonatomic, strong) NSString *FromUserID;


@property (nonatomic, strong) NSString *ObjectID;


@property (nonatomic, strong) NSString *Provider;


@property (nonatomic, strong) NSString *ToTwitterID;


@property (nonatomic, strong) NSString *ToTwitterUsername;


@property (nonatomic, strong) NSString *TweetID;


@property (nonatomic, strong) NSString *TweetJSON;


@end
