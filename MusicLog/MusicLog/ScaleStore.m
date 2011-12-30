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

- (id)init
{
    if (defaultStore) {
        return defaultStore;
    }
    self = [super init];
        if (self) {
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

- (void)addSession {   
    [sessions addObject:[mySession copy]];
    Session *newSession = [[Session alloc] initWithDayOffset:1];
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
