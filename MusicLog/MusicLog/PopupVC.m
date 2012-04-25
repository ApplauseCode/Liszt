//
//  PopupVC.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PopupVC.h"

@interface PopupVC ()
@property (nonatomic, assign) CGRect frame;
@end

@implementation PopupVC
@synthesize staticTable;
@synthesize numberOfRows;
@synthesize staticCells;
@synthesize frame;
@synthesize delegate;

- (id)initWithFrame:(CGRect)_frame
{
    self = [super init];
    if (self)
    {
        frame = _frame;
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropBarBkg.png"]]];
    staticTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    [staticTable setBackgroundColor:[UIColor clearColor]];
    [staticTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:staticTable];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [staticTable setDelegate:self];
    [staticTable setDataSource:self];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [staticCells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PopupCell *currentCell = [staticCells objectAtIndex:[indexPath row]];
    [currentCell setDelegate:self];
    return currentCell;
}

- (void)cellButtonPressedAtIndex:(NSInteger)idx
{
    [[self delegate] cellSelectedAtIndex:idx];
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

@end
