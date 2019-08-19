//
//  HXYThreadViewController.m
//  HelloWorld
//
//  Created by zhangfeng on 2019/8/17.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "HXYThreadViewController.h"
#import "HXYNSConditionLockTest.h"

@interface HXYThreadViewController ()

@property (nonatomic, strong) HXYNSConditionLockTest *nsConditionLockTest;

@end

@implementation HXYThreadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nsConditionLockTest = [[HXYNSConditionLockTest alloc] init];
//    [self.nsConditionLockTest forTest];
    
}

@end
