//
//  HXYViewControllerRed.m
//  HelloWorld
//
//  Created by zhangfeng on 2019/8/6.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "HXYViewControllerRed.h"
#import "Person.h"

@interface HXYViewControllerRed ()

@end

@implementation HXYViewControllerRed

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor redColor];
    
    
    UIImageView *xx = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"album_icon_pic_check_m_normal"]];
    [self.view addSubview:xx];
    xx.center = CGPointMake(100, 100);
    
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
    
    Person *p = [[Person alloc] init];
    [p doit];
}

- (void)test {
    SEL xx = _cmd;
    NSLog(@"谢谢%@", NSStringFromSelector(xx));
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
