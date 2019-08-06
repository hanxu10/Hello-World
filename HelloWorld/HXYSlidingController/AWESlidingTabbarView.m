#import "AWESlidingTabbarView.h"
#import "AWESlidingViewController.h"

static const CGFloat kTitleMinLength = 48;   //文字最小显示长度
static const CGFloat kTitlePadding = 16;     //文字两边间距
static const CGFloat kTitleMinLengthForGeneralSearch = 30;  //综搜tab样式特定参数
static const CGFloat kTitleAndIconSpace = 1.f;

@interface AWESlidingTabButton ()

@property (nonatomic, assign) AWESlidingTabButtonStyle buttonStyle;
@property (nonatomic, strong) UIView *circleDot;     //右上角的小点
@property (nonatomic, assign) CGFloat buttonWidth;   //button宽度
@property (nonatomic, assign) CGFloat lineWidth;     //底部黄线宽度
@property (nonatomic, assign) CGFloat lineX;         //底部黄线x坐标
@property (nonatomic, strong) UIFont *normalFont;
@property (nonatomic, strong) UIFont *selectedFont;
@property (nonatomic, assign) CGFloat titlePadding;

@end

@implementation AWESlidingTabButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.imageView.contentMode = UIViewContentModeCenter;
        [self setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
        
        self.circleDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
        self.circleDot.clipsToBounds = YES;
        self.circleDot.layer.cornerRadius = 3;
        self.circleDot.hidden = YES;
        
        self.selectedFont = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        self.normalFont = [UIFont systemFontOfSize:15];
        
        self.titlePadding = 16;
        if (self.buttonStyle == AWESlidingTabButtonStyleGeneralSearchSpecific) {
            self.titlePadding = 0;
        }
        [self addSubview:self.circleDot];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.circleDot.frame;
    frame.origin.x = self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width;
    frame.origin.y = self.center.y - 10;
    self.circleDot.frame = frame;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    if (self.buttonStyle == AWESlidingTabButtonStyleIcon) {
        return CGRectMake(16, 0, contentRect.size.width - 32, contentRect.size.height);
    } else if (self.buttonStyle == AWESlidingTabButtonStyleIconAndText) {
        return [super imageRectForContentRect:contentRect];
    } else {
        return CGRectZero;
    }
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    if (self.buttonStyle == AWESlidingTabButtonStyleIrregularText || self.buttonStyle == AWESlidingTabButtonStyleGeneralSearchSpecific) {
        return [super titleRectForContentRect:contentRect];
    } else if (self.buttonStyle == AWESlidingTabButtonStyleIconAndText) {
        return [super titleRectForContentRect:contentRect];
    } else if (self.buttonStyle == AWESlidingTabButtonStyleText) {
        return CGRectMake(self.titlePadding, 0, contentRect.size.width - 2 * self.titlePadding, contentRect.size.height);
    } else {
        return CGRectZero;
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        self.titleLabel.font = self.selectedFont;
    } else {
        self.titleLabel.font = self.normalFont;
    }
}

- (void)showDot:(BOOL)show color:(UIColor *)color
{
    self.circleDot.hidden = !show;
    self.circleDot.backgroundColor = color;
}

- (BOOL)isDotShown
{
    return !self.circleDot.hidden;
}

- (void)configureText:(NSString *)text imageName:(nullable NSString *)imageName selectedText:(NSString *)selectedText selectedImageName:(nullable NSString *)selectedImageName
{
    UIImage *image = imageName ? [UIImage imageNamed:imageName] : nil;
    UIImage *selectedImage = selectedImageName ? [UIImage imageNamed:selectedImageName] : nil;
    [self configureText:text image:image selectedText:selectedText selectedImage:selectedImage];
}

- (void)configureText:(NSString *)text image:(nullable UIImage *)image selectedText:(NSString *)selectedText selectedImage:(nullable UIImage *)selectedImage
{
    CGFloat space = kTitleAndIconSpace;
    [self setTitle:text forState:UIControlStateNormal];
    if (image) {
        [self setImage:image forState:UIControlStateNormal];
        self.titleEdgeInsets = UIEdgeInsetsMake(0, space/2.0, 0, 0);
        self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, space/2.0);
    } else {
        [self setImage:nil forState:UIControlStateNormal];
        self.titleEdgeInsets = UIEdgeInsetsZero;
        self.imageEdgeInsets = UIEdgeInsetsZero;
    }
    [self setTitle:selectedText forState:UIControlStateSelected];
    [self setImage:selectedImage forState:UIControlStateSelected];
}

