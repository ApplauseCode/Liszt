//
//  PracticedLog.h
//  PianoLog
//
//  Created by Kyle Rosenbluth on 8/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

@class CompoundString;

@interface Scale : NSObject <NSCoding, NSMutableCopying>

@property tonicType tonic;
@property modeType scaleMode;
@property int tempo;
@property rhythmType rhythm;
@property int octaves;

-(NSString *) modeString;
-(NSString *) rhythmString;
-(NSString *) octavesString;
-(NSString *) tempoString;
- (CompoundString *)tonicCompoundString;


@end