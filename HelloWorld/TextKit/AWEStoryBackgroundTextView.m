//
//  AWEStoryBackgroundTextView.m
//  AWEStudio
//
//  Created by hanxu on 2018/11/20.
//  Copyright © 2018 bytedance. All rights reserved.
//

#import "AWEStoryBackgroundTextView.h"
#import <AWEFoundationKit/AWEFoundation.h>
#import "UIFont+AWEAdditions.h"
#import <AWEUIColor.h>
#import "AWEStoryFontManager.h"
#import "AWEStoryTextImageModel.h"
#import "UIImage+Studio.h"

#import "UIFont+AWEStudio.h"
#import "UIView+AWESubtractMask.h"
#import "AWEBundle.h"
#import <ByteDanceKit/NSString+BTDAdditions.h>
#import <ByteDanceKit/BTDMacros.h>
#import <AWERTL/UIView+AWERTL.h>
#import <AWERTL/UITextView+AWERTL.h>
#import <AWERTL/AWERTLManager.h>

CGFloat kAWEStoryBackgroundTextViewLeftMargin = 32;//整个距离屏幕左边
CGFloat kAWEStoryBackgroundTextViewBackgroundColorLeftMargin = 12;
CGFloat kAWEStoryBackgroundTextViewBackgroundColorTopMargin = 6;
CGFloat kAWEStoryBackgroundTextViewBackgroundBorderMargin = 6;
CGFloat kAWEStoryBackgroundTextViewBackgroundRadius = 6;
CGFloat kAWEStoryBackgroundTextViewKeyboardMargin = 122;
CGFloat kAWEStoryBackgroundTextViewContainerInset = 20;

@interface AWEStoryBackgroundTextView () <UIGestureRecognizerDelegate>

//操作框
@property (nonatomic, assign) CGAffineTransform lastHandleButtonTransform;
@property (nonatomic, assign) CGAffineTransform lastSelectTimeButtonTransform;
@property (nonatomic, assign) CGAffineTransform lastDeleteButtonTransform;
@property (nonatomic, assign) CGAffineTransform lastEditButtonTransform;
@property (nonatomic, assign) CGFloat lastBorderViewBorderWidth;

//
@property (nonatomic, strong) NSMutableArray *layerPool;
@property (nonatomic, strong) NSMutableArray<CALayer *> *currentShowLayerArray;
@property (nonatomic, strong) UIColor *fillColor;
//在编辑页的状态
@property (nonatomic, assign) CGAffineTransform lastTransForm;
@property (nonatomic, assign) CGPoint lastAnchorPoint;
@property (nonatomic, assign) CGAffineTransform lastBorderViewTransform;

@property (nonatomic, assign, readwrite) BOOL enableEdit;
@property (nonatomic, assign, readwrite) BOOL lastHandleState;
@property (nonatomic, strong, readwrite) UIView *borderView;
@property (nonatomic, strong, readwrite) CAShapeLayer *borderShapeLayer;

//写文字时的center
@property (nonatomic, assign, readwrite) CGPoint editCenter;

@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) BOOL hasFeedback;
@property (nonatomic, assign) BOOL notRefresh;
@property (nonatomic, assign) BOOL isForImage;

@end


@implementation AWEStoryBackgroundTextView


- (void)dealloc
{
    BTDLog(@"%@ dealloc",self.class);
}