@end

@interface AWESlidingTabbarView ()<UIScrollViewDelegate>

@property (nonatomic, assign) BOOL scrollEnabled;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) NSArray<AWESlidingTabButton *> *buttonArray;
@property (nonatomic, strong) NSArray<UIView *> *btnSeperationLineArray;;
@property (nonatomic, assign) AWESlidingTabButtonStyle buttonStyle;
@property (nonatomic, strong) AWESlidingTabButton *selectedButton;

@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, assign) CGFloat titlePadding;
@property (nonatomic, assign) CGFloat titleMinLength;

@end

@implementation AWESlidingTabbarView
@synthesize slidingViewController = _slidingViewController;
@synthesize selectedIndex = _selectedIndex;

- (instancetype)initWithFrame:(CGRect)frame buttonStyle:(AWESlidingTabButtonStyle)buttonStyle scrollEnabled:(BOOL)scrollEnabled dataArray:(NSArray<NSString *> *)dataArray selectedDataArray:(NSArray<NSString *> *)selectedDataArray
{
    self = [super initWithFrame:frame];
    if (self) {
        _titlePadding = kTitlePadding;
        _titleMinLength = kTitleMinLength;
        if (buttonStyle == AWESlidingTabButtonStyleGeneralSearchSpecific) {
            _titlePadding = 0;
            _titleMinLength = kTitleMinLengthForGeneralSearch;
        }
        _selectedIndex = 0;
        _scrollEnabled = scrollEnabled;
        _buttonStyle = buttonStyle;
        _btnSeperationLineArray = [self seperationLinesWithCount:dataArray.count];
        _buttonArray = [self buttonsWithDataArray:dataArray selectedDataArray:selectedDataArray];
        [self addSubview:self.scrollView];
        [self setupSubviews];
    }
    return self;
}

- (void)resetDataArray:(NSArray<NSString *> *)dataArray selectedDataArray:(NSArray<NSString *> *)selectedDataArray
{
    self.scrollView.frame = self.bounds;
    self.btnSeperationLineArray = [self seperationLinesWithCount:dataArray.count];
    self.buttonArray = [self buttonsWithDataArray:dataArray selectedDataArray:selectedDataArray];
    [self setupSubviews];
}

- (void)configureButtonTextColor:(UIColor *)color selectedTextColor:(UIColor *)selectedColor
{
    for (AWESlidingTabButton *button in self.buttonArray) {
        [button setTitleColor:color forState:UIControlStateNormal];
        [button setTitleColor:selectedColor forState:UIControlStateSelected];
    }
}

- (void)configureButtonTextFont:(UIFont *)font selectedFont:(UIFont *)selectedFont
{
    for (AWESlidingTabButton *button in self.buttonArray) {
        button.normalFont = font;
        button.selectedFont = selectedFont;
        if (button.isSelected) {
            button.titleLabel.font = selectedFont;
        } else {
            button.titleLabel.font = font;
        }
    }
    if (self.buttonStyle == AWESlidingTabButtonStyleIrregularText || self.buttonStyle == AWESlidingTabButtonStyleGeneralSearchSpecific) {
        [self configureWidthWithButtons:self.buttonArray];
    }
}

- (void)configureTitlePadding:(CGFloat)padding
{
    for (AWESlidingTabButton *button in self.buttonArray) {
        button.titlePadding = padding;
    }
    CGRect frame = self.lineView.frame;
    frame.origin.x -= (self.titlePadding - padding);
    frame.size.width = [self tabButtonWidth] - 2 * padding;
    self.lineView.frame = frame;
    self.titlePadding = padding;
    
    if (self.buttonStyle == AWESlidingTabButtonStyleIrregularText || self.buttonStyle == AWESlidingTabButtonStyleIconAndText || self.buttonStyle == AWESlidingTabButtonStyleGeneralSearchSpecific) {
        [self configureWidthWithButtons:self.buttonArray];
    }
}

- (void)configureTitleMinLength:(CGFloat)titleMinLength
{
    _titleMinLength = titleMinLength;
    if (self.buttonStyle == AWESlidingTabButtonStyleIrregularText || self.buttonStyle == AWESlidingTabButtonStyleIconAndText || self.buttonStyle == AWESlidingTabButtonStyleGeneralSearchSpecific) {
        [self configureWidthWithButtons:self.buttonArray];
    }
}

