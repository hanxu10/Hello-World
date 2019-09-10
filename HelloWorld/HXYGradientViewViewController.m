//
//  HXYGradientViewViewController.m
//  HelloWorld
//
//  Created by zhangfeng on 2019/8/19.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "HXYGradientViewViewController.h"

@interface HXYGradientView : UIView

@end

@implementation HXYGradientView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
        gradientLayer.startPoint = CGPointMake(0.0f, 0.5f);
        gradientLayer.endPoint = CGPointMake(1.0f, 0.5f);
        gradientLayer.frame = frame;
        gradientLayer.colors = @[(__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.0f].CGColor,
                                 (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:1.0f].CGColor,
                                 (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:1.0f].CGColor];
        gradientLayer.locations = @[@(0), @(0.5), @(1)];
    }
    return self;
}

+ (Class)layerClass {
    return [CAGradientLayer class];
}

@end


@interface HXYGradientViewViewController ()

@end

@implementation HXYGradientViewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   
   
    CGRect frame = CGRectMake(100, 100, 300, 50);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = @"时代峰峻多少了房价都是垃圾";
    HXYGradientView *gradientView = [[HXYGradientView alloc] initWithFrame:frame];
    [self.view addSubview:label];
    [self.view addSubview:gradientView];
}

@end
