//
//  AWEStoryBackgroundTextView.h
//  AWEStudio
//
//  Created by hanxu on 2018/11/20.
//  Copyright © 2018 bytedance. All rights reserved.
//  文字贴纸、POI贴纸的操作框view

#import <UIKit/UIKit.h>
#import "AWEStoryDeleteView.h"
#import "AWEStoryColor.h"
#import "AWEStoryFontModel.h"
#import "AWEEditorStickerGestureViewController.h"
#import "AWEStickerEditBaseBiew.h"

@class AWEStoryTextImageModel;
@class AWEStoryBackgroundTextView;
@class AWEInteractionStickerModel,AWEInteractionStickerLocationModel;

/**
 *  进入编辑状态时，把textView放到topMaskView上
 *  退出编辑状态时，把textView放到containerView上
 */
extern CGFloat AWEStoryTextContainerViewTopMaskMargin;

extern CGFloat kAWEStoryBackgroundTextViewLeftMargin;
extern CGFloat kAWEStoryBackgroundTextViewBackgroundColorLeftMargin;
extern CGFloat kAWEStoryBackgroundTextViewBackgroundColorTopMargin;
extern CGFloat kAWEStoryBackgroundTextViewBackgroundBorderMargin;
extern CGFloat kAWEStoryBackgroundTextViewBackgroundRadius;
extern CGFloat kAWEStoryBackgroundTextViewKeyboardMargin;

typedef void(^AWEStoryTextViewBlock)(AWEStoryBackgroundTextView *textView);
typedef BOOL(^AWEStoryTextViewShouldBeginGestureBlock)(UIGestureRecognizer *panGesture);

typedef enum : NSUInteger {
    AWEStoryTextStyleNo = 0,//没有底,改颜色就是改文字颜色
    AWEStoryTextStyleBackground = 1,//有底的，改颜色是改背景色，文字颜色为白色。如果选择了白色，（如果是全背景则文字颜色变为黑色， 如果是半透明背景则文字颜色变为白色）
    AWEStoryTextStyleAlphaBackground = 2,
    AWEStoryTextStyleCount,
} AWEStoryTextStyle;

typedef NS_ENUM(NSInteger, AWEStoryTextAlignmentStyle) {
    AWEStoryTextAlignmentCenter = 0,    // 居中
    AWEStoryTextAlignmentLeft = 1,      // 居左
    AWEStoryTextAlignmentRight = 2,     // 居右
    AWEStoryTextAlignmentCount
};

@interface AWEStoryBackgroundTextView : AWEStickerEditBaseBiew <UITextViewDelegate>

@property (nonatomic, weak) id<AWEEditorStickerGestureDelegate> delegate;
@property (nonatomic, weak) AWEEditorStickerGestureViewController *gestureManager;

@property (nonatomic, copy) void (^textChangedBlock) (NSString *content);
@property (nonatomic, copy) AWEStoryTextViewShouldBeginGestureBlock shouldBeginGestureBlock;
@property (nonatomic, copy) AWEStoryTextViewBlock autoDismissHandleBlock;//触发自动删除时执行

@property (nonatomic, strong) AWEStoryColor *color;//用户选择的color，需要根据style判断后，得到textColor和fillColor
@property (nonatomic, strong) AWEStoryFontModel *selectFont;
//@property (nonatomic, strong) NSIndexPath *colorIndexPath;
@property (nonatomic, assign) AWEStoryTextStyle style;
//@property (nonatomic, strong) NSIndexPath *fontIndexPath;
@property (nonatomic, assign) AWEStoryTextAlignmentStyle alignmentType;
@property (nonatomic, assign) CGFloat leftBeyond;
@property (nonatomic, assign) CGPoint basicCenter;
@property (nonatomic, assign) CGPoint lastCenter;//在编辑页的center(非写文字时的center)

// 编辑
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *selectTimeButton;
@property (nonatomic, strong) UIButton *handleButton;
@property (nonatomic, strong) UIButton *editButton;

// gesture
@property (nonatomic, assign, readonly) BOOL enableEdit;
@property (nonatomic, assign, readonly) BOOL lastHandleState;
@property (nonatomic, assign) CGFloat currentScale;
@property (nonatomic, strong, readonly) UIView *borderView;
@property (nonatomic, strong, readonly) CAShapeLayer *borderShapeLayer;
@property (nonatomic, assign) BOOL setAnchorForRotateAndScale;

//写文字时的center
@property (nonatomic, assign, readonly) CGPoint editCenter;
@property (nonatomic, assign) CGFloat keyboardHeight;

//interaction sticker
@property (nonatomic, assign) BOOL isInteractionSticker;
@property (nonatomic, strong) UIView *darkBGView;//遮罩黑色半透明背景
@property (nonatomic,   copy) NSString *poiName;
@property (nonatomic, strong) AWEInteractionStickerLocationModel *stickerLocation;
@property (nonatomic, strong) AWEInteractionStickerModel *interactionStickerInfo;

//编辑信息
@property (nonatomic, strong) NSString *textStickerId;
@property (nonatomic, assign) NSInteger stickerEditId;
@property (nonatomic, assign) CGSize originalSize;
//@property (nonatomic, strong) IESInfoStickerProps *stickerInfos;
@property (nonatomic, strong) AWEStoryTextImageModel *textInfoModel;

//选时长状态
@property (nonatomic, assign) BOOL isSelectTimeMode;

- (instancetype)initWithIsForImage:(BOOL)isForImage;

- (instancetype)initWithTextInfo:(AWEStoryTextImageModel *)model isForImage:(BOOL)isForImage;

- (void)resetWithSuperView:(UIView *)superView;

- (void)transToRecordPosWithSuperView:(UIView *)superView
                    animationDuration:(CGFloat)duration
                           completion:(void (^)(void))completion;

- (void)transToRecordPosWithSuperView:(UIView *)superView
                           completion:(void (^)(void))completion;

- (void)initPosWithSuperView:(UIView *)superView;

- (void)hideHandle;
- (void)showHandleThenDismiss;

- (void)setCanOperate:(BOOL)canOperate;
- (void)handleContentScaleFactor;

- (void)handlePanGesture:(UIPanGestureRecognizer *)ges;

@end
