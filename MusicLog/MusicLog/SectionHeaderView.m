#import "SectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+YellowTextColor.h"
#import "DynamicLabel.h"

@interface SectionHeaderView ()
@property (nonatomic, copy) NSString *aTitle;
@property (nonatomic, copy) NSString *aTime;
@end

@implementation SectionHeaderView
@synthesize aTitle;
@synthesize aTime;

static UIImage *_backgroundImage = nil;
static UIImage *_disclosureImage = nil;


@synthesize titleLabel=_titleLabel, disclosureImage, delegate=_delegate, section=_section, tapGesture, subTitleLabel, swipeGesture, deleteView, notesButton, deleteButton;

+ (Class)layerClass {
    
    return [CAGradientLayer class];
}

-(id)initWithFrame:(CGRect)frame title:(NSString*)title subTitle:(NSString *)subTitle section:(NSInteger)sectionNumber delegate:(id <SectionHeaderViewDelegate>)delegate 
{
    
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self setBackgroundColor:[UIColor clearColor]];
        _section = sectionNumber;
        _delegate = delegate;  
        aTitle = title;
        DynamicLabel *dLabel = [[DynamicLabel alloc] initWithFrame:CGRectZero];
        subTitleLabel = dLabel;
        _disclosureImage = [UIImage imageNamed:@"DisclosureArrow.png"];
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
        [self addGestureRecognizer:tapGesture];
        swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSwipe:)];
        [swipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self addGestureRecognizer:swipeGesture];
        
        deleteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [deleteView setBackgroundColor:[UIColor whiteColor]];
        [deleteView setOpaque:NO];
        notesButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 45)];
        [notesButton setTitle:@"Notations" forState:UIControlStateNormal];
        [notesButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [notesButton setBackgroundColor:[UIColor clearColor]];
        [notesButton setOpaque:NO];
        [notesButton addTarget:self action:@selector(addNotes:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 0, 160, 45)];
        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        [deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [deleteButton setOpaque:NO];
        [deleteButton setBackgroundColor:[UIColor clearColor]];
        [deleteButton addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
        [deleteView addSubview:deleteButton];
        [deleteView addSubview:notesButton];
        [self insertSubview:deleteView belowSubview:self];
        [deleteView setHidden:YES];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    UIColor *blackColor = [UIColor blackColor];
//    [blackColor set];
    switch ([self section] % 3) {
        case 0:
            _backgroundImage = [UIImage imageNamed:@"SectionHeader1.png"];
            break;
        case 1:
            _backgroundImage = [UIImage imageNamed:@"SectionHeader2.png"];
            break;    
        default:
            _backgroundImage = [UIImage imageNamed:@"SectionHeader3.png"];
            break;
    }    
    [_backgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    UIColor *textColor = [UIColor yellowTextColor];
    [textColor set];
    [aTitle drawAtPoint:CGPointMake(37, 14)
                   forWidth:135
                   withFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:18]
              lineBreakMode:UILineBreakModeTailTruncation];
    aTime = [subTitleLabel timeString];
    [@"00:17:26" drawAtPoint:CGPointMake(240, 13)
               forWidth:70
               withFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:18]
          lineBreakMode:UILineBreakModeTailTruncation];
    [_disclosureImage drawInRect:CGRectMake(25, 17, 6, 7)];
}

//-(id)initWithFrame:(CGRect)frame title:(NSString*)title subTitle:(NSString *)subTitle section:(NSInteger)sectionNumber delegate:(id <SectionHeaderViewDelegate>)delegate {
//    
//    self = [super initWithFrame:frame];
//    
//    if (self != nil) {
//        _section = sectionNumber;
////        _backgroundImage = [UIImage imageNamed:@"SectionHeader1.png"];
//
//        // *** Don't forget to fix the -5 ***
//        deleteView = [[UIView alloc] initWithFrame:CGRectMake(0, 2, self.frame.size.width, self.frame.size.height - 5)];
//        
//        [deleteView setBackgroundColor:[UIColor clearColor]];
//        [deleteView setOpaque:NO];
//        notesButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 45)];
//        [notesButton setTitle:@"Notations" forState:UIControlStateNormal];
//        [notesButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [notesButton setBackgroundColor:[UIColor clearColor]];
//        [notesButton setOpaque:NO];
//        [notesButton addTarget:self action:@selector(addNotes:) forControlEvents:UIControlEventTouchUpInside];
//        deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 0, 160, 45)];
//        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
//        [deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [deleteButton setOpaque:NO];
//        [deleteButton setBackgroundColor:[UIColor clearColor]];
//        [deleteButton addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
//        [deleteView addSubview:deleteButton];
//        [deleteView addSubview:notesButton];
//        [self insertSubview:deleteView belowSubview:self];
//        [deleteView setBackgroundColor:[UIColor whiteColor]];
//        // Set up the tap gesture recognizer.
//        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
//        swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSwipe:)];
//        [swipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
//        //ongTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(toggleLongTap:)];
//        [self addGestureRecognizer:tapGesture];
//        [self addGestureRecognizer:swipeGesture];
//        //[self addGestureRecognizer:longTap];
//
//        _delegate = delegate;        
//        self.userInteractionEnabled = YES;
//        
//        UIImageView *bg;
//        switch (sectionNumber) {
//            case 0:
//                bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SectionHeader1.png"]];
//                break;
//            case 1:
//                bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SectionHeader2.png"]];
//                break;
//            default:
//                bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SectionHeader3.png"]];
//                break;
//        }
//        [self addSubview:bg];
//               disclosureImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DisclosureArrow.png"]];
//        CGRect disclosureFrame = self.bounds;
//        disclosureFrame.origin.x += 24;
//        disclosureFrame.origin.y = (0.5 * disclosureFrame.size.height) - 4;
//        disclosureFrame.size.width = 6;
//        disclosureFrame.size.height = 7;
//        [disclosureImage setFrame:disclosureFrame];
//        [self addSubview:disclosureImage];
//        
//        
//        UIFont *caslon = [UIFont fontWithName:@"ACaslonPro-Regular" size:20];
//        CGRect titleLabelFrame = self.bounds;
//        titleLabelFrame.origin.x += 35;
//        titleLabelFrame.origin.y += 3;
//        titleLabelFrame.size.width -= 114;
//        UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
//        [titleLabel setText:title];
//        [titleLabel setFont:caslon];
//        [titleLabel setTextColor:[UIColor yellowTextColor]];
//        [titleLabel setBackgroundColor:[UIColor clearColor]];
//        [self addSubview:titleLabel];
//        _titleLabel = titleLabel;
//                               
//        CGRect subTitleLabelFrame = self.bounds;
//        subTitleLabelFrame.origin.x += 240;
//        subTitleLabelFrame.origin.y += 3;
//        subTitleLabelFrame.size.width -= 70;
//        DynamicLabel *subLabel = [[DynamicLabel alloc] initWithFrame:subTitleLabelFrame];
//        [subLabel setText:subTitle];
//        [subLabel setFont:caslon];
//        [subLabel setTextColor:[UIColor yellowTextColor]];
//        [subLabel setBackgroundColor:[UIColor clearColor]];
//        [self addSubview:subLabel];
//        subTitleLabel = subLabel;
//    }
//   
//    return self;
//}
//
- (void)turnDownDisclosure:(BOOL)yesOrNo
{
    if (yesOrNo) {
//        [disclosureImage setImage:[UIImage imageNamed:@"DisclosureArrowDown.png"]];
        _disclosureImage = [UIImage imageNamed:@"DisclosureArrowDown.png"];
        [self setNeedsDisplay];
    }
    else {
//        [disclosureImage setImage:[UIImage imageNamed:@"DisclosureArrow.png"]];
        _disclosureImage = [UIImage imageNamed:@"DisclosureArrow.png"];
        [self setNeedsDisplay];
    }
}

- (void)setSubTitle:(NSString *)subName
{
    [subTitleLabel setText:subName];
}


-(void)toggleOpen:(id)sender {
    [self.delegate sectionHeaderView:self tapped:self.section];
}

- (void)toggleSwipe:(id)sender
{
    [[self delegate] sectionSwiped:self.section headerView:self];
    [deleteView setHidden:NO];
    [UIView animateWithDuration:0.2 animations:^{        
        // Move the side swipe view to offset 0
        deleteView.frame = CGRectMake(self.frame.size.width, 0, deleteView.frame.size.width, deleteView.frame.size.height);
        // While simultaneously moving the cell's frame offscreen
        // The net effect is that the side swipe view is pushing the cell offscreen
        self.frame = CGRectMake(-self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [[self tapGesture] setEnabled:NO];
    }];
}
//
//- (void)addNotes:(id)sender
//{
//    [[self delegate] displayNotesViewForSection:self.section headerView:self];
//}

- (void)cancelDelete:(id)sender
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
        [deleteView setFrame:CGRectMake(0, 0, deleteView.frame.size.width, deleteView.frame.size.height)];
        [self setFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
    } completion:^(BOOL finished) {
       // [deleteView removeFromSuperview];
        [deleteView setHidden:YES];
        [[self tapGesture] setEnabled:YES];
    }];
}
//
//- (void)deleteCell:(id)sender
//{
//    [[self delegate] deleteSection:self.section headerView:self];
//}
//
//- (void)toggleLongTap:(UILongPressGestureRecognizer *)sender
//{
//    if (sender.state == UIGestureRecognizerStateBegan)
//        [[self delegate] moveSection:self.section headerView:self];
//}


@end
