//
// Created by zhangfeng on 2019-08-17.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXYCancellationToken.h"
#import "HXYGeneric.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const HXYTaskErrorDomain;

extern NSInteger const kHXYMultipleErrorsError;

extern NSString *const HXYTaskMultipleErrorsUserInfoKey;

@class HXYExecutor;
@class HXYTask;

@interface HXYTask<__covariant ResultType> : NSObject

typedef _Nullable id (^HXYContinuationBlock)(HXYTask<ResultType> *t);

+ (instancetype)taskWithResult:(nullable ResultType)result;
+ (instancetype)taskWithError:(NSError *)error;
+ (instancetype)cancelledTask;
+ (instancetype)taskForCompletionOfAllTasks:(nullable NSArray<HXYTask *> *)tasks;
+ (instancetype)taskForCompletionOfAllTasksWithResults:(nullable NSArray<HXYTask *> *)tasks;
+ (instancetype)taskForCompletionOfAnyTask:(nullable NSArray<HXYTask *> *)tasks;
+ (HXYTask<HXYVoid> *)taskWithDelay:(int)millis;
+ (HXYTask<HXYVoid> *)taskWithDelay:(int)millis cancellationToken:(nullable HXYCancellationToken *)token;
+ (instancetype)taskFromExecutor:(HXYExecutor *)executor withBlock:(id(^)(void))block;

@property (nullable, nonatomic, strong, readonly) ResultType result;

@property (nullable, nonatomic, strong, readonly) NSError *error;

@property (nonatomic, assign, readonly, getter=isCancelled) BOOL cancelled;

@property (nonatomic, assign, readonly, getter=isFaulted) BOOL faulted;

@property (nonatomic, assign, readonly, getter=isCompleted) BOOL completed;

- (HXYTask *)continueWithBlock:(HXYContinuationBlock)block;
- (HXYTask *)continueWithBlock:(HXYContinuationBlock)block
            cancellationToken:(nullable HXYCancellationToken *)cancellationToken;
- (HXYTask *)continueWithExecutor:(HXYExecutor *)executor
                       withBlock:(HXYContinuationBlock)block;
- (HXYTask *)continueWithExecutor:(HXYExecutor *)executor
                           block:(HXYContinuationBlock)block
                cancellationToken:(nullable HXYCancellationToken *)cancellationToken;
- (HXYTask *)continueWithSuccessBlock:(HXYContinuationBlock)block;
- (HXYTask *)continueWithSuccessBlock:(HXYContinuationBlock)block
                   cancellationToken:(nullable HXYCancellationToken *)cancellationToken;
- (HXYTask *)continueWithExecutor:(HXYExecutor *)executor
                withSuccessBlock:(HXYContinuationBlock)block;
- (HXYTask *)continueWithExecutor:(HXYExecutor *)executor
                    successBlock:(HXYContinuationBlock)block
               cancellationToken:(nullable HXYCancellationToken *)cancellationToken;

- (void)waitUntilFinished;

@end

NS_ASSUME_NONNULL_END