- (void)configureButtonTextFont:(UIFont *)font hasShadow:(BOOL)hasShadow
{
    for (AWESlidingTabButton *button in self.buttonArray) {
        button.titleLabel.font = font;
        if (hasShadow) {
            button.titleLabel.layer.shadowColor = [UIColor redColor].CGColor;
            button.titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
            button.titleLabel.layer.shadowRadius = 2;
            button.titleLabel.layer.shadowOpacity = 1.0f;
        }
    }
    if (self.buttonStyle == AWESlidingTabButtonStyleIrregularText || self.buttonStyle == AWESlidingTabButtonStyleIconAndText || self.buttonStyle == AWESlidingTabButtonStyleGeneralSearchSpecific) {
        [self configureWidthWithButtons:self.buttonArray];
    }
}

- (void)configureText:(NSString *)text image:(nullable UIImage *)image selectedText:(NSString *)selectedText selectedImage:(nullable UIImage *)selectedImage index:(NSInteger)index
{
    if (index >= 0 && index < self.buttonArray.count) {
        AWESlidingTabButton *button = self.buttonArray[index];
        [button configureText:text image:image selectedText:selectedText selectedImage:selectedImage];
    }
    [self setupSubviews];
}

- (void)showButtonDot:(BOOL)show index:(NSInteger)index color:(UIColor *)color
{
    if (index >= 0 && index < self.buttonArray.count) {
        AWESlidingTabButton *button = self.buttonArray[index];
        [button showDot:show color:color];
    }
}

- (BOOL)isButtonDotShownOnIndex:(NSInteger)index
{
    if (index >= 0 && index < self.buttonArray.count) {
        AWESlidingTabButton *button = self.buttonArray[index];
        return [button isDotShown];
    }
    return NO;
}

- (NSArray *)buttonsWithDataArray:(NSArray<NSString *> *)dataArray selectedDataArray:(NSArray<NSString *> *)selectedDataArray
{
    NSMutableArray *buttons = [NSMutableArray array];
    for (NSInteger i = 0; i < dataArray.count; i++) {
        NSString *nameString = dataArray[i];
        NSString *selectedNameString = nil;
        if (i < selectedDataArray.count) {
            selectedNameString = selectedDataArray[i];
        }
        if (!selectedNameString) {
            selectedNameString = nameString;
        }
        AWESlidingTabButton *tabButton = [[AWESlidingTabButton alloc] init];
        tabButton.buttonStyle = self.buttonStyle;
        if (self.buttonStyle == AWESlidingTabButtonStyleText || self.buttonStyle == AWESlidingTabButtonStyleIrregularText || self.buttonStyle == AWESlidingTabButtonStyleIconAndText || self.buttonStyle == AWESlidingTabButtonStyleGeneralSearchSpecific) {
            [tabButton setTitle:nameString forState:UIControlStateNormal];
            [tabButton setTitle:selectedNameString forState:UIControlStateSelected];
        } else {
            [tabButton setImage:[UIImage imageNamed:nameString] forState:UIControlStateNormal];
            [tabButton setImage:[UIImage imageNamed:selectedNameString] forState:UIControlStateSelected];
        }
        [buttons addObject:tabButton];
    }
    if (self.buttonStyle == AWESlidingTabButtonStyleIrregularText || self.buttonStyle == AWESlidingTabButtonStyleIconAndText || self.buttonStyle == AWESlidingTabButtonStyleGeneralSearchSpecific) {
        [self configureWidthWithButtons:buttons];
    }
    return [buttons copy];
}

- (NSArray *)seperationLinesWithCount:(NSInteger)count
{
    NSMutableArray *lineArray = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++) {
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor orangeColor];
        [lineArray addObject:line];
    }
    return [lineArray copy];
}

