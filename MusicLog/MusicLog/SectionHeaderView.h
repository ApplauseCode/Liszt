

#import <Foundation/Foundation.h>

@protocol SectionHeaderViewDelegate;


@interface SectionHeaderView : UIView 

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *subTitleLabel;
@property (nonatomic, strong) UIImageView *disclosureImage;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGesture;
@property (nonatomic, strong) UIView *deleteView;
@property (nonatomic, weak) id <SectionHeaderViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame title:(NSString*)title subTitle:(NSString *)subTitle section:(NSInteger)sectionNumber delegate:(id <SectionHeaderViewDelegate>)delegate;
//-(void)toggleOpenWithUserAction:(BOOL)userAction;
- (void)setSubTitle:(NSString *)subName;
- (void)toggleSwipe:(id)sender;
- (void)cancelDelete:(id)sender;
- (void)deleteCell:(id)sender;
- (void)turnDownDisclosure:(BOOL)yesOrNo;

@end



/*
 Protocol to be adopted by the section header's delegate; the section header tells its delegate when the section should be opened and closed.
 */
@protocol SectionHeaderViewDelegate <NSObject>

@optional
- (void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView tapped:(NSInteger)section;
- (void)deleteSection:(NSInteger)section headerView:(SectionHeaderView *)sectionHeaderView;
@end

