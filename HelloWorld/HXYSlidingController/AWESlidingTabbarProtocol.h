#import <Foundation/Foundation.h>
@class AWESlidingViewController;

@protocol AWESlidingTabbarProtocol <NSObject>

@property (nonatomic, weak) AWESlidingViewController *slidingViewController;
@property (nonatomic, assign) NSInteger selectedIndex;

- (void)slidingControllerDidScroll:(UIScrollView *)scrollView;

@optional
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated tapped:(BOOL)tapped;

@end
