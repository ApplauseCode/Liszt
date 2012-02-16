//
//  SessionStore.m
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 2/15/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import "SessionStore.h"
#import "Session.h"
#import "Scale.h"
#import "Piece.h"
#import "Timer.h"

#define DEBUG 1
#undef DEBUG

@interface SessionStore ()

@property (nonatomic, strong) NSArray *objectsArchive;
- (void)testInit;
+ (NSDate *)getForDays:(int)days fromDate:(NSDate *)date;
@end

@implementation SessionStore

@synthesize objectsArchive;
@synthesize mySession;
@synthesize sessions;

- (NSString *)scaleArchivePath {
    return pathInDocumentDirectory(@"scale.data");
}

+ (SessionStore *)defaultStore
{
    __strong static SessionStore * defaultStore = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        defaultStore = [[SessionStore alloc] init];
    });
    return defaultStore;
}


- (id) init 
{
    self = [super init];
    if (self) {
#ifdef DEBUG
        [self testInit];
#else
        NSString *path = [self scaleArchivePath];
        objectsArchive = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (objectsArchive) {
            if ([objectsArchive objectAtIndex:0])
                sessions = [NSMutableArray arrayWithArray:[objectsArchive objectAtIndex:0]];
            if ([objectsArchive objectAtIndex:1])
                mySession = [objectsArchive objectAtIndex:1];
        } 
        else {
            sessions = [[NSMutableArray alloc] init];
            mySession = [[Session alloc] init];
        }
#endif    
    }
    return self; 
}

- (void)addSessionStartNew:(BOOL)fresh {
    [sessions addObject:mySession];    
    Session *newSession;
    if (!fresh)
        newSession = [[Session alloc] init];
    else
    {
        newSession = [[sessions objectAtIndex:([sessions count] - 1)] copy];
        [newSession setScaleTime:0];
        [newSession setArpeggioTime:0];
        [newSession setDate:[NSDate date]];
    }
    
    [self setMySession:newSession];
}

- (BOOL)saveChanges {
    objectsArchive = [NSArray arrayWithObjects:sessions, mySession, nil];
    return [NSKeyedArchiver archiveRootObject:objectsArchive toFile:[self scaleArchivePath]];
}

//------------------------------------------------------------------------------------------------
//               REMOVE LATER
//------------------------------------------------------------------------------------------------

+ (NSDate *)getForDays:(int)days fromDate:(NSDate *)date
{
    NSDateComponents *components= [[NSDateComponents alloc] init];
    [components setDay:days];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:components toDate:date options:0];
}

- (void)testInit
{
    sessions = [[NSMutableArray alloc] init];
    mySession = [[Session alloc] init];
    Session *tempSession = [[Session alloc] init];
    Scale *tempScale = [[Scale alloc] init];
    Piece *tempPiece = [[Piece alloc] init];
    
    [tempScale setTonic:kA];
    [tempScale setMode:kMelodicMinor];
    [tempScale setTempo:120];
    [tempScale setRhythm:kSixteenth];
    [tempScale setOctaves:4];
    [tempSession setScaleSession:[NSMutableOrderedSet orderedSetWithObject:tempScale]];
    [tempSession setScaleTime:900];
    [tempSession setDate:[SessionStore getForDays:-4 fromDate:[NSDate date]]];
    [sessions addObject:tempSession];
    
    tempSession = [[Session alloc] init];
    tempScale = [[Scale alloc] init];
    [tempScale setTonic:kB];
    [tempScale setMode:kArpDom7];
    [tempScale setTempo:112];
    [tempScale setRhythm:kTwelfth];
    [tempScale setOctaves:3];
    [tempSession setArpeggioSession:[NSMutableOrderedSet orderedSetWithObject:tempScale]];
    [tempSession setArpeggioTime:500];
    [tempSession setDate:[SessionStore getForDays:-3 fromDate:[NSDate date]]];
    [sessions addObject:tempSession];
    
    tempSession = [[Session alloc] init];
    [tempPiece setTitle:@"Polonaise N.1 Op.26"];
    [tempPiece setComposer:@"Chopin"];
    [tempPiece setMajor:YES];
    [tempPiece setTempo:80];
    [tempPiece setPieceKey:kCD];
    [tempPiece setPieceTime:1000];
    [tempPiece setTimer:[[Timer alloc] initWithElapsedTime:[tempPiece pieceTime]]];
    
    [tempSession setPieceSession:[NSMutableOrderedSet orderedSetWithObject:tempPiece]];
    [tempSession setDate:[SessionStore getForDays:-2 fromDate:[NSDate date]]];
    [sessions addObject:tempSession];
    
    tempSession = [[Session alloc] init];
    tempScale = [[Scale alloc] init];
    [tempScale setTonic:kC];
    [tempScale setMode:kMelodicMinor];
    [tempScale setTempo:125];
    [tempScale setRhythm:kSixteenth];
    [tempScale setOctaves:4];
    [tempSession setScaleSession:[NSMutableOrderedSet orderedSetWithObject:tempScale]];
    [tempSession setScaleTime:500];
    tempScale = [[Scale alloc] init];
    [tempScale setTonic:kD];
    [tempScale setMode:kArpDom7];
    [tempScale setTempo:115];
    [tempScale setRhythm:kTwelfth];
    [tempScale setOctaves:4];
    [tempSession setArpeggioTime:450];
    [tempSession setArpeggioSession:[NSMutableOrderedSet orderedSetWithObject:tempScale]];
    
    tempPiece = [[Piece alloc] init];
    [tempPiece setTitle:@"Take Five"];
    [tempPiece setComposer:@"Barnes"];
    [tempPiece setMajor:YES];
    [tempPiece setTempo:95];
    [tempPiece setPieceKey:kFG];
    [tempPiece setPieceTime:1500];
    [tempPiece setTimer:[[Timer alloc] initWithElapsedTime:[tempPiece pieceTime]]];
    [tempSession setPieceSession:[NSMutableOrderedSet orderedSetWithObject:tempPiece]];
    [tempSession setDate:[NSDate date]];
    mySession = tempSession;
}

//------------------------------------------------------------------------------------------------
//                ENDREMOVE LATER
//------------------------------------------------------------------------------------------------


@end
