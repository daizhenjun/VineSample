//
//  NSTimerExtension.m
//  VineSample
//
//  Created by 代 震军 on 13-6-18.
//  Copyright (c) 2013年 代 震军. All rights reserved.
//

#import "NSTimerExtension.h"


@implementation NSTimer (Pausing)

NSString *kIsPausedKey = @"IsPaused Key";
NSString *kRemainingTimeIntervalKey = @"RemainingTimeInterval Key";

- (NSMutableDictionary *)pauseDictionary {
    static NSMutableDictionary *globalDictionary = nil;
    
    if(!globalDictionary)
        globalDictionary = [[NSMutableDictionary alloc] init];
    
    if(![globalDictionary objectForKey:[NSNumber numberWithInt:(int)self]]) {
        NSMutableDictionary *localDictionary = [[NSMutableDictionary alloc] init];
        [globalDictionary setObject:localDictionary forKey:[NSNumber numberWithInt:(int)self]];
    }
    
    return [globalDictionary objectForKey:[NSNumber numberWithInt:(int)self]];
}

- (void)pause {
    if(![self isValid])
        return;
    
    NSNumber *isPausedNumber = [[self pauseDictionary] objectForKey:kIsPausedKey];
    if(isPausedNumber && YES == [isPausedNumber boolValue])
        return;
    
    NSDate *now = [NSDate date];
    NSDate *then = [self fireDate];
    NSTimeInterval remainingTimeInterval = [then timeIntervalSinceDate:now];
    
    [[self pauseDictionary] setObject:[NSNumber numberWithDouble:remainingTimeInterval] forKey:kRemainingTimeIntervalKey];
    
    [self setFireDate:[NSDate distantFuture]];
    [[self pauseDictionary] setObject:[NSNumber numberWithBool:YES] forKey:kIsPausedKey];
}

- (void)resume {
    if(![self isValid])
        return;
    
    NSNumber *isPausedNumber = [[self pauseDictionary] objectForKey:kIsPausedKey];
    if(!isPausedNumber || NO == [isPausedNumber boolValue])
        return;
    
    NSTimeInterval remainingTimeInterval = [[[self pauseDictionary] objectForKey:kRemainingTimeIntervalKey] doubleValue];
    
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:remainingTimeInterval];
    
    [self setFireDate:fireDate];
    [[self pauseDictionary] setObject:[NSNumber numberWithBool:NO] forKey:kIsPausedKey];
}
@end
