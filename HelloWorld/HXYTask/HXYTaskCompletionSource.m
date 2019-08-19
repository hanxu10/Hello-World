//
// Created by zhangfeng on 2019-08-17.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import "HXYTaskCompletionSource.h"
#import "HXYTask.h"

@interface HXYTask (HXYTaskCompletionSource)

- (BOOL)trySetResult:(nullable id)result;
- (BOOL)trySetError:(NSError *)error;
- (BOOL)trySetCancelled;

@end

@implementation HXYTaskCompletionSource

+ (instancetype)taskCompletionSource {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (!self) return self;

    _task = [[HXYTask alloc] init];

    return self;
}

- (void)setResult:(id)result {
    if (![self.task trySetResult:result]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot set the result on a completed task."];
    }
}

- (void)setError:(NSError *)error {
    if (![self.task trySetError:error]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot set the error on a completed task."];
    }
}

- (void)cancel {
    if (![self.task trySetCancelled]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot cancel a completed task."];
    }
}

- (BOOL)trySetResult:(nullable id)result {
    return [self.task trySetResult:result];
}

- (BOOL)trySetError:(NSError *)error {
    return [self.task trySetError:error];
}

- (BOOL)trySetCancelled {
    return [self.task trySetCancelled];
}

@end
