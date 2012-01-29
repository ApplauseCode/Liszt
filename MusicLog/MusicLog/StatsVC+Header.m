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

-(void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section
{
    tCell = (TimerCell *) [statsTable
                           dequeueReusableCellWithIdentifier:@"TimerCell"];
    
    timerButton = [tCell timerButton];
    [timerButton setTitle:@"Start" forState:UIControlStateNormal];
    
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    if ([sectionInfo countofRowsToInsert] < 1)
    {
        [[tCell timerButton] setAlpha:0.5];
        [[tCell timerButton] setEnabled:NO];
    }
    else
    {
        [[tCell timerButton] setAlpha:1.0];
        [[tCell timerButton] setEnabled:YES];
    }
    [timerButton removeTarget:scaleTimer action:@selector(timerHandling:) forControlEvents:UIControlEventTouchUpInside];
    [timerButton removeTarget:arpeggioTimer action:@selector(timerHandling:) forControlEvents:UIControlEventTouchUpInside];
    for (int i = 0; i < [[selectedSession pieceSession] count]; i++)
        [timerButton removeTarget:[[[selectedSession pieceSession] objectAtIndex:i] timer]
                           action:@selector(timerHandling:) 
                 forControlEvents:UIControlEventTouchUpInside];
    if (section == 0)
    {
        [timerButton addTarget:scaleTimer action:@selector(timerHandling:) forControlEvents:UIControlEventTouchUpInside];
        [scaleTimer setTimeLabel:[sectionInfo.headerView subTitleLabel]];
    }
    else if (section == 1)
    {
        [timerButton addTarget:arpeggioTimer action:@selector(timerHandling:) forControlEvents:UIControlEventTouchUpInside];
        [arpeggioTimer setTimeLabel:[sectionInfo.headerView subTitleLabel]];
    }
    else 
    {
        Timer *pieceTimer = [[[selectedSession pieceSession] objectAtIndex:(section - 2)] timer];
        [timerButton addTarget:pieceTimer action:@selector(timerHandling:) forControlEvents:UIControlEventTouchUpInside];
        [pieceTimer setTimeLabel:[sectionInfo.headerView subTitleLabel]];
    }
    sectionInfo.open = YES;
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    
    [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:0 inSection:section]];
    for (NSInteger i = 1; i <= [sectionInfo countofRowsToInsert]; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    NSInteger previousOpenSectionIndex = self.openSectionIndex;
    if (previousOpenSectionIndex != NSNotFound) {
        NSString *time;
        if (previousOpenSectionIndex == 0)
        {
            [timerButton setTitle:@"Start" forState:UIControlStateNormal];
            [scaleTimer stopTimer];
            time = [scaleTimer timeString];
        }
        else if (previousOpenSectionIndex == 1)
        {
            [timerButton setTitle:@"Start" forState:UIControlStateNormal];
            [arpeggioTimer stopTimer];
            time = [arpeggioTimer timeString];
        }
        else
        {
            Timer *pieceTimer = [[[selectedSession pieceSession] objectAtIndex:(previousOpenSectionIndex - 2)] timer];
            [timerButton setTitle:@"Start" forState:UIControlStateNormal];
            [pieceTimer stopTimer];
            time = [pieceTimer timeString];
        }
        
		SectionInfo *previousOpenSection = [self.sectionInfoArray objectAtIndex:previousOpenSectionIndex];
        [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:0 inSection:previousOpenSectionIndex]];
        [previousOpenSection.headerView setSubTitle:time];
        previousOpenSection.open = NO;
        [previousOpenSection.headerView toggleOpenWithUserAction:NO];
        NSInteger countOfRowsToDelete = [previousOpenSection countofRowsToInsert];
        for (NSInteger i = 1; i <= countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
        }
    }
    [statsTable beginUpdates];
    [statsTable deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
    [statsTable insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationAutomatic];
    [statsTable endUpdates];
    
    self.openSectionIndex = section;
}

- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section
{
    NSString *time;
    ScaleStore *store = [ScaleStore defaultStore];
    if (section == 0)
    {
        [scaleTimer stopTimer];
        time = [scaleTimer timeString];
        [[store mySession] setScaleTime:[scaleTimer elapsedTime]];
    }
    else if (section == 1)
    {
        [arpeggioTimer stopTimer];
        time = [arpeggioTimer timeString];
        [[store mySession] setArpeggioTime:[arpeggioTimer elapsedTime]];
    }
    else
    {
        Timer *pieceTimer = [[[selectedSession pieceSession] objectAtIndex:(section - 2)] timer];
        [pieceTimer stopTimer];
        time = [pieceTimer timeString];
    }
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    [sectionInfo.headerView setSubTitle:time];
    sectionInfo.open = NO;
    NSInteger countofRowsToDelete = [statsTable numberOfRowsInSection:section];
    
    if (countofRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countofRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        }
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
