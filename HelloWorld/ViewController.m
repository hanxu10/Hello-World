//
//  ViewController.m
//  HelloWorld
//
//  Created by xuxune on 2019/7/15.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
#import "HXYDrawingUtil.h"
#import <AVFoundation/AVFoundation.h>
#import "ZZJsonToModel/ZZJsonToModel.h"
#import "Person.h"
#import "YYModel.h"
#import "HXYSlidingController/AWESlidingViewController.h"
#import "HXYSlidingController/AWESlidingTabbarView.h"
#import "HXYViewControllerBlue.h"
#import "HXYViewControllerRed.h"

@interface ViewController ()
@property (nonatomic, strong) AVAssetImageGenerator *gen;
@property (nonatomic, strong) AWESlidingTabbarView *slidingTabView;
@property (nonatomic, strong) AWESlidingViewController *slidingViewController;

@property (nonatomic, strong) HXYViewControllerBlue *blueVc;
@property (nonatomic, strong) HXYViewControllerRed *redVc;

@end

@implementation ViewController

- (AWESlidingViewController *)slidingViewController
{
    if (!_slidingViewController) {
        _slidingViewController = [[AWESlidingViewController alloc] init];
        _slidingViewController.automaticallyAdjustsScrollViewInsets = NO;
        _slidingViewController.slideEnabled = YES;
        _slidingViewController.delegate = self;
        _slidingViewController.tabbarView = self.slidingTabView;
    }
    return _slidingViewController;
}

- (AWESlidingTabbarView *)slidingTabView
{
    if (!_slidingTabView) {
        _slidingTabView = [[AWESlidingTabbarView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40) buttonStyle:AWESlidingTabButtonStyleIrregularText scrollEnabled:NO dataArray:@[@"视频", @"照片"] selectedDataArray:@[@"视频", @"照片"]];
        _slidingTabView.backgroundColor = [UIColor purpleColor];
        [_slidingTabView configureButtonTextColor:[UIColor redColor] selectedTextColor:[UIColor greenColor]];
    }
    return _slidingTabView;
}

- (HXYViewControllerRed *)redVc {
    if (!_redVc) {
        _redVc = [[HXYViewControllerRed alloc] init];
    }
    return _redVc;
}

- (HXYViewControllerBlue *)blueVc {
    if (!_blueVc) {
        _blueVc = [[HXYViewControllerBlue alloc] init];
    }
    return _blueVc;
}

#pragma mark - AWESlidingViewControllerDelegate

- (NSInteger)numberOfControllers:(AWESlidingViewController *)slidingController
{
    return 2;
}

- (UIViewController *)slidingViewController:(AWESlidingViewController *)slidingViewController viewControllerAtIndex:(NSInteger)index
{
    if (index == 0) {
        return self.redVc;
    } else {
        return self.blueVc;
    }
}

- (void)slidingViewController:(AWESlidingViewController *)slidingViewController didSelectIndex:(NSInteger)index
{

}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AWESlidingViewController *slidingVc = [[AWESlidingViewController alloc] init];
    [self.view addSubview:self.slidingTabView];
    self.slidingTabView.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
    
    [self addChildViewController:self.slidingViewController];
    [self.slidingViewController didMoveToParentViewController:self];
    [self.view addSubview:self.slidingViewController.view];
    self.slidingViewController.view.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - 40);
    self.slidingViewController.selectedIndex = 0;
   
    return;
    
    Person *p = [Person yy_modelWithJSON:@{
                                           @"name" : @"zhangfeng",
                                           @"address" : @"中国",
                                           }];
    
