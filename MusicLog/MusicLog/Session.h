//
//  Session.h
//  MusicLog
//
//  Created by Kyle Rosenbluth on 9/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Session : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSMutableOrderedSet *scaleSession;
@property (nonatomic, strong) NSMutableOrderedSet *arpeggioSession;
@property (nonatomic, strong) NSMutableOrderedSet *pieceSession;
@property (nonatomic) int scaleTime;
@property (nonatomic) int arpeggioTime;
//@property (nonatomic) int pieceTime;
@property (nonatomic, strong) NSDate *date;

//TEMP
+ (NSDate *)getForDays:(int)days fromDate:(NSDate *)date;
- (id)initWithDayOffset:(int)n;

@end
