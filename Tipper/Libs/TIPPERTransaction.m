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
 

#import "TIPPERTransaction.h"

@implementation TIPPERTransaction

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"txid": @"txid",
             @"relayed_by": @"relayed_by",
             @"ToBitcoinAddress": @"ToBitcoinAddress",
             @"FromBitcoinAddress": @"FromBitcoinAddress",
             @"ToTwitterID": @"ToTwitterID",
             @"FromTwitterID": @"FromTwitterID",
             @"ToUserID": @"ToUserID",
             @"FromUserID": @"FromUserID",
             @"confirmations": @"confirmations",
             @"time": @"time",
             @"size": @"size",
             @"fee": @"fee",
             @"tip_amount": @"tip_amount",
             @"category": @"category"
             };
}

@end
