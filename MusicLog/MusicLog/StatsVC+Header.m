//
//  StatsVC+Header.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatsVC+Header.h"
#import "SectionInfo.h"
#import "TimerCell.h"
#import "Session.h"
#import "Timer.h"
#import "Piece.h"
#import "ScaleStore.h"

@implementation StatsVC (Header)
#pragma mark - Handling Sections

- (void)closeSections
{
    for (int i = 0; i < [sectionInfoArray count]; i++)
    {
        SectionInfo *si = [sectionInfoArray objectAtIndex:i];
        if ([si open])
            [self sectionHeaderView:[si headerView] sectionClosed:i];
    }
}

- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView tapped:(NSInteger)section
{
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    if (!sectionInfo.open)
        [self sectionHeaderView:sectionHeaderView sectionOpened:section];
    else
        [self sectionHeaderView:sectionHeaderView sectionClosed:section];
}

- (NSString *)stopTimerForSection:(NSInteger)section
{
    ScaleStore *store = [ScaleStore defaultStore];
    Timer *timer;
    switch (section) {
        case 0:
            timer = scaleTimer;
            [[store mySession] setScaleTime:[timer elapsedTime]];
            break;
        case 1:
            timer = arpeggioTimer;
            [[store mySession] setArpeggioTime:[timer elapsedTime]];
            break;   
        default:
            timer = [[[selectedSession pieceSession] objectAtIndex:(section - 2)] timer];
            break;
    }
    [timer stopTimer];
    return [timer timeString];
}

- (void)setupTimerCellForSection:(NSInteger)section
{
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    tCell = (TimerCell *) [statsTable dequeueReusableCellWithIdentifier:@"TimerCell"];
    timerButton = [tCell timerButton];
    [timerButton setTitle:@"Start" forState:UIControlStateNormal];    
    [timerButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    Timer * pieceTimer;
    switch (section) {
        case 0:
            [timerButton addTarget:scaleTimer action:@selector(timerHandling:) forControlEvents:UIControlEventTouchUpInside];
            [scaleTimer setTimeLabel:[sectionInfo.headerView subTitleLabel]];
            break;
        case 1:
            [timerButton addTarget:arpeggioTimer action:@selector(timerHandling:) forControlEvents:UIControlEventTouchUpInside];
            [arpeggioTimer setTimeLabel:[sectionInfo.headerView subTitleLabel]];
            break;
        default:
            pieceTimer = [[[selectedSession pieceSession] objectAtIndex:(section - 2)] timer];
            [timerButton addTarget:pieceTimer action:@selector(timerHandling:) forControlEvents:UIControlEventTouchUpInside];
            [pieceTimer setTimeLabel:[sectionInfo.headerView subTitleLabel]];
            break;
    }
}

-(void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section
{
    [self setupTimerCellForSection:section];
    NSInteger previousOpenSectionIndex = [self openSectionIndex];
    [self setOpenSectionIndex:section];
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    [sectionInfo setOpen:YES];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    if ([sectionInfo countofRowsToInsert] > 0) {
        for (NSInteger i = 0; i <= [sectionInfo countofRowsToInsert]; i++)
            [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    else {
        [sectionInfo setOpen:NO];
        [self setOpenSectionIndex:NSNotFound];
    }
    if (previousOpenSectionIndex != NSNotFound) {
        NSString *time;
        [timerButton setTitle:@"Start" forState:UIControlStateNormal];
        time = [self stopTimerForSection:previousOpenSectionIndex];
        
		SectionInfo *previousOpenSection = [self.sectionInfoArray objectAtIndex:previousOpenSectionIndex];
        [[previousOpenSection headerView] setSubTitle:time];
        [previousOpenSection setOpen:NO];
        [previousOpenSection.headerView toggleOpenWithUserAction:NO];
        NSInteger countOfRowsToDelete = [previousOpenSection countofRowsToInsert];
        for (NSInteger i = 0; i <= countOfRowsToDelete; i++)
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
    }
    [statsTable beginUpdates];
    [statsTable deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
    [statsTable insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationAutomatic];
    [statsTable endUpdates];
}

- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section
{
    NSString *time = [self stopTimerForSection:section];
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    [[sectionInfo headerView] setSubTitle:time];
    [sectionInfo setOpen:NO];
    
    NSInteger countofRowsToDelete = [statsTable numberOfRowsInSection:section];
    if (countofRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (int i = 0; i < countofRowsToDelete; i++)
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        [statsTable beginUpdates];
        [statsTable deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationNone];
        [statsTable endUpdates];
    }
    self.openSectionIndex = NSNotFound;
}

- (void)deleteSection:(NSInteger)section headerView:(SectionHeaderView *)sectionHeaderView
{
    if (section > 1)
    {
        Piece *p = [[[ScaleStore defaultStore] piecesInSession] objectAtIndex:section - 2];
        [[p timer] resetTimer];
        [[ScaleStore defaultStore] removePiece:p];
        [[ScaleStore defaultStore] addPiecesToSession];
        [sectionInfoArray removeObjectAtIndex:section];
        [statsTable deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
@end
