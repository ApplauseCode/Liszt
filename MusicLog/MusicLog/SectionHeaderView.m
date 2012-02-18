#import "SectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+YellowTextColor.h"

@implementation SectionHeaderView


@synthesize titleLabel=_titleLabel, disclosureImage, delegate=_delegate, section=_section, tapGesture, swipeGesture, subTitleLabel, deleteView;


+ (Class)layerClass {
    
    return [CAGradientLayer class];
}


-(id)initWithFrame:(CGRect)frame title:(NSString*)title subTitle:(NSString *)subTitle section:(NSInteger)sectionNumber delegate:(id <SectionHeaderViewDelegate>)delegate {
    
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        _section = sectionNumber;
    
        deleteView = [[UIView alloc] initWithFrame:CGRectMake(-320, 0, 320, 45)];
        [deleteView setBackgroundColor:[UIColor whiteColor]];
        // Set up the tap gesture recognizer.
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
        swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSwipe:)];
        [self addGestureRecognizer:tapGesture];
        [self addGestureRecognizer:swipeGesture];

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
        titleLabelFrame.size.width -= 113;
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
        UILabel *subLabel = [[UILabel alloc] initWithFrame:subTitleLabelFrame];
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
    //[self toggleOpenWithUserAction:YES];
}


//-(void)toggleOpenWithUserAction:(BOOL)userAction {
//    
//    // Toggle the disclosure button state.
//    //self.disclosureButton.selected = !self.disclosureButton.selected;
//    
//    // If this was a user action, send the delegate the appropriate message.
//    if (userAction) {
//       // if (self.disclosureButton.selected) {
//            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
//                //[self.delegate sectionHeaderView:self sectionOpened:self.section];
//            }
//        }
//        else {
//            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
//               // [self.delegate sectionHeaderView:self sectionClosed:self.section];
//            }
//        }
//    }
//}

- (void)toggleSwipe:(id)sender
{

    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 45)];
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancel setBackgroundColor:[UIColor blueColor]];
    [cancel addTarget:self action:@selector(cancelDelete:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *delete = [[UIButton alloc] initWithFrame:CGRectMake(160, 0, 160, 45)];
    [delete setTitle:@"Delete" forState:UIControlStateNormal];
    [delete setBackgroundColor:[UIColor blueColor]];
    [delete addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
    [deleteView addSubview:delete];
    [deleteView addSubview:cancel];
    [self addSubview:deleteView];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
        [deleteView setFrame:CGRectMake(0.0, 0.0, 320, 45)];
        //[self setFrame:CGRectMake(640, 0, 320, 45)];
    } completion:^(BOOL finished) {
        [[self tapGesture] setEnabled:NO];
    }];
}

- (void)cancelDelete:(id)sender
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
        [deleteView setFrame:CGRectMake(-320, 0, 320, 45)];
    } completion:^(BOOL finished) {
        [deleteView removeFromSuperview];
        [[self tapGesture] setEnabled:YES];
    }];
    
}

- (void)deleteCell:(id)sender
{
    [[self delegate] deleteSection:self.section headerView:self];
}

@end