- (instancetype)initWithIsForImage:(BOOL)isForImage
{
    self = [super init];
    if (self) {
        self.isForImage = isForImage;
        self.stickerEditId = -1;
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithTextInfo:(AWEStoryTextImageModel *)model isForImage:(BOOL)isForImage
{
    self = [super init];
    if (self) {
        self.notRefresh = YES;
        self.stickerEditId = -1;
        self.isForImage = isForImage;
        
        if (model.isPOISticker) {
            self.isInteractionSticker = YES;
            self.interactionStickerInfo.type = AWEInteractionStickerTypePOI;
            self.stickerLocation.pts = [NSDecimalNumber decimalNumberWithString:@"-1"];
            self.poiName = model.content;
        } else {
            self.textView.text = model.content;
        }
        
        self.selectFont = model.fontModel;
        self.color = model.fontColor;
        self.alignmentType = model.alignmentType;
        self.style = model.textStyle;
        self.keyboardHeight = model.keyboardHeight;
        self.realStartTime = model.realStartTime;
        self.realDuration = model.realDuration;
        self.finalStartTime = model.realStartTime;
        self.finalDuration = model.realDuration;
        self.notRefresh = NO;
        self.textInfoModel = model;
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.currentScale = 1;
    self.isFirstAppear = YES;
    self.lastAnchorPoint = CGPointMake(0.5, 0.5);
    self.lastTransForm = CGAffineTransformIdentity;
    self.textStickerId = [NSString stringWithFormat:@"%@", @([[NSDate date] timeIntervalSince1970])];
    
    if (!self.borderView.superview) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self addGestureRecognizer:panGesture];
        
        [self addSubview:self.borderView];
        [self hideHandle];
        
        [self addSubview:self.textView];
        [self.borderView.layer addSublayer:self.borderShapeLayer];
        [self.borderView addSubview:self.deleteButton];
        [self.borderView addSubview:self.selectTimeButton];
        [self.borderView addSubview:self.handleButton];
        [self.borderView addSubview:self.editButton];
    }
    
    if (self.isInteractionSticker) {
        [self insertSubview:self.darkBGView belowSubview:self.textView];
        self.textView.editable = NO;
        self.enableEdit = NO;
        self.selectTimeButton.hidden = YES;
    }
    
    if (self.isForImage) {
        self.selectTimeButton.hidden = YES;
    }
    
    self.color = self.color ?: [AWEStoryColor colorWithHexString:@"0xffffff"];
    
    [self refreshFont];
}

- (void)p_updateFrame
{
    CGSize textViewSize;
    if (self.isInteractionSticker) {
        textViewSize = CGSizeMake([self poiContainerWidth], [self poiContainerHeight]);
        self.textView.backgroundColor = [UIColor whiteColor];
        self.textView.layer.cornerRadius = 6.f;
        self.textView.layer.masksToBounds = YES;
        
        self.darkBGView.layer.cornerRadius = 6.f;
        self.darkBGView.layer.masksToBounds = YES;
    } else {
        self.textView.backgroundColor = [UIColor clearColor];
        textViewSize = [self.textView sizeThatFits:CGSizeMake(SCREEN_WIDTH - 2 * kAWEStoryBackgroundTextViewLeftMargin + 2 * kAWEStoryBackgroundTextViewContainerInset, HUGE)];
    }
    
    if (textViewSize.width <= 0.0001) {
        textViewSize.width = 20;
    } else if (self.isInteractionSticker && textViewSize.width > (SCREEN_WIDTH - 32)) {
        textViewSize.width = SCREEN_WIDTH - 32;
    }
    
    CGFloat selfWidth = textViewSize.width + (kAWEStoryBackgroundTextViewBackgroundColorLeftMargin + kAWEStoryBackgroundTextViewBackgroundBorderMargin) * 2 - 2 * kAWEStoryBackgroundTextViewContainerInset;
    CGFloat selfHeight = textViewSize.height + (kAWEStoryBackgroundTextViewBackgroundColorTopMargin + kAWEStoryBackgroundTextViewBackgroundBorderMargin) * 2 - 2 * kAWEStoryBackgroundTextViewContainerInset;
    if (self.isInteractionSticker) {
        selfWidth = textViewSize.width + (kAWEStoryBackgroundTextViewBackgroundColorLeftMargin + kAWEStoryBackgroundTextViewBackgroundBorderMargin) * 2;
        selfHeight = textViewSize.height + (kAWEStoryBackgroundTextViewBackgroundColorTopMargin + kAWEStoryBackgroundTextViewBackgroundBorderMargin) * 2;
    }
    self.frame = CGRectMake(0, 0, selfWidth, selfHeight);
    
    CGFloat del = self.basicCenter.y + textViewSize.height * 0.5 - (SCREEN_HEIGHT - self.keyboardHeight - (kAWEStoryBackgroundTextViewKeyboardMargin + kAWEStoryBackgroundTextViewBackgroundBorderMargin + kAWEStoryBackgroundTextViewBackgroundColorTopMargin));
    if (del > 0) {
        self.center = CGPointMake(self.basicCenter.x, self.basicCenter.y - AWEStoryTextContainerViewTopMaskMargin - del);
    } else {
        self.center = CGPointMake(self.basicCenter.x, self.basicCenter.y - AWEStoryTextContainerViewTopMaskMargin);
    }
    
    if (self.alignmentType == AWEStoryTextAlignmentLeft) {
        self.awe_left = kAWEStoryBackgroundTextViewLeftMargin - kAWEStoryBackgroundTextViewContainerInset + self.leftBeyond;
    } else if (self.alignmentType == AWEStoryTextAlignmentRight) {
        self.awe_right = SCREEN_WIDTH - kAWEStoryBackgroundTextViewLeftMargin + kAWEStoryBackgroundTextViewContainerInset + self.leftBeyond;
    }
    
    self.editCenter = self.center;
    self.borderView.frame = self.bounds;
    self.borderShapeLayer.frame = self.borderView.bounds;
    
    self.textView.frame = CGRectMake(kAWEStoryBackgroundTextViewBackgroundColorLeftMargin + kAWEStoryBackgroundTextViewBackgroundBorderMargin - kAWEStoryBackgroundTextViewContainerInset, kAWEStoryBackgroundTextViewBackgroundColorTopMargin + kAWEStoryBackgroundTextViewBackgroundBorderMargin - kAWEStoryBackgroundTextViewContainerInset, textViewSize.width, textViewSize.height);
    if (self.isInteractionSticker) {
        self.textView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        [self.textView awe_setSubtractMaskView:[self poiLblWithAlpha:0.8f]];
        self.darkBGView.frame = CGRectMake(self.textView.frame.origin.x+2, self.textView.frame.origin.y+2, self.textView.frame.size.width-4, self.textView.frame.size.height-4);
        self.darkBGView.center = self.textView.center;
    }
    
    CGFloat buttonWidth = 44;
    self.deleteButton.frame = CGRectMake(0, 0, buttonWidth, buttonWidth);
    self.deleteButton.center = CGPointMake(0, 0);
    self.selectTimeButton.frame = CGRectMake(0, 0, buttonWidth, buttonWidth);
    self.selectTimeButton.center = CGPointMake(self.bounds.size.width, 0);
    self.handleButton.frame = CGRectMake(0, 0, buttonWidth, buttonWidth);
    self.handleButton.center = CGPointMake(self.bounds.size.width, self.bounds.size.height);
    self.editButton.frame = CGRectMake(0, 0, buttonWidth, buttonWidth);
    self.editButton.center = CGPointMake(0, self.bounds.size.height);
}

#pragma mark -

//进入编辑状态
- (void)resetWithSuperView:(UIView *)superView
{
    //是否允许编辑状态下拖动
    self.enableEdit = YES;
    
    self.lastTransForm = self.transform;
    if (self.isFirstAppear) {
        self.isFirstAppear = NO;
    } else {
        self.lastCenter = self.center;
    }
    
    self.lastAnchorPoint = self.layer.anchorPoint;
    
    self.lastBorderViewTransform = self.borderView.transform;
    self.lastBorderViewBorderWidth = self.borderShapeLayer.borderWidth;
    self.lastHandleButtonTransform = self.handleButton.transform;
    self.lastDeleteButtonTransform = self.deleteButton.transform;
    self.lastSelectTimeButtonTransform = self.selectTimeButton.transform;
    self.lastEditButtonTransform = self.editButton.transform;
    
    //把textView从全屏的containerview上移动到有上边距的topmaskview上
    if (self.superview) {
        CGPoint centerInContainer = self.center;
        CGPoint centerInMaskTop = [superView convertPoint:centerInContainer fromView:self.superview];
        [self removeFromSuperview];
        [superView addSubview:self];
        self.center = centerInMaskTop;
    } else {
        [superView addSubview:self];
        [self p_updateFrame];
    }
    
    [self.textView becomeFirstResponder];
    [UIView animateWithDuration:0.35 animations:^{
        self.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.transform = CGAffineTransformIdentity;
        self.center = self.editCenter;
        self.handleButton.transform = CGAffineTransformIdentity;
        self.deleteButton.transform = CGAffineTransformIdentity;
        self.selectTimeButton.transform = CGAffineTransformIdentity;
        self.editButton.transform = CGAffineTransformIdentity;
        self.borderView.transform = CGAffineTransformIdentity;
        self.borderShapeLayer.borderWidth = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)transToRecordPosWithSuperView:(UIView *)superView
                    animationDuration:(CGFloat)duration
                           completion:(void (^)(void))completion
{
    self.enableEdit = NO;
    //把textView从有上边距的topmaskview上移动到全屏的containerview上
    if (self.superview) {
        CGPoint centerInMaskTop = self.center;
        CGPoint centerInContainer = [superView convertPoint:centerInMaskTop fromView:self.superview];
        self.superview.hidden = YES;
        [self removeFromSuperview];
        
        [superView addSubview:self];
        self.center = centerInContainer;
    } else {
        [superView addSubview:self];
    }
    
    [self handleContentScaleFactor];
    [UIView animateWithDuration:duration animations:^{
        self.layer.anchorPoint = self.lastAnchorPoint;
        self.center = self.lastCenter;
        self.handleButton.transform = self.lastHandleButtonTransform;
        self.deleteButton.transform = self.lastDeleteButtonTransform;
        self.selectTimeButton.transform = self.lastSelectTimeButtonTransform;
        self.editButton.transform = self.lastDeleteButtonTransform;
        self.borderView.transform = self.lastBorderViewTransform;
        self.borderShapeLayer.borderWidth = self.lastBorderViewBorderWidth;
        self.transform = self.lastTransForm;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

//恢复到拖动状态
- (void)transToRecordPosWithSuperView:(UIView *)superView
                           completion:(void (^)(void))completion
{
    [self transToRecordPosWithSuperView:superView animationDuration:0.3 completion:completion];
}


- (void)initPosWithSuperView:(UIView *)superView
{
    [self p_updateFrame];
    
    if (self.isInteractionSticker) { //需求定义只存在1个POI贴纸
        AWEStoryBackgroundTextView *poiSticker = [self poiStickerInContainer:superView];
        if (poiSticker) {
            [poiSticker removeFromSuperview];
        }
    }
    
    if (self.superview) {
        CGPoint centerInMaskTop = self.center;
        CGPoint centerInContainer = [superView convertPoint:centerInMaskTop fromView:self.superview];
        self.superview.hidden = YES;
        [self removeFromSuperview];
        [superView addSubview:self];
        self.center = centerInContainer;
    } else {
        [superView addSubview:self];
    }
    
    [self handleContentScaleFactor];

    self.layer.anchorPoint = self.lastAnchorPoint;
    self.center = self.lastCenter;
    self.transform = self.lastTransForm;
}

- (void)p_showHandle:(BOOL)show
{
    self.lastHandleState = self.selected;
    self.borderView.hidden = !show;
    self.selected = show;
}

- (void)hideHandle
{
    if (self.gestureManager.isGestureBegin && self.borderView.hidden) {
        return;
    }
    [self p_showHandle:NO];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)autoDismissHandle
{
    [self hideHandle];
    if (self.autoDismissHandleBlock) {
        self.autoDismissHandleBlock(self);
    }
}

- (void)showHandleThenDismiss
{
    if (self.isSelectTimeMode) {
        return;
    }
    [self p_showHandle:YES];
    [self performSelector:@selector(autoDismissHandle) withObject:nil afterDelay:3];
}

#pragma mark - gesture action

//平移手势的回调方法
- (void)panAction:(UIPanGestureRecognizer *)sender
{
    if (self.enableEdit) {
        CGPoint currentPoint = [sender translationInView:self.superview];
        
        if ((self.frame.origin.y + currentPoint.y >= 0) || self.center.y + currentPoint.y < self.editCenter.y) {
            self.center = CGPointMake(self.center.x, self.center.y);
        } else {
            self.center = CGPointMake(self.center.x, self.center.y + currentPoint.y);
        }
        
        [sender setTranslation:CGPointZero inView:self.superview];
        return;
    }
}

- (void)handleContentScaleFactor
{
    CGFloat contentScaleFactor = self.currentScale * [UIScreen mainScreen].scale;
    if (contentScaleFactor <= 2.0) {
        contentScaleFactor = 2.0;
    } else if (contentScaleFactor >= 20.0) {
        contentScaleFactor = 20.0;
    }
    
    for (UIView *view in self.textView.subviews) {
        view.contentScaleFactor = contentScaleFactor;
    }
    
    self.contentScaleFactor = contentScaleFactor;
}

- (void)setCanOperate:(BOOL)canOperate
{
    self.userInteractionEnabled = canOperate;
}

#pragma mark - action

//拖拽操作杆
- (void)handlePanGesture:(UIPanGestureRecognizer *)ges
{
    if ([self.delegate respondsToSelector:@selector(editorSticker:dragHandleBarButton:dragGesture:)]) {
        [self.delegate editorSticker:self dragHandleBarButton:self.handleButton dragGesture:ges];
    }
}

- (void)clickDeleteButton:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(editorSticker:clickedDeleteButton:)]) {
        [self.delegate editorSticker:self clickedDeleteButton:button];
    }
}

- (void)clickSelectTimeButton:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(editorSticker:clickedSelectTimeButton:)]) {
        [self.delegate editorSticker:self clickedSelectTimeButton:button];
    }
}

