//
//  ScaleStore.m
//  InstrumentLog
//
//  Created by Kyle Rosenbluth on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScaleStore.h"
#import "AppDelegate.h"
#import "Scale.h"
#import "Session.h"
#import "Piece.h"
#import "Timer.h"
#import "NSString+Number.h"

#define DEBUG 1
//#undef DEBUG

static ScaleStore *defaultStore = nil;

@interface ScaleStore ()
@property (nonatomic, strong) NSArray *objectsArchive;
@end

@implementation ScaleStore
@synthesize objectsArchive;
@synthesize mySession;
@synthesize scalesInSession;
@synthesize arpeggiosInSession;
@synthesize piecesInSession;
@synthesize sessions;

//REMOVE LATER
+ (NSDate *)getForDays:(int)days fromDate:(NSDate *)date
{
    NSDateComponents *components= [[NSDateComponents alloc] init];
    [components setDay:days];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:components toDate:date options:0];
}
//END REMOVE


- (id)init
{
    if (defaultStore) {
        return defaultStore;
    }
    self = [super init];
    if (self) {
#ifdef DEBUG
        sessions = [[NSMutableArray alloc] init];
        scalesInSession = [[NSMutableOrderedSet alloc] init];
        arpeggiosInSession = [[NSMutableOrderedSet alloc] init];
        piecesInSession = [[NSMutableOrderedSet alloc] init];
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
        [tempSession setDate:[ScaleStore getForDays:-4 fromDate:[NSDate date]]];
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
        [tempSession setDate:[ScaleStore getForDays:-3 fromDate:[NSDate date]]];
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
        [tempSession setDate:[ScaleStore getForDays:-2 fromDate:[NSDate date]]];
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
        
#else
        NSString *path = [self scaleArchivePath];
        objectsArchive = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (objectsArchive) {
            if ([objectsArchive objectAtIndex:0])
                sessions = [NSMutableArray arrayWithArray:[objectsArchive objectAtIndex:0]];
            if ([objectsArchive objectAtIndex:1]) 
                scalesInSession = [NSMutableOrderedSet orderedSetWithOrderedSet:[objectsArchive objectAtIndex:1]];
            if ([objectsArchive objectAtIndex:2])
                arpeggiosInSession = [NSMutableOrderedSet orderedSetWithOrderedSet:[objectsArchive objectAtIndex:2]];
            if ([objectsArchive objectAtIndex:3])
                piecesInSession = [NSMutableOrderedSet orderedSetWithOrderedSet:[objectsArchive objectAtIndex:3]];
            if ([objectsArchive objectAtIndex:4])
                mySession = [objectsArchive objectAtIndex:4];
        } 
        else {
            sessions = [[NSMutableArray alloc] init];
            scalesInSession = [[NSMutableOrderedSet alloc] init];
            arpeggiosInSession = [[NSMutableOrderedSet alloc] init];
            piecesInSession = [[NSMutableOrderedSet alloc] init];
            mySession = [[Session alloc] init];
        }
#endif    
    }
    return self;
}

+ (ScaleStore *)defaultStore
{
    if (!defaultStore) {
        defaultStore = [[super allocWithZone:NULL] init];
    }
    return defaultStore;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self defaultStore];
}

- (void)addScale:(Scale *)s {
    [scalesInSession addObject:s];
}

- (void)addArpeggio:(Scale *)a {
    [arpeggiosInSession addObject:a];
}

- (void)addPiece:(Piece *)p {
    [piecesInSession addObject:p];
}

- (void)addArpeggioArray:(NSArray *)a {
    [arpeggiosInSession addObjectsFromArray:a];
}

- (void)addScaleArray:(NSArray *)s {
    [scalesInSession addObjectsFromArray:s];
}

- (void)addPieceArray:(NSArray *)p {
    [piecesInSession addObjectsFromArray:p];
}

- (void)removeScale:(Scale *)s {
    [scalesInSession removeObject:s];
}

- (void)removeArpeggio:(Scale *)a {
    [arpeggiosInSession removeObject:a];
}

- (void)removePiece:(Piece *)p {
    [piecesInSession removeObject:p];
}

- (void)addSessionStartNew:(BOOL)fresh {
    [sessions addObject:mySession];
    [self clearAll];
    Session *newSession;
    if (!fresh)
        newSession = [[Session alloc] init];
    else
    {
        newSession = [[sessions objectAtIndex:([sessions count] - 1)] copy];
        [newSession setScaleTime:0];
        [newSession setArpeggioTime:0];
        [newSession setDate:[NSDate date]];
        [self setScalesInSession:[NSMutableOrderedSet orderedSetWithOrderedSet:[newSession scaleSession]]];
        [self setArpeggiosInSession:[NSMutableOrderedSet orderedSetWithOrderedSet:[newSession arpeggioSession]]];
        [self setPiecesInSession:[NSMutableOrderedSet orderedSetWithOrderedSet:[newSession pieceSession]]];
    }
    
    [self setMySession:newSession];
}

- (void)addScalesToSession {
    [mySession setScaleSession:scalesInSession];
}

- (void)addArpeggiosToSession {
    [mySession setArpeggioSession:arpeggiosInSession];
}

- (void)addPiecesToSession {
    [mySession setPieceSession:piecesInSession];
}

- (void)clearAll {
    [scalesInSession removeAllObjects];
    [arpeggiosInSession removeAllObjects];
    [piecesInSession removeAllObjects];
}

- (BOOL)saveChanges {
    objectsArchive = [NSArray arrayWithObjects:sessions, scalesInSession, arpeggiosInSession, piecesInSession, mySession, nil];
    return [NSKeyedArchiver archiveRootObject:objectsArchive toFile:[self scaleArchivePath]];
}

- (NSString *)scaleArchivePath {
    return pathInDocumentDirectory(@"scale.data");
}

@end
