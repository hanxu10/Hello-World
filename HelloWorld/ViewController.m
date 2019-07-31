//
//  ViewController.m
//  HelloWorld
//
//  Created by xuxune on 2019/7/15.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
#import "ZZJsonToModel/ZZJsonToModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.defaultMotionEffectsEnabled = YES;
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.label.text = @"Loading";

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
    NSURL *xx = [NSURL URLWithString:@"/Users/xuxu/Desktop/aaxx"];
    [ZZJsonToModel zz_createYYModelWithJson:json fileName:nil extensionName:@"json" fileURL:xx error:nil];
}


@end
