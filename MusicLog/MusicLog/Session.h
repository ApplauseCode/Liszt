//
//  Session.h
//  MusicLog
//
//  Created by Kyle Rosenbluth on 9/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Session : NSObject <NSCoding, NSMutableCopying>

@property (nonatomic, strong) NSMutableOrderedSet *scaleSession;
@property (nonatomic, strong) NSMutableOrderedSet *arpeggioSession;
@property (nonatomic, strong) NSMutableOrderedSet *pieceSession;
@property (nonatomic) int scaleTime;
@property (nonatomic) int arpeggioTime;
@property (nonatomic, strong) NSDate *date;

- (id)initWithScales:(NSMutableOrderedSet *)scaleSet
           arpeggios:(NSMutableOrderedSet *)arpeggioSet
              pieces:(NSMutableOrderedSet *)pieceSet;
@end
