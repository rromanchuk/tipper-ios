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

 
@interface TIPPERTransaction : AWSModel

@property (nonatomic, strong) NSString *txid;


@property (nonatomic, strong) NSString *relayedBy;


@property (nonatomic, strong) NSString *toBitcoinAddress;


@property (nonatomic, strong) NSString *fromBitcoinAddress;


@property (nonatomic, strong) NSString *toTwitterID;


@property (nonatomic, strong) NSString *fromTwitterID;


@property (nonatomic, strong) NSString *toUserID;


@property (nonatomic, strong) NSString *fromUserID;


@property (nonatomic, strong) NSString *confirmations;


@property (nonatomic, strong) NSNumber *time;


@property (nonatomic, strong) NSNumber *size;


@property (nonatomic, strong) NSNumber *fee;


@property (nonatomic, strong) NSNumber *tipAmount;


@property (nonatomic, strong) NSString *category;


@end