//    UIImageView *waterImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
//    waterImageView.image = [UIImage imageNamed:@"water"];
//    [self.view addSubview:waterImageView];
//
//    UIInterpolatingMotionEffect *motionEffect;
//    motionEffect = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x"
//                                                                  type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
//    motionEffect.minimumRelativeValue = @(-25);
//    motionEffect.maximumRelativeValue = @(25);
//    [waterImageView addMotionEffect:motionEffect];
//
//    motionEffect = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y"
//                                                                  type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
//    motionEffect.minimumRelativeValue = @(-25);
//    motionEffect.maximumRelativeValue = @(25);
//    [waterImageView addMotionEffect:motionEffect];
    
    //------------------------------------------------------------
    //------------------------------------------------------------
    
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.defaultMotionEffectsEnabled = YES;
//    hud.mode = MBProgressHUDModeAnnularDeterminate;
//    hud.label.text = @"Loading";
//
//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//        // Do something...
//        sleep(4);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//        });
//    });
    
    //------------------------------------------------------------
    //------------------------------------------------------------
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 300, 300)];
    UIImage *image = [HXYDrawingUtil drawImageWithSize:CGSizeMake(300, 300) drawBlock:^(CGContextRef context, CGSize size) {
        CGRect rect = CGRectMake(0, 0, 300, 300);
//        UIBezierPath *shape1 = [UIBezierPath bezierPathWithOvalInRect:rect];
//        rect.origin.x += 100;
        UIBezierPath *shape2 = [UIBezierPath bezierPathWithOvalInRect:rect];
        shape2.lineWidth = 5;
        
        // Then draw green
        [[[UIColor greenColor] colorWithAlphaComponent:0.5] set];
        [shape2 fill];
        
        CGContextFillRect(context, rect);
        // First draw purple
        [[UIColor purpleColor] set];
        [shape2 stroke];
    }];
    
    UIImage *alphaImage1 = [HXYDrawingUtil drawImageWithSize:CGSizeMake(300, 300) drawBlock:^(CGContextRef context, CGSize size) {
        NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        CGPoint center = CGPointMake(150, 150);
        CGFloat r = 50;
        UIFont *font = [UIFont systemFontOfSize:14];
        for(int i = 0; i < 26; i++) {
            NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
            CGSize letterSize = [letter sizeWithAttributes:@{NSFontAttributeName:font}];
            CGFloat theta = M_PI - i * (2 * M_PI / 26.0);
            CGFloat x = center.x + r * sin(theta) - letterSize.width / 2.0;
            CGFloat y = center.y + r * cos(theta) - letterSize.height / 2.0;
            [letter drawAtPoint:CGPointMake(x, y) withAttributes:@{NSFontAttributeName:font}];
        }
    }];
    
    UIImage *alphaImage2 = [HXYDrawingUtil drawImageWithSize:CGSizeMake(300, 300) drawBlock:^(CGContextRef context, CGSize size) {
        NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        CGPoint center = CGPointMake(150, 150);
        CGFloat r = 50;
        UIFont *font = [UIFont systemFontOfSize:14];
        
        //从调整原点开始
        CGContextTranslateCTM(context, center.x, center.y);
        
        for(int i = 0; i < 26; i++) {
            NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
            CGSize letterSize = [letter sizeWithAttributes:@{NSFontAttributeName:font}];
            CGFloat theta = i * (2 * M_PI / 26.0);
            
            CGContextSaveGState(context);
            
            CGContextRotateCTM(context, theta);
            //平移到半径的边缘，向左移动一半的字母宽度。高度平移是负的，因为这个绘图序列使用UIKit坐标系。向上移动到更低的y值。
            CGContextTranslateCTM(context, -letterSize.width / 2.0, -r);
            [letter drawAtPoint:CGPointMake(0, 0) withAttributes:@{NSFontAttributeName:font}];
            
            CGContextRestoreGState(context);
        }
    }];
    
    UIImage *alphaImage3 = [HXYDrawingUtil drawImageWithSize:CGSizeMake(300, 300) drawBlock:^(CGContextRef context, CGSize size) {
        NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        CGPoint center = CGPointMake(150, 150);
        CGFloat r = 50;
        UIFont *font = [UIFont systemFontOfSize:14];
        
        //从调整原点开始
        CGContextTranslateCTM(context, center.x, center.y);
        
        
        // Calculate the full extent
        CGFloat fullSize = 0;
        for (int i = 0; i < 26; i++) {
            NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
            CGSize letterSize = [letter sizeWithAttributes:@{NSFontAttributeName:font}];
            fullSize += letterSize.width;
        }
        // Initialize the consumed space
        CGFloat consumedSize = 0.0f;
        // Iterate through each letter, consuming that width
        for (int i = 0; i < 26; i++) {
            // Measure each letter
            NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
            CGSize letterSize = [letter sizeWithAttributes:@{NSFontAttributeName:font}];
            // Move the pointer forward, calculating the
            // new percentage of travel along the path
            consumedSize += letterSize.width / 2.0f;
            CGFloat percent = consumedSize / fullSize;
            CGFloat theta = percent * 2 * M_PI;
            consumedSize += letterSize.width / 2.0f;
            
            // Prepare to draw the letter by saving the state
            CGContextSaveGState(context);
            // Rotate the context by the calculated angle
            CGContextRotateCTM(context, theta);
            // Move to the letter position
            CGContextTranslateCTM(context, -letterSize.width / 2, -r);
            // Draw the letter
            [letter drawAtPoint:CGPointMake(0, 0) withFont:font];
            // Reset the context back to the way it was
            CGContextRestoreGState(context);
        }
    }];
    
    UIImage *cgrectDivide = [HXYDrawingUtil drawImageWithSize:CGSizeMake(300, 300) drawBlock:^(CGContextRef context, CGSize size) {
        CGRect rect = CGRectMake(0, 0, 300, 300);
        
        UIBezierPath *path;
        CGRect remainder;
        CGRect slice;
        
        //从左边切下一片，涂成橙色
        CGRectDivide(rect, &slice, &remainder, 80, CGRectMinXEdge);
        [[UIColor orangeColor] set];
        path = [UIBezierPath bezierPathWithRect:slice];
        [path fill];
        
        //将另一部分水平切成两半
        rect = remainder;
        CGRectDivide(rect, &slice, &remainder, remainder.size.height * 0.5, CGRectMinYEdge);
        
        //将切片部分涂成紫色
        [[UIColor purpleColor] set];
        path = [UIBezierPath bezierPathWithRect:slice];
        [path fill];
        
        //从左下角切出20个点。
        //用灰色画
        rect = remainder;
        CGRectDivide(rect, &slice, &remainder, 20, CGRectMinXEdge);
        [[UIColor grayColor] set];
        path = [UIBezierPath bezierPathWithRect:slice];
        [path fill];
        
        //再从右边切20
        rect = remainder;
        CGRectDivide(rect, &slice, &remainder, 20, CGRectMaxXEdge);
        // Use same color on the right
        path = [UIBezierPath bezierPathWithRect:slice]; [path fill];
        
        // Fill the rest in brown
        [[UIColor brownColor] set];
        path = [UIBezierPath bezierPathWithRect:remainder];
        [path fill];
    }];
    
    CGRect rect = CGRectMake(0, 0, 300, 300);
    UIImage *centerAStringImage = [HXYDrawingUtil drawImageWithSize:rect.size drawBlock:^(CGContextRef context, CGSize size) {
        
        NSString *string = @"Hello World";
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:48];
        
        CGSize stringSize = [string sizeWithAttributes:@{NSFontAttributeName : font}];
        CGRect target = RectAroundCenter(RectGetCenter(rect), stringSize);
        
        [[UIColor redColor] set];
        
        CGContextStrokeRect(context, target);
        
        [[UIColor greenColor] set];
        CGRect smallRect = target;
        smallRect.size.width -= 0;
        [string drawInRect:smallRect withFont:font];
    }];
    
    UIImage *colorImage = [HXYDrawingUtil imageWithColor:[UIColor greenColor] size:CGSizeMake(100, 200)];

    UIImage *waterimage = [UIImage imageNamed:@"water"];
