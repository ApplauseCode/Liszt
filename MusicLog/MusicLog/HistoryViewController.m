//
//  HistoryViewController.m
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 3/20/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryCell.h"

@interface HistoryViewController ()

@property (nonatomic, strong) NSArray *tableData;
@end

@implementation HistoryViewController
@synthesize tableData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        tableData = [NSArray arrayWithObjects:@"Alpha", @"Beta", @"Gamma", @"Delta", @"Omicron", @"Pi",
                     @"Mu",@"Nu",@"Rho",@"Delta",@"Kappa", @"Sigma",@"Epsilon",@"Iota",@"Lambda", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [tableData count];
}
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryCell *cell;
        cell = (HistoryCell *)[tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];
        if (cell == nil) 
            cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HistoryCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone; 
    [cell setTempLabel:[tableData objectAtIndex:[indexPath row]]];    
    return cell;
}

@end
