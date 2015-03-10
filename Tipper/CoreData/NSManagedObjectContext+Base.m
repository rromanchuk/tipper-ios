//
//  NSManagedObjectContext+Base.m
//  frontback-xcode
//
//  Created by Ryan Romanchuk on 12/2/14.
//  Copyright (c) 2014 Frontback. All rights reserved.
//

#import "NSManagedObjectContext+Base.h"

@implementation NSManagedObjectContext (Base)
- (BOOL)saveMoc {
    if ([self hasChanges]) {
        NSError *error;
        if ([self save:&error]) {
            return YES;
        } else {
            NSLog(@"[CD ERROR] %@", error.userInfo);
            return NO;
        }
    } else {
        return YES;
    }
}
@end