- (void)setupSubviews
{
    for (UIView *subView in self.scrollView.subviews) {
        [subView removeFromSuperview];
    }
    
    __block CGFloat x = 0;
    if (self.buttonStyle == AWESlidingTabButtonStyleGeneralSearchSpecific) {
        x = 16;
    }
    [self.buttonArray enumerateObjectsUsingBlock:^(AWESlidingTabButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.buttonStyle == AWESlidingTabButtonStyleIrregularText || self.buttonStyle == AWESlidingTabButtonStyleIconAndText || self.buttonStyle == AWESlidingTabButtonStyleGeneralSearchSpecific) {
            button.frame = CGRectMake(x + 0.5, 0, button.buttonWidth - 1, self.bounds.size.height);
        } else {
            button.frame = CGRectMake(idx * [self tabButtonWidth] + 0.5, 0, [self tabButtonWidth] - 1, self.bounds.size.height);
        }
        button.tag = idx + 10001;
        [button addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        if (idx > 0) {
            UIView *line = self.btnSeperationLineArray[idx - 1];
            if (self.buttonStyle == AWESlidingTabButtonStyleIrregularText || self.buttonStyle == AWESlidingTabButtonStyleIconAndText || self.buttonStyle == AWESlidingTabButtonStyleGeneralSearchSpecific) {
                line.frame = CGRectMake(x, (self.scrollView.frame.size.height - 16) * 0.5, 0.5, 16);
            } else {
                line.frame = CGRectMake([self tabButtonWidth] * idx, (self.scrollView.frame.size.height - 16) * 0.5, 0.5, 16);
            }
            line.hidden = !self.shouldShowButtonSeperationLine;
            [self.scrollView addSubview:line];
        }
        x += button.buttonWidth;
    }];
    if (self.buttonStyle == AWESlidingTabButtonStyleGeneralSearchSpecific) {
        x += 16;
    }
    if (self.buttonStyle == AWESlidingTabButtonStyleIrregularText || self.buttonStyle == AWESlidingTabButtonStyleIconAndText || self.buttonStyle == AWESlidingTabButtonStyleGeneralSearchSpecific) {
        self.scrollView.contentSize = CGSizeMake(x, 0);
        if (self.selectedIndex < self.buttonArray.count) {
            AWESlidingTabButton *selectButton = self.buttonArray[self.selectedIndex];
            self.lineView.frame = CGRectMake(selectButton.lineX + selectButton.frame.origin.x, self.bounds.size.height - 2, selectButton.lineWidth, 2);
        }
    } else {
        self.scrollView.contentSize = CGSizeMake(self.buttonArray.count * [self tabButtonWidth], 0);
        self.lineView.frame = CGRectMake(self.titlePadding + self.selectedIndex * [self tabButtonWidth], self.bounds.size.height - 2, [self tabButtonWidth] - 2 * self.titlePadding, 2);
    }
    [self.scrollView addSubview:self.lineView];
    CGFloat lineHeight = 1 / [UIScreen mainScreen].scale;
    self.bottomLineView.frame = CGRectMake(0, self.bounds.size.height - lineHeight, self.bounds.size.width, lineHeight);
    [self addSubview:self.bottomLineView];
    self.topLineView.frame = CGRectMake(0, 0, self.bounds.size.width, lineHeight);
    [self addSubview:self.topLineView];
}

- (void)tabButtonClicked:(AWESlidingTabButton *)sender
{
    NSInteger index = sender.tag - 10001;
    self.slidingViewController.selectedIndex = index;
}

- (void)slidingControllerDidScroll:(UIScrollView *)scrollView
{
    if (self.buttonStyle == AWESlidingTabButtonStyleIrregularText || self.buttonStyle == AWESlidingTabButtonStyleIconAndText || self.buttonStyle == AWESlidingTabButtonStyleGeneralSearchSpecific) {
        [self updateIrregularTextFrameWhenScroll:scrollView];
    } else {
        [self updateFrameWhenScroll:scrollView];
    }
}

- (void)updateFrameWhenScroll:(UIScrollView *)scrollView
{
    CGFloat ratio = scrollView.contentOffset.x / scrollView.contentSize.width;
    CGPoint center = self.lineView.center;
    center.x = ratio * self.scrollView.contentSize.width + [self tabButtonWidth] * 0.5;
    void (^animationBlock)(void) = ^{
        self.lineView.center = center;
        CGFloat leftOffset = self.scrollView.contentOffset.x;
        CGFloat rightOffset = self.scrollView.contentOffset.x + self.scrollView.frame.size.width;
        if (self.scrollEnabled) {
            if (center.x - [self tabButtonWidth] * 0.5 <= leftOffset) {
                [self.scrollView setContentOffset:CGPointMake(center.x - [self tabButtonWidth] * 0.5, 0)];
            } else if (center.x + [self tabButtonWidth] * 0.5 >= rightOffset) {
                [self.scrollView setContentOffset:CGPointMake(center.x + [self tabButtonWidth] * 0.5 - self.scrollView.frame.size.width, 0)];
            }
        }
    };
    if (scrollView.isDragging) {
        animationBlock();
    } else {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView animateWithDuration:0.15 animations:^{
            animationBlock();
        }];
    }
}

