//
//  HXYViewControllerBlue.m
//  HelloWorld
//
//  Created by zhangfeng on 2019/8/6.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "HXYViewControllerBlue.h"
#import <Bolts/Bolts.h>

@interface HXYViewControllerBlue () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation HXYViewControllerBlue

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    self.scrollView.backgroundColor = [UIColor redColor];
    self.scrollView.contentSize = CGSizeMake(200, 350);
    self.scrollView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //getPasswordTask会返回一个task,这个task去获取密码,并且在获取成功后设置result,触发continueWithSuccessBlock里的内容.
    //
    [[[self getPasswordTask] continueWithSuccessBlock:^id _Nullable(BFTask<NSString *> * _Nonnull t) {
        NSString *passwd = t.result;
        if ([passwd hasPrefix:@"err"]) {
            return [BFTask taskWithError:[NSError errorWithDomain:@"醋五了" code:222 userInfo:@{}]];
        }
        return [self getUserMoneyWithPasswd:passwd];
    }] continueWithSuccessBlock:^id _Nullable(BFTask<NSString *> * _Nonnull t) {
        NSString *money = t.result;
        return nil;
    }];
    
    [[[self getPasswordTask] continueWithSuccessBlock:^id _Nullable(BFTask<NSString *> * _Nonnull t) {
        NSString *passwd = t.result;
        if ([passwd hasPrefix:@"err"]) {
            return [BFTask taskWithError:[NSError errorWithDomain:@"醋五了" code:222 userInfo:@{}]];
        }
        return [self getUserMoneyWithPasswd:passwd];
    }] continueWithBlock:^id _Nullable(BFTask<NSString *> * _Nonnull t) {
        NSString *money = t.result;
        return nil;
    }];
    
    
   
    BFExecutor *executor = [BFExecutor executorWithDispatchQueue:dispatch_get_global_queue(0, 0)];
    BFTask *task = [BFTask taskFromExecutor:executor withBlock:^id {
        return nil;
    }];
    
    [task continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        NSLog(@"%@", t.result);
        return nil;
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"xxxx %@", NSStringFromCGPoint(scrollView.contentOffset));
}

//
- (BFTask<NSString *> *)getPasswordTaskSyn {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    [completionSource setResult:@"ok o"];
    return completionSource.task;
}

- (BFTask<NSString *> *)getUserMoneyWithPasswdSyn:(NSString *)passwd {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    [completionSource setResult:@"1000万"];
    return completionSource.task;
}

//
- (BFTask<NSString *> *)getPasswordTask {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [completionSource setResult:@"err"];
    });
    return completionSource.task;
}

- (BFTask<NSString *> *)getUserMoneyWithPasswd:(NSString *)passwd {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [completionSource setResult:@"1000万"];
    });
    return completionSource.task;
}

@end
