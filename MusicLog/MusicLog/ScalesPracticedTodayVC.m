//
//  ScalesPracticedToday.m
//  InstrumentLog
//
//  Created by Kyle Rosenbluth on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScalesPracticedTodayVC.h"
#import "ScalesPracticedCell.h"
#import "Scale.h"
#import "ScalePickerVC.h"
#import "AppDelegate.h"
#import "ScaleStore.h"

@implementation ScalesPracticedTodayVC
@synthesize scalesTableView;
@synthesize startTimerButton;

- (id)init 
{
    self = [super initWithNibName:@"ScalesPracticedTodayVC" bundle:nil];

    if (self) {
    [self setTitle:@"ScalesPracticedTodayVC"];
    
    // Create a set to see if timer should display 0 before minutes
    NSMutableArray *setArray = [[NSMutableArray alloc] init];
    for (int i = 0; i <= 9; i++)
    {
        NSNumber *myInt = [NSNumber numberWithInt:i];
        [setArray addObject:myInt];
    }
    zeroThroughNine = [NSSet setWithArray:setArray];
    }
    
    return self; 
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
} 

#pragma mark -
#pragma mark === View Lifecycle ===
#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Scales" image:[UIImage imageNamed:@"glyphicons_017_music"] tag:2];
    
    // Register the customCell.xib
    UINib *nib = [UINib nibWithNibName:@"ScalesPracticedCell" bundle:nil];
    [scalesTableView registerNib:nib 
          forCellReuseIdentifier:@"ScalesPracticedCell"];
    
    // Set top bar title to todays date
    NSDate *todaysDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM d"];
    [[self navigationItem] setTitle:[dateFormat stringFromDate:todaysDate]];
    
    // Create two navbar buttons
    UIBarButtonItem *doneWithSessionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishedSession:)];
    self.navigationItem.rightBarButtonItem = doneWithSessionButton; 
    
    UIBarButtonItem *clearAllButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear All" style:UIBarButtonItemStylePlain target:self action:@selector(clearAll:)];
    self.navigationItem.leftBarButtonItem = clearAllButton; 
    [clearAllButton setTitle:@"Clear All"];
    
    // Create a plus button that appears on the tabBar
    UIImage *plusButton = [UIImage imageNamed:@"plusbutton.png"];
    UIView *tabBarView = [[self tabBarController] view];
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //[addButton setFrame:CGRectMake(105, 432.0, 110.0, 49.0)];
    [addButton setFrame:CGRectMake(127.0, 432.0, [plusButton size].width, [plusButton size].height)];
    [addButton setBackgroundImage:plusButton forState:UIControlStateNormal];
    [tabBarView addSubview:addButton];
    [addButton addTarget:self action:@selector(scalePicker:) forControlEvents:UIControlEventTouchUpInside];
    
    // Configure the appearance of buttons and labels
    [timerLabel setText:@"00:00"];
    [startTimerButton setTitle:@"Start" forState:UIControlStateNormal];
    [resetTimerButton setTitle:@"Reset" forState:UIControlStateNormal];
    [resetTimerButton setEnabled:NO];
    [resetTimerButton setAlpha:0.5];
    
    // set the scrolling bottom between metronome and timer
    [scrollView setFrame:CGRectMake(0.0, 310.0, 320.0, 57.0)];
     
    [scrollView setContentSize:CGSizeMake(640.0, 57.0)];
    [scrollView setPagingEnabled:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setDelegate:self];
    
    [scrollView addSubview:startTimerButton];
    [scrollView addSubview:resetTimerButton];
    [scrollView addSubview:timerLabel];
    
    [pageControl setNumberOfPages:2];
    [pageControl setCurrentPage:0];
    //[self loadScrollViewWithPage:0];
    //[self loadScrollViewWithPage:1];
}