- (void)updateIrregularTextFrameWhenScroll:(UIScrollView *)scrollView
{
    NSInteger selectedIndex = scrollView.contentOffset.x / scrollView.bounds.size.width;   //不用self.selectedIndex，快速滑动时值不准确
    NSAssert(selectedIndex < self.buttonArray.count, @"index beyond bounds");
    if (selectedIndex >= self.buttonArray.count) {
        return;
    }
    AWESlidingTabButton *selectButton = self.buttonArray[selectedIndex];
    AWESlidingTabButton *nextButton;
    
    CGFloat ratio = (scrollView.contentOffset.x - selectedIndex * scrollView.bounds.size.width) / scrollView.bounds.size.width;
    CGFloat x;
    if (ratio > 0) {
        NSAssert(selectedIndex + 1 < self.buttonArray.count, @"index beyond bounds");
        if (selectedIndex + 1 >= self.buttonArray.count) {
            return;
        }
        nextButton = self.buttonArray[selectedIndex + 1];
        CGFloat diff = (selectButton.buttonWidth + selectButton.lineWidth + nextButton.buttonWidth - nextButton.lineWidth) / 2;
        x = ratio * diff + selectButton.frame.origin.x + selectButton.lineX;
    } else if (ratio < 0) {
        NSAssert(selectedIndex - 1 < self.buttonArray.count && selectedIndex >= 1, @"index beyond bounds");
        if (selectedIndex - 1 >= self.buttonArray.count || selectedIndex < 1) {
            return;
        }
        nextButton = self.buttonArray[selectedIndex - 1];
        CGFloat diff = (nextButton.buttonWidth + nextButton.lineWidth + selectButton.buttonWidth - selectButton.lineWidth) / 2;
        x = ratio * diff + selectButton.frame.origin.x + selectButton.lineX;
    } else {
        x = selectButton.frame.origin.x + selectButton.lineX;
    }
    
    CGFloat width = fabs(ratio) * (nextButton.lineWidth - selectButton.lineWidth) + selectButton.lineWidth;
    CGRect frame = self.lineView.frame;
    frame.origin.x = x;
    frame.size.width = width;
    
    CGPoint center = CGPointMake(frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height / 2);
    CGFloat scrollCenter = self.scrollView.contentOffset.x + self.scrollView.frame.size.width / 2;
    CGFloat offset = self.scrollView.contentOffset.x + center.x - scrollCenter;
    CGFloat rightOffset = self.scrollView.contentSize.width - self.scrollView.bounds.size.width;
    if (offset < 0) {
        offset = 0;
    } else if (offset > rightOffset) {
        offset = rightOffset;
    }
    
    [UIView animateWithDuration:0.15 animations:^{
        self.lineView.frame = frame;
        if (self.scrollEnabled) {
            [self.scrollView setContentOffset:CGPointMake(offset, 0)];
        }
    }];
}

- (void)configureWidthWithButtons:(NSArray<AWESlidingTabButton *> *)buttons
{
    CGFloat widthTotal = 0;
    CGFloat widthMax = 0;
    for (NSInteger i = 0; i < buttons.count; i++) {
        AWESlidingTabButton *button = buttons[i];
        CGSize normalTitleSize = [[button titleForState:UIControlStateNormal] sizeWithAttributes:@{NSFontAttributeName : button.normalFont}];
        CGSize selectedTitleSize = [[button titleForState:UIControlStateSelected] sizeWithAttributes:@{NSFontAttributeName : button.selectedFont}];
        if (self.buttonStyle == AWESlidingTabButtonStyleIconAndText) {
            CGSize imageSize = [[button imageForState:UIControlStateNormal] size];
            if (imageSize.width > 0) {
                normalTitleSize = CGSizeMake(normalTitleSize.width + imageSize.width + kTitleAndIconSpace, normalTitleSize.height);
            }
            CGSize selectedImageSize = [[button imageForState:UIControlStateSelected] size];
            if (selectedImageSize.width > 0) {
                selectedImageSize = CGSizeMake(selectedTitleSize.width + selectedImageSize.width + kTitleAndIconSpace, selectedTitleSize.height);
            }
        }
        CGFloat biggerWidth = selectedTitleSize.width > normalTitleSize.width ? selectedTitleSize.width : normalTitleSize.width;
        if (self.buttonStyle == AWESlidingTabButtonStyleGeneralSearchSpecific) {
            biggerWidth += 24;
        }
        button.lineWidth = biggerWidth > self.titleMinLength ? biggerWidth : self.titleMinLength;
        button.buttonWidth = button.lineWidth + 2 * self.titlePadding;
        button.lineX = (button.buttonWidth - button.lineWidth) / 2;
        widthTotal += button.buttonWidth;
        if (button.buttonWidth > widthMax) {
            widthMax = button.buttonWidth;
        }
    }
    CGFloat x = 0;
    CGFloat offset = self.shouldShowButtonSeperationLine ? 0.5 : 0;
    if (widthMax * buttons.count <= self.bounds.size.width) {
        for (AWESlidingTabButton *button in buttons) {
            button.buttonWidth = self.bounds.size.width / buttons.count;
            button.lineX = (button.buttonWidth - button.lineWidth) / 2;
            button.frame = CGRectMake(x + offset, 0, button.buttonWidth - offset * 2, self.bounds.size.height);
            x += CGRectGetMaxX(button.frame);
        }
    } else if (widthTotal < self.bounds.size.width) {
        CGFloat extraSpace = (self.bounds.size.width - widthTotal) / buttons.count;
        for (AWESlidingTabButton *button in buttons) {
            button.buttonWidth += extraSpace;
            button.lineX = (button.buttonWidth - button.lineWidth) / 2;
            button.frame = CGRectMake(x + offset, 0, button.buttonWidth - offset * 2, self.bounds.size.height);
            x += CGRectGetMaxX(button.frame);
        }
    }
}

