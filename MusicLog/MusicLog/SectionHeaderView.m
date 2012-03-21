#import "SectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+YellowTextColor.h"
#import "DynamicLabel.h"

@implementation SectionHeaderView

@synthesize titleLabel=_titleLabel, disclosureImage, delegate=_delegate, section=_section, tapGesture, subTitleLabel, swipeGesture, deleteView, notesButton, deleteButton;

+ (Class)layerClass {
    
    return [CAGradientLayer class];
}

-(id)initWithFrame:(CGRect)frame title:(NSString*)title subTitle:(NSString *)subTitle section:(NSInteger)sectionNumber delegate:(id <SectionHeaderViewDelegate>)delegate {
    
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        _section = sectionNumber;
    
        deleteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [deleteView setBackgroundColor:[UIColor clearColor]];
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
        [deleteView setBackgroundColor:[UIColor whiteColor]];
        // Set up the tap gesture recognizer.
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
        swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSwipe:)];
        [swipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
        //ongTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(toggleLongTap:)];
        [self addGestureRecognizer:tapGesture];
        [self addGestureRecognizer:swipeGesture];
        //[self addGestureRecognizer:longTap];

        _delegate = delegate;        
        self.userInteractionEnabled = YES;
        
        UIImageView *bg;
        switch (sectionNumber) {
            case 0:
                bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SectionHeader1.png"]];
                break;
            case 1:
                bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SectionHeader2.png"]];
                break;
            default:
                bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SectionHeader3.png"]];
                break;
        }
        [self addSubview:bg];
        
        disclosureImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DisclosureArrow.png"]];
        CGRect disclosureFrame = self.bounds;
        disclosureFrame.origin.x += 24;
        disclosureFrame.origin.y = (0.5 * disclosureFrame.size.height) - 4;
        disclosureFrame.size.width = 6;
        disclosureFrame.size.height = 7;
        [disclosureImage setFrame:disclosureFrame];
        [self addSubview:disclosureImage];
        
        
        UIFont *caslon = [UIFont fontWithName:@"ACaslonPro-Regular" size:20];
        CGRect titleLabelFrame = self.bounds;
        titleLabelFrame.origin.x += 35;
        titleLabelFrame.origin.y += 3;
        titleLabelFrame.size.width -= 114;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
        [titleLabel setText:title];
        [titleLabel setFont:caslon];
        [titleLabel setTextColor:[UIColor yellowTextColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;
                               
        CGRect subTitleLabelFrame = self.bounds;
        subTitleLabelFrame.origin.x += 240;
        subTitleLabelFrame.origin.y += 3;
        subTitleLabelFrame.size.width -= 70;
        DynamicLabel *subLabel = [[DynamicLabel alloc] initWithFrame:subTitleLabelFrame];
        [subLabel setText:subTitle];
        [subLabel setFont:caslon];
        [subLabel setTextColor:[UIColor yellowTextColor]];
        [subLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:subLabel];
        subTitleLabel = subLabel;
    }
    
    return self;
}

- (void)turnDownDisclosure:(BOOL)yesOrNo
{
    if (yesOrNo)
        [disclosureImage setImage:[UIImage imageNamed:@"DisclosureArrowDown.png"]];
    else
        [disclosureImage setImage:[UIImage imageNamed:@"DisclosureArrow.png"]];
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

- (void)addNotes:(id)sender
{
    [[self delegate] displayNotesViewForSection:self.section headerView:self];
}
- (void)cancelDelete:(id)sender
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
        [deleteView setFrame:CGRectMake(0, 0, deleteView.frame.size.width, deleteView.frame.size.height)];
        [self setFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
    } completion:^(BOOL finished) {
       // [deleteView removeFromSuperview];
        [[self tapGesture] setEnabled:YES];
    }];
    
}

- (void)deleteCell:(id)sender
{
    [[self delegate] deleteSection:self.section headerView:self];
}

- (void)toggleLongTap:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
        [[self delegate] moveSection:self.section headerView:self];
}
@end