- (void)clickEditButton:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(editorSticker:clickedTextEditButton:)]) {
        [self.delegate editorSticker:self clickedTextEditButton:button];
    }
    [self hideHandle];
}

#pragma mark - getter

- (AWEInteractionStickerLocationModel *)stickerLocation
{
    if (!_stickerLocation) {
        _stickerLocation = [[AWEInteractionStickerLocationModel alloc]init];
    }
    return _stickerLocation;
}

- (AWEInteractionStickerModel *)interactionStickerInfo
{
    if (!_interactionStickerInfo) {
        _interactionStickerInfo = [[AWEInteractionStickerModel alloc] init];
    }
    return _interactionStickerInfo;
}

- (UIView *)borderView
{
    if (!_borderView) {
        _borderView = [[UIView alloc] init];
    }
    return _borderView;
}

- (CAShapeLayer *)borderShapeLayer
{
    if (!_borderShapeLayer) {
        _borderShapeLayer = [CAShapeLayer layer];
        _borderShapeLayer.borderWidth = 1;
        _borderShapeLayer.borderColor = [UIColorFromRGBA(0xffffff, 1) CGColor];
    }
    return _borderShapeLayer;
}

- (UIButton *)deleteButton
{
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage awe_studioImageNamed:@"icCameraStickerClose"] forState:UIControlStateNormal];
        [_deleteButton setImage:[UIImage awe_studioImageNamed:@"icCameraStickerClose"] forState:UIControlStateHighlighted];
        _deleteButton.backgroundColor = [UIColor clearColor];
        [_deleteButton addTarget:self action:@selector(clickDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (UIButton *)selectTimeButton
{
    if (!_selectTimeButton) {
        _selectTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectTimeButton setImage:[UIImage awe_studioImageNamed:@"icCameraStickerTime"] forState:UIControlStateNormal];
        [_selectTimeButton setImage:[UIImage awe_studioImageNamed:@"icCameraStickerTime"] forState:UIControlStateHighlighted];
        _selectTimeButton.backgroundColor = [UIColor clearColor];
        [_selectTimeButton addTarget:self action:@selector(clickSelectTimeButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectTimeButton;
}

- (UIButton *)handleButton
{
    if (!_handleButton) {
        _handleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_handleButton setImage:[UIImage awe_studioImageNamed:@"icCameraStickerEnlarge"] forState:UIControlStateNormal];
        [_handleButton setImage:[UIImage awe_studioImageNamed:@"icCameraStickerEnlarge"] forState:UIControlStateHighlighted];
        _handleButton.backgroundColor = [UIColor clearColor];
    }
    return _handleButton;
}

- (UIButton *)editButton
{
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setImage:[UIImage awe_studioImageNamed:@"icCameraStickerEdit"] forState:UIControlStateNormal];
        [_editButton setImage:[UIImage awe_studioImageNamed:@"icCameraStickerEdit"] forState:UIControlStateHighlighted];
        _editButton.backgroundColor = [UIColor clearColor];
        [_editButton addTarget:self action:@selector(clickEditButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

- (UITextView *)textView
{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.autocorrectionType = UITextAutocorrectionTypeNo;
        _textView.tintColor = [AWEUIColor colorWithName:AWEUIColorLink2];
        _textView.delegate = self;
        _textView.font = [UIFont awe_systemFontOfSize:28 weight:AWEFontWeightHeavy];
        _textView.textColor = [UIColor blackColor];
        _textView.scrollEnabled = NO;
        _textView.showsVerticalScrollIndicator = NO;
        _textView.showsHorizontalScrollIndicator = NO;
        _textView.textAlignment = NSTextAlignmentCenter;
        _textView.textContainerInset = UIEdgeInsetsMake(kAWEStoryBackgroundTextViewContainerInset, kAWEStoryBackgroundTextViewContainerInset, kAWEStoryBackgroundTextViewContainerInset, kAWEStoryBackgroundTextViewContainerInset);
        _textView.textContainer.lineFragmentPadding = 0;
        _textView.backgroundColor = [UIColor clearColor];
    }
    return _textView;
}

- (UIView *)darkBGView
{
    if (!_darkBGView) {
        _darkBGView = [UIView new];
        _darkBGView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
    }
    return _darkBGView;
}

- (NSMutableArray *)currentShowLayerArray
{
    if (!_currentShowLayerArray) {
        _currentShowLayerArray = [@[] mutableCopy];
    }
    return _currentShowLayerArray;
}

- (NSMutableArray *)layerPool
{
    if (!_layerPool) {
        _layerPool = [NSMutableArray array];
        [_layerPool addObject:[CAShapeLayer layer]];
    }
    return _layerPool;
}

- (AWEStoryTextImageModel *)textInfoModel
{
    if (!_textInfoModel) {
        _textInfoModel = [AWEStoryTextImageModel new];
        _textInfoModel.colorIndex = [NSIndexPath indexPathForRow:0 inSection:0];
        _textInfoModel.fontIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    }

    _textInfoModel.realStartTime = self.realStartTime;
    _textInfoModel.realDuration = self.realDuration;
    
    return _textInfoModel;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    AWEBLOCK_INVOKE(self.textChangedBlock, textView.text);
    self.textInfoModel.content = self.textView.text;
    [self refreshFont];
}

#pragma mark - help

- (void)setColor:(AWEStoryColor *)color
{
    _color = color;
    self.textInfoModel.fontColor = color;
    
    [self refreshFont];
}

- (void)setStyle:(AWEStoryTextStyle)style
{
    _style = style;
    self.textInfoModel.textStyle = style;
    
    [self setColor:self.color];
}

- (void)setAlignmentType:(AWEStoryTextAlignmentStyle)alignmentType
{
    _alignmentType = alignmentType;
    self.textInfoModel.alignmentType = alignmentType;
    
    if (alignmentType == AWEStoryTextAlignmentLeft) {
        _textView.textAlignment = NSTextAlignmentLeft;
    } else if (alignmentType == AWEStoryTextAlignmentRight) {
        _textView.textAlignment = NSTextAlignmentRight;
    } else {
        _textView.textAlignment = NSTextAlignmentCenter;
    }
    
    [self refreshFont];
}

- (void)setSelectFont:(AWEStoryFontModel *)selectFont
{
    _selectFont = selectFont;
    self.textInfoModel.fontModel = selectFont;
    
    UIFont *defaultFont = [UIFont awe_systemFontOfSize:28 weight:AWEFontWeightHeavy];
    if (!selectFont) {
        _textView.font = defaultFont;
        return;
    } else {
        _textView.font = [[AWEStoryFontManager sharedInstance] fontWithModel:selectFont size:28];
    }
    
    [self refreshFont];
}

- (void)resetTextViewAlignment
{
    if (self.alignmentType == AWEStoryTextAlignmentLeft) {
        _textView.textAlignment = NSTextAlignmentLeft;
    } else if (self.alignmentType == AWEStoryTextAlignmentRight) {
        _textView.textAlignment = NSTextAlignmentRight;
    } else {
        _textView.textAlignment = NSTextAlignmentCenter;
    }
}

#pragma mark - 刷新文字贴纸显示样式

- (void)doAfterChange
{
    [self p_updateFrame];
    
    if (!self.isInteractionSticker) {
        [self drawBackgroundWithFillColor:self.fillColor];
    }
}

- (void)refreshFont
{
    if (self.notRefresh) {
        return;
    }
    
    if (!self.isInteractionSticker) {
        if (self.selectFont.hasShadeColor) {
            NSShadow *shadow = [[NSShadow alloc] init];
            shadow.shadowBlurRadius = 10;
            shadow.shadowColor = self.color.color;
            shadow.shadowOffset = CGSizeMake(0, 0);
            
            NSDictionary *params = @{NSShadowAttributeName : shadow,
                                     NSForegroundColorAttributeName : [UIColor whiteColor],
                                     NSFontAttributeName : self.textView.font,
                                     NSBaselineOffsetAttributeName: @(-1.5f),
                                     };
            [self.textView.textStorage setAttributes:params range:NSMakeRange(0, self.textView.text.length)];
            self.fillColor = [UIColor clearColor];
        } else {
            if (self.style == AWEStoryTextStyleNo) {
                self.textView.textColor = _color.color;
                self.fillColor = [UIColor clearColor];
                
            } else {
                if (CGColorEqualToColor(_color.color.CGColor, [UIColorFromRGB(0xffffff) CGColor])) {
                    if (self.style == AWEStoryTextStyleBackground) {
                        self.textView.textColor = [UIColor blackColor];
                    } else {
                        self.textView.textColor = [UIColor whiteColor];
                    }
                } else {
                    self.textView.textColor = [UIColor whiteColor];
                }
                
                if (self.style == AWEStoryTextStyleBackground) {
                    self.fillColor = _color.color;
                    
                } else {
                    self.fillColor = [_color.color colorWithAlphaComponent:0.5];
                }
            }
 
            NSDictionary *params = @{
                                     NSForegroundColorAttributeName : self.textView.textColor ?: [UIColor whiteColor],
                                     NSFontAttributeName : self.textView.font,
                                     NSBaselineOffsetAttributeName: @(-1.5f),
                                     };
            [self.textView.textStorage setAttributes:params range:NSMakeRange(0, self.textView.text.length)];
        }
        
        // 防止有selectRange的情况下，切换字体，textAlignment自动切换成居左，导致背景计算异常的问题
        [self resetTextViewAlignment];
    }
    
    [self doAfterChange];
}

- (void)drawBackgroundWithFillColor:(UIColor *)fillColor
{
    NSMutableArray *lineRangeArray = [@[] mutableCopy];
    NSMutableArray<NSValue *> *lineRectArray = [@[] mutableCopy];
    
    NSRange range = NSMakeRange(0, 0);
    CGRect lineRect = [self.textView.layoutManager lineFragmentUsedRectForGlyphAtIndex:0 effectiveRange:&range];
    
    if (range.length != 0) {
        [lineRangeArray addObject:[NSValue valueWithRange:range]];
        [lineRectArray addObject:[NSValue valueWithCGRect:lineRect]];
    }
    while (range.location + range.length < self.textView.text.length) {
        lineRect = [self.textView.layoutManager lineFragmentUsedRectForGlyphAtIndex:(range.location + range.length) effectiveRange:&range];
        if (range.length != 0) {
            [lineRangeArray addObject:[NSValue valueWithRange:range]];
            [lineRectArray addObject:[NSValue valueWithCGRect:lineRect]];
        }
    }

    NSMutableArray<NSMutableArray *> *segArray = [@[] mutableCopy];
    NSMutableArray *currentArray = [@[] mutableCopy];
    [segArray addObject:currentArray];
    int i = 0;
    while (i < lineRectArray.count) {
        if (lineRectArray[i].CGRectValue.size.width <= 0.00001) {
            if (currentArray.count != 0) {
                currentArray = [@[] mutableCopy];
                [segArray addObject:currentArray];
            }
        } else {
            [currentArray addObject:lineRectArray[i]];
        }
        i++;
    }
    
    for (CAShapeLayer *layer in self.currentShowLayerArray) {
        [layer removeFromSuperlayer];
        [self.layerPool addObject:layer];
    }
    
    [self.currentShowLayerArray removeAllObjects];
    
    for (NSArray *lineRectArray in segArray) {
        if (lineRectArray.count) {
            [self drawWithLineRectArray:lineRectArray fillColor:fillColor];
        }
    }
}

- (void)drawWithLineRectArray:(NSArray<NSValue *> *)array fillColor:(UIColor *)fillColor
{
    NSMutableArray<NSValue *> *lineRectArray = [array mutableCopy];
    
    CAShapeLayer *leftLayer = nil;
    
    if (self.layerPool.count) {
        leftLayer = self.layerPool.lastObject;
        [self.layerPool removeLastObject];
    } else {
        leftLayer = [CAShapeLayer layer];
    }
    
    leftLayer.fillColor = fillColor.CGColor;
    [self.layer insertSublayer:leftLayer atIndex:0];
    
    [self.currentShowLayerArray addObject:leftLayer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (lineRectArray.count == 1) {
        CGRect currentLineRect = lineRectArray[0].CGRectValue;
        CGPoint topMidPoint = [self topMidPointWithRect:currentLineRect];
        [path moveToPoint:topMidPoint];
        
        CGPoint leftTop = [self leftTopWithRect_up:currentLineRect];
        CGPoint leftTopCenter = CGPointMake(leftTop.x + kAWEStoryBackgroundTextViewBackgroundRadius , leftTop.y + kAWEStoryBackgroundTextViewBackgroundRadius);
        [path addLineToPoint:CGPointMake(leftTopCenter.x, leftTop.y)];
        [path addArcWithCenter:leftTopCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:M_PI * 1.5 endAngle:M_PI clockwise:NO];
        
        
        CGPoint leftBottomPoint = [self leftBottomWithRect_down:currentLineRect];
        CGPoint leftBottomCenter = CGPointMake(leftBottomPoint.x + kAWEStoryBackgroundTextViewBackgroundRadius, leftBottomPoint.y - kAWEStoryBackgroundTextViewBackgroundRadius);
        [path addLineToPoint:CGPointMake(leftBottomPoint.x, leftBottomCenter.y)];
        [path addArcWithCenter:leftBottomCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:M_PI endAngle:M_PI * 0.5 clockwise:NO];
        
        CGPoint bottomMid = [self bottomMidPointWithRect:currentLineRect];
        [path addLineToPoint:bottomMid];
    } else if (lineRectArray.count > 1) {
        int i = 0;
        while (i < lineRectArray.count - 1) {
            CGRect currentLineRect = lineRectArray[i].CGRectValue;
            CGRect nextLineRect = lineRectArray[i + 1].CGRectValue;
            if (fabs(currentLineRect.size.width - nextLineRect.size.width) <= (4 * kAWEStoryBackgroundTextViewBackgroundRadius + 1)) {
                //如果两行之差小于2 * kAWEStoryBackgroundTextViewBackgroundRadius
                if (currentLineRect.size.width > nextLineRect.size.width) {
                    lineRectArray[i] = @(CGRectMake(currentLineRect.origin.x, currentLineRect.origin.y, currentLineRect.size.width, currentLineRect.size.height + nextLineRect.size.height));
                } else {
                    lineRectArray[i] = @(CGRectMake(nextLineRect.origin.x, currentLineRect.origin.y, nextLineRect.size.width, currentLineRect.size.height + nextLineRect.size.height));
                }
                [lineRectArray removeObjectAtIndex:(i + 1)];
            } else {
                i ++;
            }
        }
        
        if (self.textView.textAlignment == NSTextAlignmentLeft) {
            path = [self drawAlignmentLeftLineRectArray:lineRectArray];
        } else if (self.textView.textAlignment == NSTextAlignmentRight) {
            path = [self drawAlignmentRightLineRectArray:lineRectArray];
        } else {
            path = [self drawAlignmentCenterLineRectArray:lineRectArray];
        }
    }
    
    if (self.alignmentType == AWEStoryTextAlignmentCenter || array.count == 1) {
        //先移动到原点，然后做翻转，然后再移动到指定位置
        UIBezierPath *reversingPath = path.bezierPathByReversingPath;
        CGRect boxRect = CGPathGetPathBoundingBox(reversingPath.CGPath);
        [reversingPath applyTransform:CGAffineTransformMakeTranslation(- CGRectGetMidX(boxRect), - CGRectGetMidY(boxRect))];
        [reversingPath applyTransform:CGAffineTransformMakeScale(-1, 1)];
        [reversingPath applyTransform:CGAffineTransformMakeTranslation(CGRectGetWidth(boxRect) + CGRectGetMidX(boxRect), CGRectGetMidY(boxRect))];
        [path appendPath:reversingPath];
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    leftLayer.path = path.CGPath;
    CGRect frame = self.textView.frame;
    frame.origin.x += kAWEStoryBackgroundTextViewContainerInset;
    frame.origin.y += kAWEStoryBackgroundTextViewContainerInset;
    leftLayer.frame = frame;
    [CATransaction commit];
}

////////////////////////////////////////////////////////////////////////////////

- (CGPoint)leftTopWithRect_up:(CGRect)rect
{
    return CGPointMake(rect.origin.x - kAWEStoryBackgroundTextViewBackgroundColorLeftMargin, rect.origin.y - kAWEStoryBackgroundTextViewBackgroundColorTopMargin);
}

- (CGPoint)leftTopCenterWithRect_up:(CGRect)rect
{
    CGPoint leftTop = [self leftTopWithRect_up:rect];
    return CGPointMake(leftTop.x + kAWEStoryBackgroundTextViewBackgroundRadius , leftTop.y + kAWEStoryBackgroundTextViewBackgroundRadius);
}

- (CGPoint)leftTopWithRect_down:(CGRect)rect
{
    return CGPointMake(rect.origin.x - kAWEStoryBackgroundTextViewBackgroundColorLeftMargin, rect.origin.y + kAWEStoryBackgroundTextViewBackgroundColorTopMargin);
}

- (CGPoint)leftTopCenterWithRect_down:(CGRect)rect
{
    CGPoint leftTop = [self leftTopWithRect_down:rect];
    return CGPointMake(leftTop.x - kAWEStoryBackgroundTextViewBackgroundRadius, leftTop.y + kAWEStoryBackgroundTextViewBackgroundRadius);
}

////////////////////////////////////////////////////////////////////////////////

- (CGPoint)leftBottomWithRect_up:(CGRect)rect
{
    return CGPointMake(rect.origin.x - kAWEStoryBackgroundTextViewBackgroundColorLeftMargin, rect.origin.y + rect.size.height - kAWEStoryBackgroundTextViewBackgroundColorTopMargin);
}

- (CGPoint)leftBottomCenterWithRect_up:(CGRect)rect
{
    CGPoint leftBottomPoint = [self leftBottomWithRect_up:rect];
    return CGPointMake(leftBottomPoint.x - kAWEStoryBackgroundTextViewBackgroundRadius, leftBottomPoint.y - kAWEStoryBackgroundTextViewBackgroundRadius);
}

- (CGPoint)leftBottomWithRect_down:(CGRect)rect
{
    return CGPointMake(rect.origin.x - kAWEStoryBackgroundTextViewBackgroundColorLeftMargin, rect.origin.y + rect.size.height + kAWEStoryBackgroundTextViewBackgroundColorTopMargin);
}

- (CGPoint)leftBottomCenterWithRect_down:(CGRect)rect
{
    CGPoint leftBottomPoint = [self leftBottomWithRect_down:rect];
    return CGPointMake(leftBottomPoint.x + kAWEStoryBackgroundTextViewBackgroundRadius, leftBottomPoint.y - kAWEStoryBackgroundTextViewBackgroundRadius);
}

////////////////////////////////////////////////////////////////////////////////

- (CGPoint)topMidPointWithRect:(CGRect)rect
{
    return CGPointMake(CGRectGetMidX(rect), rect.origin.y - kAWEStoryBackgroundTextViewBackgroundColorTopMargin);
}

- (CGPoint)bottomMidPointWithRect:(CGRect)rect
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect) + kAWEStoryBackgroundTextViewBackgroundColorTopMargin);
}

////////////////////////////////////////////////////////////////////////////////

- (CGPoint)rightTopWithRect_up:(CGRect)rect
{
    return CGPointMake(CGRectGetMaxX(rect) + kAWEStoryBackgroundTextViewBackgroundColorLeftMargin, rect.origin.y - kAWEStoryBackgroundTextViewBackgroundColorTopMargin);
}

- (CGPoint)rightTopCenterWithRect_up:(CGRect)rect
{
    CGPoint rightTop = [self rightTopWithRect_up:rect];
    return CGPointMake(rightTop.x - kAWEStoryBackgroundTextViewBackgroundRadius , rightTop.y + kAWEStoryBackgroundTextViewBackgroundRadius);
}

- (CGPoint)rightTopWithRect_down:(CGRect)rect
{
    return CGPointMake(CGRectGetMaxX(rect) + kAWEStoryBackgroundTextViewBackgroundColorLeftMargin, rect.origin.y + kAWEStoryBackgroundTextViewBackgroundColorTopMargin);
}

- (CGPoint)rightTopCenterWithRect_down:(CGRect)rect
{
    CGPoint rightTop = [self rightTopWithRect_down:rect];
    return CGPointMake(rightTop.x + kAWEStoryBackgroundTextViewBackgroundRadius , rightTop.y + kAWEStoryBackgroundTextViewBackgroundRadius);
}

////////////////////////////////////////////////////////////////////////////////

- (CGPoint)rightBottomWithRect_up:(CGRect)rect
{
    return CGPointMake(CGRectGetMaxX(rect) + kAWEStoryBackgroundTextViewBackgroundColorLeftMargin, CGRectGetMaxY(rect) - kAWEStoryBackgroundTextViewBackgroundColorTopMargin);
}

- (CGPoint)rightBottomCenterWithRect_up:(CGRect)rect
{
    CGPoint rightBottom = [self rightBottomWithRect_up:rect];
    return CGPointMake(rightBottom.x + kAWEStoryBackgroundTextViewBackgroundRadius , rightBottom.y - kAWEStoryBackgroundTextViewBackgroundRadius);
}

- (CGPoint)rightBottomWithRect_down:(CGRect)rect
{
    return CGPointMake(CGRectGetMaxX(rect) + kAWEStoryBackgroundTextViewBackgroundColorLeftMargin, CGRectGetMaxY(rect) + kAWEStoryBackgroundTextViewBackgroundColorTopMargin);
}

- (CGPoint)rightBottomCenterWithRect_down:(CGRect)rect
{
    CGPoint rightBottom = [self rightBottomWithRect_down:rect];
    return CGPointMake(rightBottom.x - kAWEStoryBackgroundTextViewBackgroundRadius , rightBottom.y - kAWEStoryBackgroundTextViewBackgroundRadius);
}

////////////////////////////////////////////////////////////////////////////////

- (UIBezierPath *)drawAlignmentCenterLineRectArray:(NSArray<NSValue *> *)lineRectArray
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGRect firstLineRect = lineRectArray[0].CGRectValue;
    
    CGPoint topMidPoint = [self topMidPointWithRect:firstLineRect];
    [path moveToPoint:topMidPoint];
    
    CGPoint leftTop = [self leftTopWithRect_up:firstLineRect];
    CGPoint leftTopCenter = [self leftTopCenterWithRect_up:firstLineRect];
    [path addLineToPoint:CGPointMake(leftTopCenter.x, leftTop.y)];
    [path addArcWithCenter:leftTopCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:M_PI * 1.5 endAngle:M_PI clockwise:NO];
    
    for (int i = 0; i < lineRectArray.count; i++) {
        CGRect currentLineRect = lineRectArray[i].CGRectValue;
        if (i + 1 < lineRectArray.count) {
            //当前行是中间行
            CGRect nextLineRect = lineRectArray[i + 1].CGRectValue;
            
            CGPoint leftBottomPoint;
            CGPoint leftBottomCenter;
            CGPoint nextLineLeftTopPoint;
            CGPoint nextLineLeftTopCenter;
            if (nextLineRect.origin.x > currentLineRect.origin.x) {
                leftBottomPoint = [self leftBottomWithRect_down:currentLineRect];
                leftBottomCenter = [self leftBottomCenterWithRect_down:currentLineRect];
                [path addLineToPoint:CGPointMake(leftBottomPoint.x, leftBottomCenter.y)];
                [path addArcWithCenter:leftBottomCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:M_PI endAngle:M_PI * 0.5 clockwise:NO];
                
                nextLineLeftTopPoint = [self leftTopWithRect_down:nextLineRect];
                nextLineLeftTopCenter = [self leftTopCenterWithRect_down:nextLineRect];
                [path addLineToPoint:CGPointMake(nextLineLeftTopCenter.x, nextLineLeftTopPoint.y)];
                [path addArcWithCenter:nextLineLeftTopCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:1.5 * M_PI endAngle:2 * M_PI clockwise:YES];
            } else {
                leftBottomPoint = [self leftBottomWithRect_up:currentLineRect];
                leftBottomCenter = [self leftBottomCenterWithRect_up:currentLineRect];
                [path addLineToPoint:CGPointMake(leftBottomPoint.x, leftBottomCenter.y)];
                [path addArcWithCenter:leftBottomCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:0 endAngle:M_PI * 0.5 clockwise:YES];
                
                nextLineLeftTopPoint = [self leftTopWithRect_up:nextLineRect];
                nextLineLeftTopCenter = [self leftTopCenterWithRect_up:nextLineRect];
                [path addLineToPoint:CGPointMake(nextLineLeftTopCenter.x, nextLineLeftTopPoint.y)];
                [path addArcWithCenter:nextLineLeftTopCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:1.5 * M_PI endAngle:M_PI clockwise:NO];
            }
        } else {
            //当前行是最后一行
            CGPoint leftBottomPoint;
            CGPoint leftBottomCenter;
            leftBottomPoint = [self leftBottomWithRect_down:currentLineRect];
            leftBottomCenter = [self leftBottomCenterWithRect_down:currentLineRect];
            [path addLineToPoint:CGPointMake(leftBottomPoint.x, leftBottomCenter.y)];
            [path addArcWithCenter:leftBottomCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:M_PI endAngle:M_PI * 0.5 clockwise:NO];
            
            CGPoint bottomMidPoint = [self bottomMidPointWithRect:currentLineRect];
            [path addLineToPoint:CGPointMake(topMidPoint.x, bottomMidPoint.y)];
        }
    }
    
    return path;
}

- (UIBezierPath *)drawAlignmentLeftLineRectArray:(NSArray<NSValue *> *)lineRectArray
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGRect firstLineRect = lineRectArray[0].CGRectValue;
    
    CGPoint leftTop = [self leftTopWithRect_up:firstLineRect];
    CGPoint leftTopCenter = [self leftTopCenterWithRect_up:firstLineRect];
    
    [path moveToPoint:CGPointMake(leftTopCenter.x, leftTop.y)];
    
    CGPoint rightTop = [self rightTopWithRect_up:firstLineRect];
    CGPoint rightTopCenter = [self rightTopCenterWithRect_up:firstLineRect];
    [path addLineToPoint:CGPointMake(rightTopCenter.x, rightTop.y)];
    [path addArcWithCenter:rightTopCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:M_PI * 1.5 endAngle:M_PI * 2 clockwise:YES];
    
    for (int i = 0; i < lineRectArray.count; i++) {
        CGRect currentLineRect = lineRectArray[i].CGRectValue;
        if (i + 1 < lineRectArray.count) {
            //当前行是中间行
            CGRect nextLineRect = lineRectArray[i + 1].CGRectValue;
            
            CGPoint rightBottomPoint;
            CGPoint rightBottomCenter;
            CGPoint nextLineRightTopPoint;
            CGPoint nextLineRightTopCenter;
            if (nextLineRect.size.width < currentLineRect.size.width) {
                rightBottomPoint = [self rightBottomWithRect_down:currentLineRect];
                rightBottomCenter = [self rightBottomCenterWithRect_down:currentLineRect];
                [path addLineToPoint:CGPointMake(rightBottomPoint.x, rightBottomCenter.y)];
                [path addArcWithCenter:rightBottomCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:0 endAngle:M_PI * 0.5 clockwise:YES];
                
                nextLineRightTopPoint = [self rightTopWithRect_down:nextLineRect];
                nextLineRightTopCenter = [self rightTopCenterWithRect_down:nextLineRect];
                [path addLineToPoint:CGPointMake(nextLineRightTopCenter.x, nextLineRightTopPoint.y)];
                [path addArcWithCenter:nextLineRightTopCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:1.5 * M_PI endAngle:M_PI clockwise:NO];
            } else {
                rightBottomPoint = [self rightBottomWithRect_up:currentLineRect];
                rightBottomCenter = [self rightBottomCenterWithRect_up:currentLineRect];
                [path addLineToPoint:CGPointMake(rightBottomPoint.x, rightBottomCenter.y)];
                [path addArcWithCenter:rightBottomCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:M_PI endAngle:M_PI * 0.5 clockwise:NO];
                
                nextLineRightTopPoint = [self rightTopWithRect_up:nextLineRect];
                nextLineRightTopCenter = [self rightTopCenterWithRect_up:nextLineRect];
                [path addLineToPoint:CGPointMake(nextLineRightTopCenter.x, nextLineRightTopPoint.y)];
                [path addArcWithCenter:nextLineRightTopCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:1.5 * M_PI endAngle:M_PI * 2 clockwise:YES];
            }
        } else {
            //当前行是最后一行
            CGPoint rightBottomPoint;
            CGPoint rightBottomCenter;
            rightBottomPoint = [self rightBottomWithRect_down:currentLineRect];
            rightBottomCenter = [self rightBottomCenterWithRect_down:currentLineRect];
            [path addLineToPoint:CGPointMake(rightBottomPoint.x, rightBottomCenter.y)];
            [path addArcWithCenter:rightBottomCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:0 endAngle:M_PI * 0.5 clockwise:YES];
            
            CGPoint leftBottomPoint = [self leftBottomWithRect_down:currentLineRect];
            CGPoint leftBottomCenterPoint = [self leftBottomCenterWithRect_down:currentLineRect];
            [path addLineToPoint:CGPointMake(leftBottomCenterPoint.x, leftBottomPoint.y)];
            [path addArcWithCenter:leftBottomCenterPoint radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:M_PI * 0.5 endAngle:M_PI clockwise:YES];
            [path addLineToPoint:CGPointMake(leftTop.x, leftTopCenter.y)];
            [path addArcWithCenter:leftTopCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:M_PI endAngle:1.5 * M_PI clockwise:YES];
        }
    }
    
    return path;
}

- (UIBezierPath *)drawAlignmentRightLineRectArray:(NSArray<NSValue *> *)lineRectArray
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGRect firstLineRect = lineRectArray[0].CGRectValue;
    
    CGPoint rightTopPoint = [self rightTopWithRect_up:firstLineRect];
    CGPoint rightTopCenterPoint = [self rightTopCenterWithRect_up:firstLineRect];
    
    [path moveToPoint:CGPointMake(rightTopCenterPoint.x, rightTopPoint.y)];
    
    CGPoint leftTop = [self leftTopWithRect_up:firstLineRect];
    CGPoint leftTopCenter = [self leftTopCenterWithRect_up:firstLineRect];
    [path addLineToPoint:CGPointMake(leftTopCenter.x, leftTop.y)];
    [path addArcWithCenter:leftTopCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:M_PI * 1.5 endAngle:M_PI clockwise:NO];
    
    for (int i = 0; i < lineRectArray.count; i++) {
        CGRect currentLineRect = lineRectArray[i].CGRectValue;
        if (i + 1 < lineRectArray.count) {
            //当前行是中间行
            CGRect nextLineRect = lineRectArray[i + 1].CGRectValue;
            
            CGPoint leftBottomPoint;
            CGPoint leftBottomCenter;
            CGPoint nextLineLeftTopPoint;
            CGPoint nextLineLeftTopCenter;
            if (nextLineRect.origin.x > currentLineRect.origin.x) {
                leftBottomPoint = [self leftBottomWithRect_down:currentLineRect];
                leftBottomCenter = [self leftBottomCenterWithRect_down:currentLineRect];
                [path addLineToPoint:CGPointMake(leftBottomPoint.x, leftBottomCenter.y)];
                [path addArcWithCenter:leftBottomCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:M_PI endAngle:M_PI * 0.5 clockwise:NO];
                
                nextLineLeftTopPoint = [self leftTopWithRect_down:nextLineRect];
                nextLineLeftTopCenter = [self leftTopCenterWithRect_down:nextLineRect];
                [path addLineToPoint:CGPointMake(nextLineLeftTopCenter.x, nextLineLeftTopPoint.y)];
                [path addArcWithCenter:nextLineLeftTopCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:1.5 * M_PI endAngle:2 * M_PI clockwise:YES];
            } else {
                leftBottomPoint = [self leftBottomWithRect_up:currentLineRect];
                leftBottomCenter = [self leftBottomCenterWithRect_up:currentLineRect];
                [path addLineToPoint:CGPointMake(leftBottomPoint.x, leftBottomCenter.y)];
                [path addArcWithCenter:leftBottomCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:0 endAngle:M_PI * 0.5 clockwise:YES];
                
                nextLineLeftTopPoint = [self leftTopWithRect_up:nextLineRect];
                nextLineLeftTopCenter = [self leftTopCenterWithRect_up:nextLineRect];
                [path addLineToPoint:CGPointMake(nextLineLeftTopCenter.x, nextLineLeftTopPoint.y)];
                [path addArcWithCenter:nextLineLeftTopCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:1.5 * M_PI endAngle:M_PI clockwise:NO];
            }
        } else {
            //当前行是最后一行
            CGPoint leftBottomPoint;
            CGPoint leftBottomCenter;
            leftBottomPoint = [self leftBottomWithRect_down:currentLineRect];
            leftBottomCenter = [self leftBottomCenterWithRect_down:currentLineRect];
            [path addLineToPoint:CGPointMake(leftBottomPoint.x, leftBottomCenter.y)];
            [path addArcWithCenter:leftBottomCenter radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:M_PI endAngle:M_PI * 0.5 clockwise:NO];
            
            CGPoint rightBottomPoint = [self rightBottomWithRect_down:currentLineRect];
            CGPoint rightBottomCenterPoint = [self rightBottomCenterWithRect_down:currentLineRect];
            [path addLineToPoint:CGPointMake(rightBottomCenterPoint.x, rightBottomPoint.y)];
            [path addArcWithCenter:rightBottomCenterPoint radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:M_PI * 0.5 endAngle:0 clockwise:NO];
            [path addLineToPoint:CGPointMake(rightTopPoint.x, rightTopCenterPoint.y)];
            [path addArcWithCenter:rightTopCenterPoint radius:kAWEStoryBackgroundTextViewBackgroundRadius startAngle:2 * M_PI endAngle:1.5 * M_PI clockwise:NO];
        }
    }
    
    return path;
}

