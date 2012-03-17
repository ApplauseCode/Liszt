//
//  StatsVC+TableViewDelegate.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatsVC+TableViewDelegate.h"
#import "SessionStore.h"
#import "SectionInfo.h"
#import "Session.h"
#import "Timer.h"
#import "Scale.h"
#import "Piece.h"
#import "ScalesPracticedCell.h"
#import "TimerCell.h"
#import "NSString+Number.h"
#import "LisztCell.h"
#import "ScaleCell.h"
#import "PieceCell.h"
#import "NotesVC.h"

@implementation StatsVC (TableViewDelegate)

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == 0 && currentPractice)
        return 27;
    return 42;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (2 + [[selectedSession pieceSession] count]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    NSInteger numRowsInSection;
    
    if (currentPractice)
        numRowsInSection = [sectionInfo countofRowsToInsert] + 1;
    else
        numRowsInSection = [sectionInfo countofRowsToInsert];
    return (sectionInfo.open) ? numRowsInSection : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    Session *s = [[SessionStore defaultStore] mySession];
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
		NSString *sectionName = sectionInfo.title;
        sectionInfo.headerView = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, statsTable.bounds.size.width, 42) title:[sectionName capitalizedString] subTitle:@"" section:section delegate:self];
    NSString *time;
    if (currentPractice)
    {
        if (section ==  0)
            time = [NSString timeStringFromInt:[s scaleTime]];
        else if (section == 1)
            time = [NSString timeStringFromInt:[s arpeggioTime]];
        else
        {
            Piece *currentPiece = [[s pieceSession] objectAtIndex:(section - 2)];
            time = [NSString timeStringFromInt:[currentPiece pieceTime]];             
        }
    }
    else
    {
        if (section == 0)
            time = [NSString timeStringFromInt:[selectedSession scaleTime]];
        else if (section == 1)
            time = [NSString timeStringFromInt:[selectedSession arpeggioTime]];
        else
            time = [NSString timeStringFromInt:[[[selectedSession pieceSession] objectAtIndex:(section - 2)] pieceTime]];
    }
    [sectionInfo.headerView setSubTitle:time];
    if (sectionInfo.open)
        [sectionInfo.headerView turnDownDisclosure:YES];
    else
        [sectionInfo.headerView turnDownDisclosure:NO];
    return sectionInfo.headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    LisztCell *cell;
    id entry;
    if (section < 2) {
        cell = (ScaleCell *)[tableView dequeueReusableCellWithIdentifier:@"ScaleCell"];
        if (cell == nil) 
            cell = [[ScaleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ScaleCell"];
    }
    else {
        cell = (PieceCell *)[tableView dequeueReusableCellWithIdentifier:@"PieceCell"];
        if (cell == nil) 
            cell = [[PieceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PieceCell"];
    }
    NSInteger dataIndex;
    if (row == 0 && currentPractice)
        return tCell;
    if (!currentPractice)
        dataIndex = row;
    else
        dataIndex = row - 1;
    if (section == 0)
        entry = [[selectedSession scaleSession] objectAtIndex:dataIndex];
    else if (section == 1)
        entry = [[selectedSession arpeggioSession] objectAtIndex:dataIndex];
    else {
        entry = [[selectedSession pieceSession] objectAtIndex:([indexPath section] - 2)];
    }
    [cell updateLabels:entry];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


#pragma mark - Table View Editing -

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [statsTable setEditing:editing animated:animated];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    if (![indexPath row]) return NO;
    if (section < 2)
        return YES;
    else
        return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{  
    int section = [indexPath section];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSOrderedSet *removers;
        id cellToRemove;
        
        if (section == 0)
        {
            removers = [[[SessionStore defaultStore] mySession] scaleSession];
            cellToRemove = [removers objectAtIndex:[indexPath row] - 1];
            [[[[SessionStore defaultStore] mySession] scaleSession] removeObject:cellToRemove];
            [[sectionInfoArray objectAtIndex:0] setCountofRowsToInsert:[[selectedSession scaleSession] count]];
        }
        else if (section == 1)
        {
            removers = [[[SessionStore defaultStore] mySession] arpeggioSession];
            cellToRemove = [removers objectAtIndex:[indexPath row] - 1];
            [[[[SessionStore defaultStore] mySession] arpeggioSession] removeObject:cellToRemove];
            [[sectionInfoArray objectAtIndex:1] setCountofRowsToInsert:[[selectedSession arpeggioSession] count]];
        }
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if ([statsTable numberOfRowsInSection:section] == 1)
            [self closeSections];
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotesVC *notes = [[NotesVC alloc] initWithIndexPath:indexPath session:selectedSession];
    [self presentViewController:notes animated:YES completion:^{
        
    }];
}
@end