//    waterimage = [UIImage imageWithCGImage:waterimage.CGImage scale:[UIScreen mainScreen].scale orientation:waterimage.imageOrientation];
    UIImage *xx = [HXYDrawingUtil thumbnailImage:waterimage targetSize:CGSizeMake(200, 200) useFitting:YES];
    xx = ExtractRectFromImage(waterimage, CGRectMake(0, 0, 576, 300));
    xx = [HXYDrawingUtil grayscaleVersionOfImage:waterimage];
    
    rect = CGRectMake(0, 0, waterimage.size.width, waterimage.size.height);
    xx = [HXYDrawingUtil drawImageWithSize:rect.size drawBlock:^(CGContextRef context, CGSize xxsize) {
        CGRect targetRect = rect;
        UIImage *sourceImage = waterimage;
        CGRect imgRect = rect;
        [sourceImage drawInRect:imgRect];
        
        CGPoint center = RectGetCenter(targetRect);
        CGContextTranslateCTM(context, center.x, center.y);
        CGContextRotateCTM(context, M_PI_4 * 0.5);
        CGContextTranslateCTM(context, -center.x, -center.y);
        
        NSString *watermark = @"watermark";
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:48];
        CGSize size = [watermark sizeWithAttributes:@{NSFontAttributeName : font}];
        CGRect stringRect = RectCenteredInRect(RectMakeRect(CGPointZero, size), targetRect);
        
        stringRect.origin.x = 0;
        stringRect.origin.y = 0;
        
        CGContextSetBlendMode(context, kCGBlendModeDifference);
        [watermark drawInRect:stringRect withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:[UIColor whiteColor]}];
        CGContextStrokeRect(context, stringRect);
    }];
    
    imageView.backgroundColor = [UIColor yellowColor];
    imageView.image = centerAStringImage;
    [self.view addSubview:imageView];
    
    
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test.MP4" withExtension:nil];
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    self.gen = gen;
    gen.maximumSize = CGSizeMake(720, 720);
    NSValue *time = [NSValue valueWithCMTime:kCMTimeZero];
    NSTimeInterval currentTime = CACurrentMediaTime();
    [gen generateCGImagesAsynchronouslyForTimes:@[time] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *xximage = [[UIImage alloc]initWithCGImage:image];
            NSLog(@"xxxx %f", CACurrentMediaTime() - currentTime);
        }
    }];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do something...
        sleep(4);
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"info.json" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSURL *xxsdf = [NSURL URLWithString:@"/Users/zhangfeng/Desktop/jsonGENModel"];
    [ZZJsonToModel zz_createYYModelWithJson:json fileName:@"InfoModel" extensionName:@"json" fileURL:xxsdf error:nil];
}

- (void)pdf {
    NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"pdf"];
    CGPDFDocumentRef pdfRef = CGPDFDocumentCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:pdfPath]);
    
    
    
    CGPDFDocumentRelease(pdfRef);
}

@end
