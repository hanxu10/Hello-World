//
// Created by zhangfeng on 2019-08-17.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HXYExecutor : NSObject

+ (instancetype)defaultExecutor;
+ (instancetype)immediateExecutor;
+ (instancetype)mainThreadExecutor;
+ (instancetype)executorWithBlock:(void(^)(void(^innerBlock)(void)))block;
+ (instancetype)executorWithDispatchQueue:(dispatch_queue_t)queue;
+ (instancetype)executorWithOperationQueue:(NSOperationQueue *)queue;
- (void)execute:(void(^)(void))block;

@end