#pragma mark -

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    [self handleContentScaleFactor];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.enableEdit) {
        return [super hitTest:point withEvent:event];
    }
    
    CGRect deleteFrame = [self.borderView convertRect:self.deleteButton.frame toView:self];
    deleteFrame = CGRectInset(deleteFrame, -10, -10);
    if (!self.borderView.hidden && CGRectContainsPoint(deleteFrame, point)) {
        return self.deleteButton;
    }
    
    CGRect selectTimeFrame = [self.borderView convertRect:self.selectTimeButton.frame toView:self];
    selectTimeFrame = CGRectInset(selectTimeFrame, -10, -10);
    if (!self.borderView.hidden && CGRectContainsPoint(selectTimeFrame, point)) {
        return self.selectTimeButton;
    }
    
    CGRect editFrame = [self.borderView convertRect:self.editButton.frame toView:self];
    editFrame = CGRectInset(editFrame, -10, -10);
    if (!self.borderView.hidden && CGRectContainsPoint(editFrame, point)) {
        return self.editButton;
    }
    
    return nil;
}

#pragma mark - interaction sticker methods

- (NSString *)poiContent:(NSString *)poiName {
    NSString *icon = @"\U0000e900";//poi icon
    NSString *fontName = @"icomoon";
    NSString *poiAddress = poiName;
    
    NSString *totalStr;
    NSURL *poiFontPath = [[AWEBundle bundleWithName:@"AWEStudio"] URLForResource:fontName withExtension:@"ttf"];
    UIFont *iconFont = [UIFont awe_iconFontWithPath:poiFontPath name:fontName size:20];
    if (iconFont) {
        totalStr = [NSString stringWithFormat:@"%@ %@",icon,poiAddress];
    } else {
        totalStr = poiAddress;
    }
    return totalStr;
}

