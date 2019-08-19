//
//  HXYNSConditionLockTest.m
//  HelloWorld
//
//  Created by zhangfeng on 2019/8/17.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "HXYNSConditionLockTest.h"

@interface HXYNSConditionLockTest ()
@property (nonatomic,strong) NSMutableArray *tickets;
@property (nonatomic,assign) int soldCount;
@property (nonatomic,strong) NSConditionLock *condition;
@end

@implementation HXYNSConditionLockTest

- (void)forTest
{
    self.tickets = [NSMutableArray arrayWithCapacity:1];
    self.condition = [[NSConditionLock alloc]initWithCondition:0];
    NSThread *windowOne = [[NSThread alloc]initWithTarget:self selector:@selector(soldTicketOne) object:nil];
    [windowOne start];
    
    NSThread *windowTwo = [[NSThread alloc]initWithTarget:self selector:@selector(soldTicketTwo) object:nil];
    [windowTwo start];
    
    NSThread *windowTuiPiao = [[NSThread alloc]initWithTarget:self selector:@selector(tuiPiao) object:nil];
    [windowTuiPiao start];
    
}
//一号窗口
-(void)soldTicketOne
{
    while (YES) {
        NSLog(@"====一号窗口没票了，等别人退票");
        [self.condition lockWhenCondition:1];
        NSLog(@"====在一号窗口买了一张票,%@",[self.tickets objectAtIndex:0]);
        [self.tickets removeObjectAtIndex:0];
        [self.condition unlockWithCondition:0];
    }
}
//二号窗口
-(void)soldTicketTwo
{
    while (YES) {
        NSLog(@"====二号窗口没票了，等别人退票");
        [self.condition lockWhenCondition:2];
        NSLog(@"====在二号窗口买了一张票,%@",[self.tickets objectAtIndex:0]);
        [self.tickets removeObjectAtIndex:0];
        [self.condition unlockWithCondition:0];
    }
}
- (void)tuiPiao
{
    while (YES) {
//        sleep(3);
        [self.condition lockWhenCondition:0];
        [self.tickets addObject:@"南京-北京（退票）"];
        int x = arc4random() % 2;
        if (x == 1) {
            NSLog(@"====有人退票了，赶快去一号窗口买");
            [self.condition unlockWithCondition:1];
        }else
        {
            NSLog(@"====有人退票了，赶快去二号窗口买");
            [self.condition unlockWithCondition:2];
        }
    }
    
}

@end
