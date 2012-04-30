//
//  InfoViewController.m
//  Split
//
//  Created by Jeffrey Rosenbluth on 12/27/11.
//  Copyright (c) 2011 Applause Code. All rights reserved.
//

#import "InfoViewController.h"

@implementation InfoViewController
@synthesize fullScrollView;
@synthesize scrollView;
@synthesize drop;
@synthesize geometryProof;
@synthesize convexity;
@synthesize alertMe;
@synthesize faSchedule;
@synthesize twitter;
@synthesize website;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"About"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *lbbi = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(done:)];
    [[self navigationItem] setLeftBarButtonItem:lbbi];
    [scrollView setContentSize:CGSizeMake(520, 52)];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [fullScrollView setContentSize:CGSizeMake(320, 640)];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(removeInfoView:) 
                                                 name: UIApplicationWillResignActiveNotification
                                               object: nil];

}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setDrop:nil];
    [self setGeometryProof:nil];
    [self setConvexity:nil];
    [self setAlertMe:nil];
    [self setFaSchedule:nil];
    [self setFullScrollView:nil];
    [self setTwitter:nil];
    [self setWebsite:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    CGPoint dropCenter = [[self drop] center];
    CGPoint geomCenter = [[self geometryProof] center];
    CGPoint convCenter = [[self convexity] center];
    CGPoint alerCenter = [[self alertMe] center];
    CGPoint fascCenter = [[self faSchedule] center];
    CGPoint startCenter = CGPointMake(-50, [drop center].y);
    [drop setCenter:startCenter];
    [geometryProof setCenter:startCenter];
    [convexity setCenter:startCenter];
    [alertMe setCenter:startCenter];
    [faSchedule setCenter:startCenter];
    [UIView animateWithDuration:.7 
                          delay:0 
                        options:UIViewAnimationOptionCurveEaseIn 
                     animations:^{
                         [drop setCenter:dropCenter];
                         [geometryProof setCenter:geomCenter];
                         [convexity setCenter:convCenter];
                         [alertMe setCenter:alerCenter];
                         [faSchedule setCenter:fascCenter];}                    
                         completion:^(BOOL finished) {}];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)done:(id)sender {
    [[self navigationController] dismissModalViewControllerAnimated:YES];
}

- (void)removeInfoView:(id)sender {
    [[self navigationController] dismissModalViewControllerAnimated:NO];
}

- (IBAction)toURL:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Coming Soon" message:nil delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
    if (sender == drop)
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/drop!/id415884044?mt=8"]];
    else if (sender == faSchedule)
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/faschedule/id472827413?mt=8"]];
    else if (sender == geometryProof)
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/geometry-proof/id479753226?mt=8"]];
    else if (sender == convexity)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/convexity/id492001353?mt=8"]];
    else if (sender == alertMe)
        [alertView show];
    else if (sender == twitter)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/#!/getliszt"]];
    else if (sender == website)
    {
        Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
        if (mailClass != nil)
        {
            // We must always check whether the current device is configured for sending emails
            if ([mailClass canSendMail])
            {
                [self displayComposerSheet];
            }
            else
            {
                [self launchMailAppOnDevice];
            }
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
}

-(void)displayComposerSheet 
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"Liszt"];
    
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"kyle@applausecode.com"]; 
	[picker setToRecipients:toRecipients];
	
	[self presentModalViewController:picker animated:YES];
}

-(void)launchMailAppOnDevice
{
	NSString *recipients = @"mailto:kyle@applausecode.com";	
	NSString *email = [NSString stringWithFormat:@"%@", recipients];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
    [self dismissModalViewControllerAnimated:YES];
}

@end
