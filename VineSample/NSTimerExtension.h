//
//  NSTimerExtension.h
//  VineSample
//
//  Created by 代 震军 on 13-6-18.
//  Copyright (c) 2013年 代 震军. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Pausing)

- (NSMutableDictionary *)pauseDictionary;
- (void)pause;
- (void)resume;

@end  