- (NSAttributedString *)poiAttributedStringWithName:(NSString *)poiName {
    NSString *fontName = @"icomoon";
    NSString *totalStr = [self poiContent:self.poiName];
    NSURL *poiFontPath = [[AWEBundle bundleWithName:@"AWEStudio"] URLForResource:fontName withExtension:@"ttf"];
    
    NSMutableAttributedString *atts = [[NSMutableAttributedString alloc]initWithString:totalStr];
    NSRange poiRange = [totalStr rangeOfString:poiName];
    
    CGFloat width = [totalStr btd_widthWithFont:[UIFont awe_systemFontOfSize:28 weight:AWEFontWeightMedium] height:34];
    if (width > (SCREEN_WIDTH - 16*2 - 16*2 + 2)) {//contaner screen edge gap 16*2,textview container gap 16*2, 2-compensation
        UIFont *iconFont = [UIFont awe_iconFontWithPath:poiFontPath name:fontName size:16];
        if (iconFont) {
            [atts addAttribute:NSFontAttributeName value:iconFont range:NSMakeRange(0, poiRange.location)];
            [atts addAttribute:NSBaselineOffsetAttributeName value:@0.5 range:NSMakeRange(0, poiRange.location)];
            [atts addAttribute:NSKernAttributeName value:@(-1.0) range:NSMakeRange(0, poiRange.location)];
        }
        [atts addAttribute:NSFontAttributeName value:[UIFont awe_systemFontOfSize:20 weight:AWEFontWeightMedium] range:poiRange];
    } else {
        UIFont *iconFont = [UIFont awe_iconFontWithPath:poiFontPath name:fontName size:20];
        if (iconFont) {
            [atts addAttribute:NSFontAttributeName value:iconFont range:NSMakeRange(0, poiRange.location)];
            [atts addAttribute:NSBaselineOffsetAttributeName value:@1.5 range:NSMakeRange(0, poiRange.location)];
            [atts addAttribute:NSKernAttributeName value:@(-1.0) range:NSMakeRange(0, poiRange.location)];
        }
        [atts addAttribute:NSFontAttributeName value:[UIFont awe_systemFontOfSize:28 weight:AWEFontWeightMedium] range:poiRange];
    }
    
    return atts;
}

