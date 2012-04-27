//
//  Other.h
//  Liszt
//
//  Created by Kyle Rosenbluth on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "Common.h"

@interface Other: NSObject <NSMutableCopying, NSCoding>
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSString *otherDescription;
@property (nonatomic, assign) double otherTime;
@property (nonatomic, strong) NSDate *startOtherDate;
- (int)updateElapsedTime:(NSDate *)d;
- (void)resetStartTime;
@end

