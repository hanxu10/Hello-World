//
// Created by zhangfeng on 2019-08-16.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXYCancellationTokenRegistration.h"

typedef void (^HXYCancellationBlock)(void);

@interface HXYCancellationToken : NSObject

@property (nonatomic, assign, readonly, getter=isCancellationRequested) BOOL cancellationRequested;

- (HXYCancellationTokenRegistration *)registerCancellationObserverWithBlock:(HXYCancellationBlock)block;

@end