- (CGFloat)poiContainerWidth {
    NSString *poiContent = [self poiContent:self.poiName];
    CGFloat width = [poiContent btd_widthWithFont:[UIFont awe_systemFontOfSize:28 weight:AWEFontWeightMedium] height:34];
    if (width > (SCREEN_WIDTH - 16*2 - 16*2 + 2)) {
        width = [poiContent btd_widthWithFont:[UIFont awe_systemFontOfSize:20 weight:AWEFontWeightMedium] height:26];
    }
    return width + 16*2 - 10;//-10因为文本是左对齐
}

- (CGFloat)poiContainerHeight {
    NSString *poiContent = [self poiContent:self.poiName];
    CGFloat width = [poiContent btd_widthWithFont:[UIFont awe_systemFontOfSize:28 weight:AWEFontWeightMedium] height:34];
    CGFloat height = 34;
    if (width > (SCREEN_WIDTH - 16*2 - 16*2 + 2)) {
        height = 26;
    }
    return height + 2*8;
}

- (UILabel *)poiLblWithAlpha:(CGFloat)alpha {
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, self.textView.frame.size.width-14, self.textView.frame.size.height)];
    label1.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
    label1.textAlignment = NSTextAlignmentLeft;
    label1.attributedText = [self poiAttributedStringWithName:self.poiName];
    return label1;
}

- (AWEStoryBackgroundTextView *)poiStickerInContainer:(UIView *)superView {
    __block AWEStoryBackgroundTextView *poiSticker;
    [[superView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[AWEStoryBackgroundTextView class]]) {
            if (((AWEStoryBackgroundTextView *)obj).isInteractionSticker) {
                poiSticker = (AWEStoryBackgroundTextView *)obj;
                *stop = YES;
            }
        }
    }];
    return poiSticker;
}

- (void)setIsInteractionSticker:(BOOL)isInteractionSticker
{
    _isInteractionSticker = isInteractionSticker;
    self.textInfoModel.isPOISticker = isInteractionSticker;
}

@end
