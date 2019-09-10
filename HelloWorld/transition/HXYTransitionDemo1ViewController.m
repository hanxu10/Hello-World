//
//  HXYTransitionDemo1ViewController.m
//  HelloWorld
//
//  Created by zhangfeng on 2019/8/28.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "HXYTransitionDemo1ViewController.h"
#import "HXYTransitionDemo2ViewController.h"
#import "HXYTransitionDelegate.h"

@interface HXYTransitionDemo1ViewController ()

@property (nonatomic, strong) UIViewPropertyAnimator *animator;
@property (nonatomic, strong) HXYTransitionDelegate *transitionDelegate;

@end

@implementation HXYTransitionDemo1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    {
        UIButton *testButton = [UIButton buttonWithType:UIButtonTypeCustom];
        testButton.frame = CGRectMake(50, 100, 100, 100);
        testButton.backgroundColor = [UIColor redColor];
        [testButton setTitle:@"UIViewPropertyAnimator" forState:UIControlStateNormal];
        [testButton addTarget:self action:@selector(testPropertyAnimator:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:testButton];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [testButton addGestureRecognizer:pan];
    }
    
    {
        UIButton *testButton = [UIButton buttonWithType:UIButtonTypeCustom];
        testButton.frame = CGRectMake(150, 100, 100, 100);
        testButton.backgroundColor = [UIColor redColor];
        [testButton setTitle:@"test" forState:UIControlStateNormal];
        [testButton addTarget:self action:@selector(clickTestButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:testButton];
    }
    
    {
        UIButton *testButton = [UIButton buttonWithType:UIButtonTypeCustom];
        testButton.frame = CGRectMake(250, 100, 100, 100);
        [testButton setTitle:@"catransition" forState:UIControlStateNormal];
        [testButton addTarget:self action:@selector(clickCATransitionButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:testButton];
    }
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

#pragma mark -

- (void)testPropertyAnimator:(UIButton *)button {
    UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:5 curve:UIViewAnimationCurveLinear animations:^{
        button.frame = CGRectMake(50, 500, 100, 100);
    }];
    [animator startAnimation];
    self.animator = animator;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.animator pauseAnimation];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [gesture locationInView:self.view];
        self.animator.fractionComplete = (location.y - 100) / 400;
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.animator startAnimation];
    }
}

#pragma mark -

- (void)clickTestButton:(UIButton *)button {
    HXYTransitionDemo1ViewController *vc = [[HXYTransitionDemo1ViewController alloc] init];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.modalPresentationStyle = UIModalPresentationCustom;
//    vc.transitioningDelegate = self.transitionDelegate;
    [self presentViewController:vc animated:YES completion:nil];
}

- (HXYTransitionDelegate *)transitionDelegate {
    if (!_transitionDelegate) {
        _transitionDelegate = [[HXYTransitionDelegate alloc] init];
    }
    return _transitionDelegate;
}

#pragma mark -

- (void)clickCATransitionButton:(UIButton *)button {
    NSArray *images = @[
                        @"色_000.png",
                        @"色_001.png",
                        @"色_002.png",
                        @"色_003.png",
                        ];
    static NSInteger i = 0;
    
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;
    [button.imageView.layer addAnimation:transition forKey:nil];
    [button setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
    i = (i + 1) % 4;
}

@end
