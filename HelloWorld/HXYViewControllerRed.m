//
//  HXYViewControllerRed.m
//  HelloWorld
//
//  Created by zhangfeng on 2019/8/6.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "HXYViewControllerRed.h"
#import "Person.h"
#import <objc/message.h>
#import <Masonry/Masonry.h>

@interface HXYViewControllerRed ()

@end

@implementation HXYViewControllerRed

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor redColor];
    
    UIImage *image = [[UIImage imageNamed:@"big"] imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, 0, 196)];
    UIImageView *xx = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:xx];
    [xx mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
//    xx.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.5);
    
    
    
    {
        UIImageView *xx = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"album_icon_pic_check_m_normal-1"]];
        [self.view addSubview:xx];
        xx.center = CGPointMake(150, 100);
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 23, 23)];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    shapeLayer.lineWidth = 1;
    shapeLayer.frame = CGRectMake(0, 00, 23, 23);
    [self.view.layer addSublayer:shapeLayer];
    
    void(*testImp)(id, SEL)  = [self methodForSelector:@selector(test)];
    testImp(self, @selector(test));
    
    ((void(*)(id, SEL))objc_msgSend)(self, @selector(test));
    
//    Person *p = [[Person alloc] init];
//    [p doit];
}

- (void)test {
    SEL xx = _cmd;
    NSLog(@"谢谢%@", NSStringFromSelector(xx));
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSLog(@"任务1:%@",[NSThread currentThread]);
        dispatch_semaphore_signal(sem);
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"任务2:%@",[NSThread currentThread]);
        dispatch_semaphore_signal(sem);
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"任务3:%@",[NSThread currentThread]);
    });
}

@end
