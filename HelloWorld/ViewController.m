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
#import "HXYTextKitViewController.h"
#import <MJExtension/MJExtension.h>
#import "User.h"
#import "HXYThreadViewController.h"
#import "HXYDrawViewController.h"
#import "HXYCalendarCollectionViewViewController.h"
#import "HXYGradientViewViewController.h"
#import "HXYTransitionDemo1ViewController.h"

@interface ViewController () <AWESlidingViewControllerDelegate>
@property (nonatomic, strong) AVAssetImageGenerator *gen;
@property (nonatomic, strong) AWESlidingTabbarView *slidingTabView;
@property (nonatomic, strong) AWESlidingViewController *slidingViewController;

@property (nonatomic, strong) NSMutableArray *vcs;
@property (nonatomic, weak) Person *p;

@end

@implementation ViewController


- (NSArray *)tabNames {
    NSArray *classes = [self classes];
    NSMutableArray *ret = [@[] mutableCopy];
    for (Class c in classes) {
        [ret addObject:NSStringFromClass(c)];
    }
    return ret;
}

- (NSArray *)classes {
    static NSArray *xx = nil;
    if (!xx) {
        xx = @[
               [HXYTextKitViewController class],
               [HXYTransitionDemo1ViewController class],
               [HXYGradientViewViewController class],
               [HXYCalendarCollectionViewViewController class],
               [HXYDrawViewController class],
               [HXYViewControllerRed class],
               [HXYViewControllerBlue class],
               [HXYThreadViewController class],
               ];
    }

    return xx;
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];

    [self testPerson];
    
    self.vcs = [@[] mutableCopy];
    for (Class c in [self classes]) {
        [self.vcs addObject:[[c alloc] init]];
    }

    NSDictionary *dict = @{
                           @"name" : @"Jack",
                           @"icon" : @"lufy.png",
                           @"age" : @20,
                           @"height" : @"1.55",
                           @"money" : @100.9,
                           @"sex" : @(SexFemale),
                           @"gay" : @"true"
                           //   @"gay" : @"1"
                           //   @"gay" : @"NO"
                           };

    // JSON -> User
    User *user = [User mj_objectWithKeyValues:dict];


    [self.view addSubview:self.slidingTabView];
    self.slidingTabView.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);

    [self addChildViewController:self.slidingViewController];
    [self.slidingViewController didMoveToParentViewController:self];
    [self.view addSubview:self.slidingViewController.view];
    self.slidingViewController.view.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - 40);
    self.slidingViewController.selectedIndex = 0;


    return;

    NSString *keyPath = @".a.b.c.";
    NSArray *keyPathArray = [keyPath componentsSeparatedByString:@"."];



    struct example {
        id   anObject;
        char *aString;
        int  anInt;
    };

    char *buf2 = @encode(struct example);
    char *buf3 = @encode(CGPoint);
    char *buf4 = @encode(CGRect);
    char *buf5 = @encode(void(^)(NSString *, CGRect));
    char *buf6 = @encode(id);
    char *buf7 = @encode(Person);
    char *buf8 = @encode(Class);

    Person *p = [Person yy_modelWithJSON:@{
                                           @"name" : @"zhangfeng",
                                           @"address" : @"中国",
                                           }];

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



//    NSString *path = [[NSBundle mainBundle] pathForResource:@"info.json" ofType:nil];
//    NSData *data = [NSData dataWithContentsOfFile:path];
//    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//    NSURL *xxsdf = [NSURL URLWithString:@"/Users/zhangfeng/Desktop/jsonGENModel"];
//    [ZZJsonToModel zz_createYYModelWithJson:json fileName:@"InfoModel" extensionName:@"json" fileURL:xxsdf error:nil];
}

- (void)pdf {
    NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"pdf"];
    CGPDFDocumentRef pdfRef = CGPDFDocumentCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:pdfPath]);



    CGPDFDocumentRelease(pdfRef);
}

#pragma mark - slidingVc

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
        _slidingTabView = [[AWESlidingTabbarView alloc]
                           initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)
                           buttonStyle:AWESlidingTabButtonStyleIrregularText scrollEnabled:YES
                           dataArray:[self tabNames]
                           selectedDataArray:[self tabNames]];
        _slidingTabView.backgroundColor = [UIColor purpleColor];
        [_slidingTabView configureButtonTextColor:[UIColor redColor] selectedTextColor:[UIColor greenColor]];
    }
    return _slidingTabView;
}

#pragma mark -

- (void)testPerson {
    self.p = [[Person alloc] init];
    NSLog(@"testPerson finish");
}

#pragma mark - AWESlidingViewControllerDelegate

- (NSInteger)numberOfControllers:(AWESlidingViewController *)slidingController
{
    return [self vcs].count;
}

- (UIViewController *)slidingViewController:(AWESlidingViewController *)slidingViewController viewControllerAtIndex:(NSInteger)index
{
    return self.vcs[index];
}

- (void)slidingViewController:(AWESlidingViewController *)slidingViewController didSelectIndex:(NSInteger)index
{

}

@end