#pragma mark - Getters

- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor redColor];
    }
    return _lineView;
}

- (UIView *)topLineView
{
    if (!_topLineView) {
        _topLineView = [[UIView alloc] init];
        _topLineView.hidden = NO;
        _topLineView.backgroundColor = [UIColor redColor];
    }
    return _topLineView;
}

- (UIView *)bottomLineView
{
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] init];
        _bottomLineView.backgroundColor = [UIColor redColor];
    }
    return _bottomLineView;
}

- (CGFloat)tabButtonWidth
{
    NSInteger count = self.buttonArray.count;
    if (count == 0) {
        return 0.f;
    }
    CGFloat width = self.bounds.size.width / count;
    if (self.scrollEnabled) {  // 允许滚动，button宽度限制
        CGFloat maxWidth = (self.buttonStyle == AWESlidingTabButtonStyleIcon ? 80 : 94);
        return (width < maxWidth ? maxWidth : width);
    } else {
        return width;
    }
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.scrollEnabled = self.scrollEnabled;
        _scrollView.delegate = self;
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
    }
    return _scrollView;
}

#pragma mark - Setters

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (!self.buttonArray || self.buttonArray.count == 0) {
        return;
    }
    
    if (selectedIndex < 0 || selectedIndex >= self.buttonArray.count) {
        return;
    }
    
    [self.buttonArray enumerateObjectsUsingBlock:^(AWESlidingTabButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        [button setSelected:(idx == selectedIndex)];
    }];
    
    _selectedIndex = selectedIndex;
}

- (void)setShouldShowTopLine:(BOOL)shouldShowTopLine
{
    _shouldShowTopLine = shouldShowTopLine;
    self.topLineView.hidden = !shouldShowTopLine;
}

- (void)setShouldShowBottomLine:(BOOL)shouldShowBottomLine
{
    _shouldShowBottomLine = shouldShowBottomLine;
    self.bottomLineView.hidden = !shouldShowBottomLine;
}

- (void)setShouldShowSelectionLine:(BOOL)shouldShowSelectionLine
{
    _shouldShowSelectionLine = shouldShowSelectionLine;
    self.lineView.hidden = !shouldShowSelectionLine;
}

- (void)setSelectionLineColor:(UIColor *)selectionLineColor
{
    self.lineView.backgroundColor = selectionLineColor;
}

- (void)setTopBottomLineColor:(UIColor *)topBottomLineColor
{
    _topBottomLineColor = topBottomLineColor;
    self.topLineView.backgroundColor = topBottomLineColor;
    self.bottomLineView.backgroundColor = topBottomLineColor;
}

- (void)setShouldShowButtonSeperationLine:(BOOL)shouldShowButtonSeperationLine
{
    _shouldShowButtonSeperationLine = shouldShowButtonSeperationLine;
    for (UIView *line in self.btnSeperationLineArray) {
        line.hidden = !shouldShowButtonSeperationLine;
    }
}

@end
