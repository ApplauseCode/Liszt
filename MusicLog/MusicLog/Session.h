//
//  Session.h
//  MusicLog
//
//  Created by Kyle Rosenbluth on 9/22/11.
//  Copyright (c) 2011 __Applause Code__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Session : NSObject <NSCoding, NSMutableCopying>

@property (nonatomic, strong) NSMutableOrderedSet *scaleSession;
@property (nonatomic, strong) NSMutableOrderedSet *arpeggioSession;
@property (nonatomic, strong) NSMutableOrderedSet *pieceSession;
@property (nonatomic) double scaleTime;
@property (nonatomic) double arpeggioTime;
@property (nonatomic, strong) NSString *sessionNotes;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *startScaleDate, *startArpeggioDate;

- (id)initWithScales:(NSMutableOrderedSet *)scaleSet
           arpeggios:(NSMutableOrderedSet *)arpeggioSet
              pieces:(NSMutableOrderedSet *)pieceSet;
- (NSInteger)calculateTotalTime;
- (int)updateElapsedTime:(NSDate *)d forIndex:(NSInteger)idx;
- (void)resetStartTime:(NSInteger)idx;
@end
