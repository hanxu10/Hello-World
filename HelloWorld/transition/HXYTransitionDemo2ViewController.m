//
//  HXYTransitionDemo2ViewController.m
//  HelloWorld
//
//  Created by zhangfeng on 2019/8/28.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "HXYTransitionDemo2ViewController.h"

@interface HXYTransitionDemo2ViewController ()

@end

@implementation HXYTransitionDemo2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%@-- %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%@-- %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"%@-- %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"%@-- %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    NSLog(@"%@-- %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    NSLog(@"%@-- %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
