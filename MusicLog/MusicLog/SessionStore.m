//
//  SessionStore.m
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 2/15/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import "SessionStore.h"
#import "AppDelegate.h"
#import "Session.h"
#import "Scale.h"
#import "Piece.h"
#import "NSMutableOrderedSet+DeepCopy.h"

#define DEBUG 1
//#undef DEBUG

@interface SessionStore ()

@property (nonatomic, strong) NSArray *objectsArchive;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
- (void)testInit;
+ (NSDate *)getForDays:(int)days fromDate:(NSDate *)date;
@end

@implementation SessionStore

@synthesize objectsArchive;
@synthesize mySession;
@synthesize sessions;
@synthesize indexForDateString;
@synthesize dateFormatter;

- (NSString *)scaleArchivePath {
    return pathInDocumentDirectory(@"scale.data");
}

+ (SessionStore *)defaultStore
{
    __strong static SessionStore *defaultStore = nil;
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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *isFirstLaunch = [NSNumber numberWithBool:YES];
        NSDictionary *appDefaults = [[NSDictionary alloc] initWithObjectsAndKeys:isFirstLaunch, @"FirstLaunch", nil];
        [defaults registerDefaults:appDefaults];
        if ([[defaults objectForKey:@"FirstLaunch"] boolValue]) {
            [self testInit];
            [defaults setBool:NO forKey:@"FirstLaunch"];
            [defaults synchronize];
        }
        else
        {
            NSString *path = [self scaleArchivePath];
            objectsArchive = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            if (objectsArchive) {
                if ([objectsArchive objectAtIndex:0])
                    sessions = [NSMutableArray arrayWithArray:[objectsArchive objectAtIndex:0]];
                if ([objectsArchive objectAtIndex:1]) {
                    Session *archivedSession = [objectsArchive objectAtIndex:1];
                    mySession = [[Session alloc] initWithScales:[NSMutableOrderedSet fromOrderedSet:[archivedSession scaleSession]]
                                                      arpeggios:[NSMutableOrderedSet fromOrderedSet:[archivedSession arpeggioSession]]
                                                         pieces:[NSMutableOrderedSet fromOrderedSet:[archivedSession pieceSession]]];
                    [mySession setScaleTime:[[objectsArchive objectAtIndex:1] scaleTime]];
                    [mySession setArpeggioTime:[[objectsArchive objectAtIndex:1] arpeggioTime]];
                    [mySession setDate:[[objectsArchive objectAtIndex:1] date]];                
                }
            } 
            else {
                sessions = [[NSMutableArray alloc] init];
                mySession = [[Session alloc] init];
            }

        }    
    }
    [self updateDict];
    return self; 
}

- (void)updateDict
{
    indexForDateString = [[NSMutableDictionary alloc] initWithCapacity:[sessions count]];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *key;
    for (int i = 0; i < [sessions count]; i++ ) {
        key = [dateFormatter stringFromDate:[(Session *)[sessions objectAtIndex:i] date]];
        [indexForDateString setObject:[NSNumber numberWithInt:i] forKey:key];
    } 
}

- (void)startNewSession:(BOOL)fresh {
    Session *newSession;
    if (fresh)
        newSession = [[Session alloc] init];
    else
    {
        newSession = [[sessions objectAtIndex:([sessions count] - 1)] mutableCopy];
        [newSession setScaleTime:0];
        [newSession setArpeggioTime:0];
        for (Piece *p in [newSession pieceSession]) {
            [p setPieceTime:0];
        }
        [newSession setDate:[NSDate date]];
    }
    [self setMySession:newSession];
}

- (BOOL)saveChanges {
    objectsArchive = [NSArray arrayWithObjects:sessions, mySession, nil];
    return [NSKeyedArchiver archiveRootObject:objectsArchive toFile:[self scaleArchivePath]];
}

- (Session *)sessionForDate:(NSDate *)d
{
    NSString *key = [dateFormatter stringFromDate:d];
    NSNumber *idx = [indexForDateString objectForKey:key];
    if (idx)
        return [sessions objectAtIndex:[idx intValue]];
    else 
        return mySession;
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
    [mySession setDate:[SessionStore getForDays:-3 fromDate:[NSDate date]]];
    
    NSArray *pieceNames = [NSArray arrayWithObjects:@"Waltz", @"Etude", @"Danse", @"Song", @"Prelude", @"Polonaise", @"Sonata", @"Concerto", @"Symphony", nil];
    NSArray *pieceNumbers = [NSArray arrayWithObjects:@" No.1", @" No.2", @" No.3", @" No. 4", @" No. 5", @" No. 6", @" No. 7", @" No. 8", @" No. 9", @" No. 10", nil];
    NSArray *composers = [NSArray arrayWithObjects:@"Chopin", @"Handel", @"Bach", @"Monk", @"Brubeck", @"Malmstein", @"Beethoven", @"Tchaikovsky", @"Debussy", @"Faure", @"Satie", @"Mussourgsky", @"Liszt", @"Marselis", @"Coltrane", nil];
                        
    
    for (int i = 500; i > 3; i--)
    {
        NSMutableOrderedSet *scaleSet = [[NSMutableOrderedSet alloc] initWithCapacity:20];
        NSMutableOrderedSet *arpeggioSet = [[NSMutableOrderedSet alloc] initWithCapacity:20];
        NSMutableOrderedSet *pieceSet = [[NSMutableOrderedSet alloc] initWithCapacity:10];
        for (int k = 0; k < arc4random() % 20; k++)
        {
            Scale *tempScale = [[Scale alloc] init];
            [tempScale setTonic:(arc4random() % 12) + 3];
            [tempScale setScaleMode:arc4random() % 4];
            [tempScale setTempo:k * (arc4random() % 25)];
            [tempScale setRhythm:arc4random() % 6];
            [tempScale setOctaves:4];
            [scaleSet addObject:tempScale];
            
        }
        for (int k = 0; k < arc4random() % 20; k++)
        {
            Scale *tempArpeggio = [[Scale alloc] init];
            [tempArpeggio setTonic:(arc4random() % 12) + 3];
            [tempArpeggio setTempo:k * (arc4random() % 25)];
            [tempArpeggio setRhythm:arc4random() % 6];
            [tempArpeggio setOctaves:4];
            [arpeggioSet addObject:tempArpeggio];
        }
        for (int k = 0; k < arc4random() % 10; k++)
        {
            Piece *tempPiece = [[Piece alloc] init];
            NSString *title = [pieceNames objectAtIndex:arc4random() % [pieceNames count]];
            NSString *number = [pieceNumbers objectAtIndex:arc4random() % [pieceNumbers count]];
            [tempPiece setTitle:[title stringByAppendingString:number]];
            [tempPiece setComposer:[composers objectAtIndex:arc4random() % [composers count]]];
            [tempPiece setMajor:arc4random() % 2];
            [tempPiece setPieceKey:arc4random() % 17];
            [tempPiece setPieceTime:(arc4random() % 10000) + 1];
            [tempPiece setTempo:k * (arc4random() % 25)];
            [pieceSet addObject:tempPiece];
        }
        Session *theSesh = [[Session alloc] initWithScales:scaleSet arpeggios:arpeggioSet pieces:pieceSet];
        [theSesh setScaleTime:i * 10];
        [theSesh setArpeggioTime:i * 7];
        [theSesh setDate:[SessionStore getForDays:-i fromDate:[NSDate date]]];
        [theSesh setSessionNotes:@"Hi Testing"];
        [sessions addObject:theSesh];
    }
}

//------------------------------------------------------------------------------------------------
//                ENDREMOVE LATER
//------------------------------------------------------------------------------------------------


@end
