//
// Created by zhangfeng on 2019-08-17.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HXYCancellationToken;

@interface HXYCancellationTokenSource : NSObject

+ (instancetype)cancellationTokenSource;

@property (nonatomic, strong, readonly) HXYCancellationToken *token;

@property (nonatomic, assign, readonly, getter=isCancellationRequested) BOOL cancellationRequested;

- (void)cancel;

- (void)cancelAfterDelay:(int)millis;

- (void)dispose;

@end