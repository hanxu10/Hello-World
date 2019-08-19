//
// Created by zhangfeng on 2019-08-17.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import "HXYCancellationTokenSource.h"
#import "HXYCancellationToken.h"

@interface HXYCancellationToken (HXYCancellationTokenSource)
- (void)cancel;
- (void)unregisterRegistration:(HXYCancellationTokenRegistration *)registration;
- (void)cancelAfterDelay:(int)millis;
- (void)dispose;
@end

@implementation HXYCancellationTokenSource

- (instancetype)init {
    self = [super init];
    if (!self) return self;

    _token = [[HXYCancellationToken alloc] init];

    return self;
}

+ (instancetype)cancellationTokenSource {
    return [[HXYCancellationTokenSource alloc] init];
}

- (BOOL)isCancellationRequested {
    return _token.isCancellationRequested;
}

- (void)cancel {
    [_token cancel];
}

- (void)cancelAfterDelay:(int)millis {
    [_token cancelAfterDelay:millis];
}

- (void)dispose {
    [_token dispose];
}

@end
