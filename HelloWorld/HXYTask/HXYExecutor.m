//
// Created by zhangfeng on 2019-08-17.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import "HXYExecutor.h"
#import <pthread.h>
#import <ARKit/ARKit.h>

__attribute__((noinline)) static size_t remaining_stack_size(size_t *restrict totalSize) {
    pthread_t currentThread = pthread_self();
    uint8_t *endStack = pthread_get_stackaddr_np(currentThread);
    *totalSize = pthread_get_stacksize_np(currentThread);

    uint8_t *frameAddr = __builtin_frame_address(0);
    return (*totalSize) - (size_t) (endStack - frameAddr);

}

@interface HXYExecutor ()

@property(nonatomic, strong) void (^block)(void(^)(void));

@end

@implementation HXYExecutor

+ (instancetype)defaultExecutor {
    static HXYExecutor *defaultExecutor = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultExecutor = [self executorWithBlock:^void(void(^block)(void)) {
            // We prefer to run everything possible immediately, so that there is callstack information
            // when debugging. However, we don't want the stack to get too deep, so if the remaining stack space
            // is less than 10% of the total space, we dispatch to another GCD queue.
            size_t totalStackSize = 0;
            size_t remainingStackSize = remaining_stack_size(&totalStackSize);

            if (remainingStackSize < (totalStackSize / 10)) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
            } else {
                @autoreleasepool {
                    block();
                }
            }
        }];
    });
    return defaultExecutor;
}

+ (instancetype)immediateExecutor {
    static HXYExecutor *immediateExecutor = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        immediateExecutor = [self executorWithBlock:^void(void(^block)(void)) {
            block();
        }];
    });
    return immediateExecutor;
}

+ (instancetype)mainThreadExecutor {
    static HXYExecutor *mainThreadExecutor = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mainThreadExecutor = [self executorWithBlock:^(void (^innerBlock)(void)) {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), innerBlock);
            } else {
                @autoreleasepool {
                    innerBlock();
                }

            }
        }];
    });
    return mainThreadExecutor;
}

+ (instancetype)executorWithBlock:(void(^)(void(^block)(void)))block {
    return [[self alloc] initWithBlock:block];
}

+ (instancetype)executorWithDispatchQueue:(dispatch_queue_t)queue {
    return [self executorWithBlock:^void(void(^block)(void)) {
        dispatch_async(queue, block);
    }];
}

+ (instancetype)executorWithOperationQueue:(NSOperationQueue *)queue {
    return [self executorWithBlock:^(void (^innerBlock)(void)) {
        [queue addOperationWithBlock:innerBlock];
    }];
}

- (instancetype)initWithBlock:(void (^)(void(^innerBlock)(void)))block {
    if (self = [super init]) {
        _block = block;
    }
    return self;
}

- (void)execute:(void (^)(void))block {
    self.block(block);
}

@end