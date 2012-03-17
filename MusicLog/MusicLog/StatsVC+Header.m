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
#import "SessionStore.h"
#import "NSString+Number.h"
#import "CustomSectionMove.h"

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

- (void)setupTimerCellForSection:(NSInteger)section
{
//    tCell = (TimerCell *) [statsTable dequeueReusableCellWithIdentifier:@"TimerCell"];
    tCell = [[[NSBundle mainBundle] loadNibNamed:@"TimerCell" owner:self options:nil] objectAtIndex:0];
    timerButton = [tCell timerButton];
    [timerButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [timerButton addTarget:self action:@selector(timerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section
{
    
    [sectionHeaderView turnDownDisclosure:YES];
    NSInteger previousOpenSectionIndex = [self openSectionIndex];
    [self setOpenSectionIndex:section];
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    [sectionInfo setOpen:YES];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    if ([sectionInfo countofRowsToInsert] > 0 && currentPractice) {
        for (NSInteger i = 0; i <= [sectionInfo countofRowsToInsert]; i++)
            [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        [self setupTimerCellForSection:section];
        [timerButton setImage:[UIImage imageNamed:@"StartTimer.png"] forState:UIControlStateNormal];
    } else if ([sectionInfo countofRowsToInsert] > 0 && !currentPractice) {
        for (NSInteger i = 0; i < [sectionInfo countofRowsToInsert]; i++)
            [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    } else {
        [sectionHeaderView turnDownDisclosure:NO];
        [sectionInfo setOpen:NO];
        [self setOpenSectionIndex:NSNotFound];
    }
    
    if (previousOpenSectionIndex != NSNotFound) {
        SectionInfo *previousOpenSection = [self.sectionInfoArray objectAtIndex:previousOpenSectionIndex];
        [previousOpenSection.headerView turnDownDisclosure:NO];
        if (currentPractice && isTiming)
            [self toggleTimer:previousOpenSectionIndex];
		
        [previousOpenSection setOpen:NO];
        NSInteger countOfRowsToDelete = [previousOpenSection countofRowsToInsert];
        if (countOfRowsToDelete > 0 && currentPractice) {
            for (NSInteger i = 0; i <= countOfRowsToDelete; i++)
                [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
        } else if (countOfRowsToDelete > 0 && !currentPractice) {
            for (NSInteger i = 0; i < countOfRowsToDelete; i++)
                [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
        } else {
            [previousOpenSection.headerView turnDownDisclosure:NO];
            [previousOpenSection setOpen:NO];
        }
    }
    [statsTable beginUpdates];
    [statsTable deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
    [statsTable insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationAutomatic];
    [statsTable endUpdates];
    // calling cellForRowAtIndexPath, is this bad?
    if (section > 1 && ![[statsTable visibleCells] containsObject: 
        [statsTable cellForRowAtIndexPath:
         [NSIndexPath indexPathForRow:[statsTable numberOfRowsInSection:section] -1 inSection:section]]])
        [statsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[statsTable numberOfRowsInSection:section] - 1 inSection:section] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    if (section < 2)
        [statsTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section
{
    [sectionHeaderView turnDownDisclosure:NO];
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    [sectionInfo setOpen:NO];
    if (currentPractice && isTiming)
        [self toggleTimer:section];
    
    NSInteger countofRowsToDelete = [statsTable numberOfRowsInSection:section];
    if (countofRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (int i = 0; i < countofRowsToDelete; i++)
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        [statsTable beginUpdates];
        [statsTable deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
        [statsTable endUpdates];
    }
    self.openSectionIndex = NSNotFound;
}

- (void)deleteSection:(NSInteger)section headerView:(SectionHeaderView *)sectionHeaderView
{
    if (section > 1)
    {
        Piece *p = [[[[SessionStore defaultStore] mySession] pieceSession] objectAtIndex:section - 2];
        [[[[SessionStore defaultStore] mySession] pieceSession] removeObject:p];
        [sectionInfoArray removeObjectAtIndex:section];
        [statsTable deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self setOpenSectionIndex:NSNotFound];
        NSString *timeString = [NSString timeStringFromInt:[self calculateTotalTime]];
        [totalTime setText:timeString];
        for (int i = section; i < [sectionInfoArray count]; i++)
        {
            NSInteger currentSection = [[[sectionInfoArray objectAtIndex:i] headerView] section];
            SectionHeaderView *currentHeader = [[sectionInfoArray objectAtIndex:i] headerView];
            [currentHeader setSection:(currentSection - 1)];
        }
    }
}

- (void)moveSection:(NSInteger)section headerView:(SectionHeaderView *)sectionHeaderView
{
    if (section > 1)
    {
        sectionMover = [[CustomSectionMove alloc] initWithFrame:[statsTable frame]
                                               numberOfSections:[statsTable numberOfSections]
                                                heightOfSection:[statsTable sectionHeaderHeight]];
        [sectionMover setOldSection:section];
        [sectionMover setDelegate:self];
        [self.view addSubview:sectionMover];
    }
//    if (section > 1)
//    {
//        NSInteger oldSectionFirst = [[[sectionInfoArray objectAtIndex:section] headerView] section];
//        NSInteger oldSectionSecond = [[[sectionInfoArray objectAtIndex:section + 1] headerView] section];
//        [[[sectionInfoArray objectAtIndex:section] headerView] setSection:oldSectionSecond];
//        [[[sectionInfoArray objectAtIndex:section + 1] headerView] setSection:oldSectionFirst];
//        [statsTable beginUpdates];
//        [statsTable moveSection:section toSection:section + 1];
//        [statsTable endUpdates];
//    }
    
}

- (void)sectionMoveLocationSelected:(NSInteger)section
{
    if (section > 1)
    {
        [[[sectionInfoArray objectAtIndex:[sectionMover oldSection]] headerView] setSection:section];
        NSInteger largerSection = MAX([sectionMover oldSection], section);
        NSInteger smallerSection = MIN([sectionMover oldSection], section);
        for (int i = smallerSection; i < largerSection; i++)
        {
            [[[sectionInfoArray objectAtIndex:i] headerView] setSection:i + 1];
            
        }
        SectionInfo *objectToMove = [sectionInfoArray objectAtIndex:[sectionMover oldSection]];
        [sectionInfoArray removeObject:objectToMove];
        [sectionInfoArray insertObject:objectToMove atIndex:section];
        [sectionMover removeFromSuperview];
        [statsTable beginUpdates];
        [statsTable moveSection:[sectionMover oldSection] toSection:section];
        [statsTable endUpdates];
        // for debugging
        for (SectionInfo *info in sectionInfoArray)
            NSLog(@"objectAtIndex:%i section:%i title:%@", [sectionInfoArray indexOfObject:info], [[info headerView] section], [[[info headerView] titleLabel] text]);
    }
    
}
@end
