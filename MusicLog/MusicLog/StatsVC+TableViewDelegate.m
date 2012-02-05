//
//  StatsVC+TableViewDelegate.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatsVC+TableViewDelegate.h"
#import "ScaleStore.h"
#import "SectionInfo.h"
#import "Session.h"
#import "Timer.h"
#import "Scale.h"
#import "Piece.h"
#import "ScalesPracticedCell.h"
#import "TimerCell.h"
#import "NSString+Number.h"

@implementation StatsVC (TableViewDelegate)

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (2 + [[selectedSession pieceSession] count]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    NSInteger numRowsInSection;
    numRowsInSection = [sectionInfo countofRowsToInsert] + 1;
    if (section > 1)
        return (sectionInfo.open) ? numRowsInSection : 0;
    else if ((numRowsInSection == 1) || (!sectionInfo.open)) 
        return 0;
    else
        return numRowsInSection;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    if ((!sectionInfo.headerView) || (section < 2)) 
    {
		NSString *sectionName = sectionInfo.title;
        sectionInfo.headerView = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, statsTable.bounds.size.width, 45) title:sectionName subTitle:@"" section:section delegate:self];
        NSString *time;
        if (currentPractice)
        {
            if (section ==  0)
                time = [scaleTimer timeString];
            else if (section == 1)
                time = [arpeggioTimer timeString];
        }
        else
        {
            if (section == 0)
                time = [NSString TimeStringFromInt:[selectedSession scaleTime]];
            else if (section == 1)
                time = [NSString TimeStringFromInt:[selectedSession arpeggioTime]];
        }
        if (section > 1)
        {
            time = [[[[selectedSession pieceSession] objectAtIndex:(section - 2)] timer] timeString];
        }
        [sectionInfo.headerView setSubTitle:time];

    }
    return sectionInfo.headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    ScalesPracticedCell *cell = (ScalesPracticedCell *)[tableView
                                                         dequeueReusableCellWithIdentifier:@"ScalesPracticedCell"];
    if (row == 0)
        return tCell;
    
    id entry;
    if (section == 0)
        entry = [[selectedSession scaleSession] objectAtIndex:([indexPath row] - 1)];
    else if (section == 1)
        entry = [[selectedSession arpeggioSession] objectAtIndex:([indexPath row] - 1)];
    if (section < 2)
    {
        cell.tonicLabel.text = [entry tonicString];
        cell.modeLabel.text = [entry modeString];
        cell.rhythmLabel.text = [entry rhythmString];
        cell.speedLabel.text = [entry tempoString];
        cell.octavesLabel.text = [entry octavesString];
    }
    else
    {
        entry = [[selectedSession pieceSession] objectAtIndex:([indexPath section] - 2)];
        cell.tonicLabel.text = [entry title];
        cell.modeLabel.text = [entry composer];
        cell.rhythmLabel.text = [entry keyString];
        cell.speedLabel.text = [NSString stringWithInt:[entry tempo]];
        if ([entry major])
            cell.octavesLabel.text = @"Major";
        else
            cell.octavesLabel.text = @"Minor";
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;    
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
            removers = [[ScaleStore defaultStore] scalesInSession];
            cellToRemove = [removers objectAtIndex:[indexPath row] - 1];
            [[ScaleStore defaultStore] removeScale:cellToRemove];
            [[ScaleStore defaultStore] addScalesToSession];
            [[sectionInfoArray objectAtIndex:0] setCountofRowsToInsert:[[selectedSession scaleSession] count]];
        }
        else if (section == 1)
        {
            removers = [[ScaleStore defaultStore] arpeggiosInSession];
            cellToRemove = [removers objectAtIndex:[indexPath row] - 1];
            [[ScaleStore defaultStore] removeArpeggio:cellToRemove];
            [[ScaleStore defaultStore] addArpeggiosToSession];
            [[sectionInfoArray objectAtIndex:1] setCountofRowsToInsert:[[selectedSession arpeggioSession] count]];
        }
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}



@end
