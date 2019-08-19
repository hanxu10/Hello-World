//
// Created by zhangfeng on 2019-08-17.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HXYTask<__covariant ResultType>;

@interface HXYTaskCompletionSource<__covariant ResultType> : NSObject

+ (instancetype)taskCompletionSource;
@property (nonatomic, strong, readonly) HXYTask<ResultType> *task;
- (void)setResult:(nullable ResultType)result;
- (void)setError:(NSError *)error;
- (void)cancel;
- (BOOL)trySetResult:(nullable ResultType)result;
- (BOOL)trySetError:(NSError *)error;
- (BOOL)trySetCancelled;

@end