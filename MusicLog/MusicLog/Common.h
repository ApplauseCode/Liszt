//
//  Common.h
//  InstrumentLog
//
//  Created by Kyle Rosenbluth on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef InstrumentLog_Common_h
#define InstrumentLog_Common_h
/*BOOL doubleDigit(int x);

BOOL doubleDigit(int x)
{
    if (x > 9)
        return YES;
    else
        return NO;
}*/


typedef enum {kSharps, kFlats, kAll, kC, kCD, kD, kDE, kE, kF, kFG, kG, kGA, kA, kAB, kB} tonicType;
typedef enum {kpC, kpCSharp, kpDFlat, kpD, kpDSharp, kpEFlat, kpE, kpF, kpFSharp, kpGFlat, kpG, kpGSharp, kpAFlat, kpA, kpASharp, kpBFlat, kpB} pieceTonicType;

typedef enum {kMajor, kNaturalMinor, kMelodicMinor, kHarmonicMinor, kArpMajor, kArpMinor, kArpMaj7, kArpDom7, kArpMin7, kArpHalfDim7, kArpDim7, kArpMajMin7} modeType;

typedef enum {kWhole, kHalf, kQuarter, kEighth, kTwelfth, kSixteenth, kThirtysecond, kSixtyfourth, kOctaveBursts} rhythmType;

typedef enum {kZERO, kONE, kTWO} TROOL;

#endif