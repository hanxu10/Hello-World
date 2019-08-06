#import <UIKit/UIKit.h>
#import "AWESlidingTabbarProtocol.h"


typedef NS_ENUM(NSInteger, AWESlidingTabButtonStyle) {
    AWESlidingTabButtonStyleText = 0,
    AWESlidingTabButtonStyleIcon,
    AWESlidingTabButtonStyleIrregularText,   //不等宽Tab
    AWESlidingTabButtonStyleGeneralSearchSpecific,  //综搜特定布局
    AWESlidingTabButtonStyleIconAndText
};

@interface AWESlidingTabButton : UIButton

- (void)showDot:(BOOL)show color:(UIColor *)color;

@end

@interface AWESlidingTabbarView : UIView<AWESlidingTabbarProtocol>

@property (nonatomic, assign) BOOL shouldShowTopLine;
@property (nonatomic, assign) BOOL shouldShowBottomLine;
@property (nonatomic, assign) BOOL shouldShowSelectionLine;
@property (nonatomic, assign) BOOL shouldShowButtonSeperationLine;
@property (nonatomic, strong) UIColor *selectionLineColor;
@property (nonatomic, strong) UIColor *topBottomLineColor;

/**
 初始化方法

 @param frame tabview frame
 @param buttonStyle 按钮样式(图片/文字)
 @param scrollEnabled 是否可以滚动
 @param dataArray 图片名/标题的数组
 @param selectedDataArray 选中状态的图片名/标题的数组
 @return 初始化后的对象
 */
- (instancetype)initWithFrame:(CGRect)frame buttonStyle:(AWESlidingTabButtonStyle)buttonStyle scrollEnabled:(BOOL)scrollEnabled dataArray:(NSArray<NSString *> *)dataArray selectedDataArray:(NSArray<NSString *> *)selectedDataArray;

- (void)configureText:(NSString *)text image:(nullable UIImage *)image selectedText:(NSString *)selectedText selectedImage:(nullable UIImage *)selectedImage index:(NSInteger)index;
- (void)resetDataArray:(NSArray<NSString *> *)dataArray selectedDataArray:(NSArray<NSString *> *)selectedDataArray;
- (void)configureButtonTextColor:(UIColor *)color selectedTextColor:(UIColor *)selectedColor;
- (void)configureButtonTextFont:(UIFont *)font hasShadow:(BOOL)hasShadow;
- (void)configureButtonTextFont:(UIFont *)font selectedFont:(UIFont *)selectedFont;
- (void)configureTitlePadding:(CGFloat)padding;
- (void)configureTitleMinLength:(CGFloat)titleMinLength;
/**
 展示右上角的小圆点
 */
- (void)showButtonDot:(BOOL)show index:(NSInteger)index color:(UIColor *)color;
- (BOOL)isButtonDotShownOnIndex:(NSInteger)index;

@end
