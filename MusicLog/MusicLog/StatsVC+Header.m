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
#import "StatsView.h"

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
    [self setSwipedHeader:nil];
}

- (void)displayNotesViewForSection:(NSInteger)section headerView:(SectionHeaderView *)headerView
{
    CGRect frameOfExcludedArea = [self.view.superview convertRect:headerView.deleteView.frame fromView:headerView.deleteView.superview];
    CGPoint center = CGPointMake(frameOfExcludedArea.origin.x + (frameOfExcludedArea.size.width / 2),
                                 frameOfExcludedArea.origin.y + (frameOfExcludedArea.size.height / 2));
    [notesTapGesture addTarget:self action:@selector(getRidOfNotes:)];
    [notesTapGesture setEnabled:YES];
    [self.view addGestureRecognizer:notesTapGesture];
    notesView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 280, 50)];
    [notesView setDelegate:self];
    [notesView setCenter:CGPointMake(center.x, center.y - 75)];
    Session *mySession = [[SessionStore defaultStore] mySession];
    NSString *notesViewText;
    switch (swipedHeader.section) {
        case 0:
            notesViewText = [mySession scaleNotes];
            break;
        case 1:
            notesViewText = [mySession arpeggioNotes];
        default:
            notesViewText = [[[mySession pieceSession] objectAtIndex:swipedHeader.section - 2] pieceNotes];
            break;
    }
    [notesView setText:notesViewText];
    [self.view addSubview:notesView];
}
- (void)getRidOfNotes:(id)sender
{
    [notesView removeFromSuperview];
    [notesTapGesture setEnabled:NO];
    Session *mySession = [[SessionStore defaultStore] mySession];
    switch (swipedHeader.section) {
        case 0:
            [mySession setScaleNotes:[notesView text]];
            break;
        case 1:
            [mySession setArpeggioNotes:[notesView text]];
        default:
            [[[mySession pieceSession] objectAtIndex:swipedHeader.section - 2] setPieceNotes:[notesView text]];
            break;
    }
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        Session *mySession = [[SessionStore defaultStore] mySession];
        [textView resignFirstResponder];
        [textView removeFromSuperview];
        [notesTapGesture setEnabled:NO];
        switch (swipedHeader.section) {
            case 0:
                [mySession setScaleNotes:[textView text]];
                break;
            case 1:
                [mySession setArpeggioNotes:[textView text]];
            default:
                [[[mySession pieceSession] objectAtIndex:swipedHeader.section - 2] setPieceNotes:[textView text]];
                break;
        }
        return FALSE;
    }
    return TRUE;
}

- (void)sectionSwiped:(NSInteger)section headerView:(SectionHeaderView *)sectionHeaderView
{
    self.swipedHeader = sectionHeaderView;
}

- (UIView *)hitWithPoint:(CGPoint)point
{
    if (swipedHeader)
    {
        if ([notesView isDescendantOfView:self.view])
            return nil;
        CGRect frameOfExcludedArea = [self.view.superview convertRect:swipedHeader.deleteView.frame fromView:swipedHeader.deleteView.superview];
        if ((point.y > frameOfExcludedArea.origin.y-20) && (point.y < frameOfExcludedArea.origin.y-20 + frameOfExcludedArea.size.height))
        {
            if(point.x > (self.view.frame.size.width / 2))
                return swipedHeader.deleteButton;
            else
                return swipedHeader.notesButton;
        }
        else if (CGRectContainsPoint([notesView frame], point))
        {
            return notesView;
        }
        else if (CGRectContainsPoint([statsTable frame], point))
        {
            [swipedHeader cancelDelete:nil];
            [self setSwipedHeader:nil];
            return statsTable;
        }
        else 
        {
            [swipedHeader cancelDelete:nil];
            [self setSwipedHeader:nil];
             return nil;
        }
    }
    return nil;
}

//- (void)moveSection:(NSInteger)section headerView:(SectionHeaderView *)sectionHeaderView
//{
//    if (section > 1)
//    {
//        sectionMover = [[CustomSectionMove alloc] initWithFrame:[statsTable frame]
//                                               numberOfSections:[statsTable numberOfSections]
//                                                heightOfSection:[statsTable sectionHeaderHeight]];
//        [sectionMover setOldSection:section];
//        [sectionMover setDelegate:self];
//        [self.view addSubview:sectionMover];
//    }
//}

//- (void)sectionMoveLocationSelected:(NSInteger)section
//{
//    if (section > 1)
//    {
//        [[[sectionInfoArray objectAtIndex:[sectionMover oldSection]] headerView] setSection:section];
//        NSInteger largerSection = MAX([sectionMover oldSection], section);
//        NSInteger smallerSection = MIN([sectionMover oldSection], section);
//        for (int i = smallerSection; i < largerSection; i++)
//        {
//            [[[sectionInfoArray objectAtIndex:i] headerView] setSection:i + 1];
//            
//        }
//        SectionInfo *objectToMove = [sectionInfoArray objectAtIndex:[sectionMover oldSection]];
//        [sectionInfoArray removeObject:objectToMove];
//        [sectionInfoArray insertObject:objectToMove atIndex:section];
//        [sectionMover removeFromSuperview];
//        [statsTable beginUpdates];
//        [statsTable moveSection:[sectionMover oldSection] toSection:section];
//        [statsTable endUpdates];
//    }
//}
@end