- (void)viewDidUnload
{
    scrollView = nil;
    pageControl = nil;
    timerView = nil;
    metronomeView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{    
    [super viewWillAppear:animated];
    
    // refresh the data so that the tableview will load the new info added by the user
    [self.scalesTableView reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark === Timer ===
#pragma mark -

- (IBAction)startTimer:(id)sender
{
    if ([[startTimerButton currentTitle] isEqual:@"Start"])
    {
        // Start the timer.
        if (onlyOneTimer < 1) {
            // Create a pointer to the current run loop and add the timer so that it continues while scrolling the TableView.
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
            [runLoop addTimer:timer forMode:NSRunLoopCommonModes];
            [runLoop addTimer:timer forMode:UITrackingRunLoopMode];
        }
        
        [startTimerButton setTitle:@"Stop" forState:UIControlStateNormal];
        onlyOneTimer++;
        
    } else if ([[startTimerButton currentTitle] isEqual:@"Stop"]) {
        // turn off the timer
        [timer invalidate];
        [resetTimerButton setEnabled:YES];
        [resetTimerButton setAlpha:1.0];
        [startTimerButton setTitle:@"Start" forState:UIControlStateNormal];
        
        onlyOneTimer--;
    }
}

- (IBAction)resetTimer:(id)sender
{
    
    [timer invalidate];
    
    minutes *= 60;
    timePracticed = minutes + seconds;
    minutes = 0;
    seconds = 0;
    
    [resetTimerButton setEnabled:NO];
    [resetTimerButton setAlpha:0.5];
    [resetTimerButton setTitle:@"Reset" forState:UIControlStateNormal];
    [timerLabel setText:@"00:00"];
    [startTimerButton setTitle:@"Start" forState:UIControlStateNormal];
    
    onlyOneTimer --;
}

- (void)timerFireMethod:(NSTimer *)theTimer
{    
    seconds += 1;
    
    // Check for minutes
    if ((seconds % 60) == 0)
    {
        minutes++;
        seconds = 0;
    }
    
    NSNumber *minutesObject = [NSNumber numberWithInt:minutes];
    
    // format timer label
    if ([zeroThroughNine member:minutesObject]) 
    {
        [timerLabel setText:[NSString stringWithFormat:@"0%d: %d" , minutes, seconds]];
    } else {
        [timerLabel setText:[NSString stringWithFormat:@"%d: %d" , minutes, seconds]];
    }
}




#pragma mark -
#pragma mark === Actions ===
#pragma mark -

-(void) scalePicker:(id)sender
{
    // create the view scalePicker, set it's title and place it on the top of the view hierarchy
    if ([[[[self navigationController] topViewController] title] isEqual:@"ScalesPracticedTodayVC"]) {
    sp = [[ScalePickerVC alloc] init];
    UINavigationController *pickerNavController = [[UINavigationController alloc] initWithRootViewController:sp];
    [[pickerNavController tabBarItem] setTitle:@"Scale Picker"];
        
    [self presentModalViewController:pickerNavController animated:YES];
    }
}

- (void)clearAll:(id)sender
{
    UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Are you sure you want to erase all of your scales?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    
    [warning show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [[ScaleStore defaultStore] clearAll];
        [scalesTableView reloadData];
    }
}

- (void)finishedSession:(id)sender
{
    [[ScaleStore defaultStore] addSession];
}

- (void)scrollViewDidScroll:(UIScrollView *)myScrollView
{
    CGFloat pageWidth = myScrollView.frame.size.width;
    int page = floor((myScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark === Table view data source ===
#pragma mark -

 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
} 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[ScaleStore defaultStore] scalesInSession] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Display the custom cell with the values set by the user in the scalePicker screen
        
    ScalesPracticedCell *cell = (ScalesPracticedCell *) [tableView
                                       dequeueReusableCellWithIdentifier:@"ScalesPracticedCell"];
/*    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ScalesPracticedCell" owner:self options:nil];
        for (id oneObject in nib) 
            if ([oneObject isKindOfClass:[ScalesPracticedCell class]]) 
                cell = (ScalesPracticedCell *)oneObject; 
 } */ 
    
    cell.tonicLabel.text = [[[[ScaleStore defaultStore] scalesInSession] objectAtIndex:[indexPath row]] tonicString];
    cell.modeLabel.text = [[[[ScaleStore defaultStore] scalesInSession] objectAtIndex:[indexPath row]] modeString];
    cell.rhythmLabel.text = [[[[ScaleStore defaultStore] scalesInSession] objectAtIndex:[indexPath row]] rhythmString];
    cell.speedLabel.text = [[[[ScaleStore defaultStore] scalesInSession] objectAtIndex:[indexPath row]] tempoString];
    cell.octavesLabel.text = [[[[ScaleStore defaultStore] scalesInSession] objectAtIndex:[indexPath row]] octavesString];
 
    // set the cells to not highlight when selected.
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [[self scalesTableView] setEditing:editing animated:animated];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source
        NSOrderedSet *scales = [[ScaleStore defaultStore] scalesInSession];
        Scale *s = [scales objectAtIndex:[indexPath row]];
        [[ScaleStore defaultStore] removeScale:s];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Table view delegate
/* - (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[cell contentView] setBackgroundColor:[UIColor greenColor]];
    [[cell valueForKey:@"cellView"] setBackgroundColor:[UIColor redColor]];
    NSLog(@"%@", [cell performSelector:@selector(recursiveDescription)]);
} */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
  //  [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
}

@end
