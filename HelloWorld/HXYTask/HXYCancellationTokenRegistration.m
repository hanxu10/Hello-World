//
// Created by zhangfeng on 2019-08-17.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import "HXYCancellationTokenRegistration.h"
#import "HXYCancellationToken.h"

@interface HXYCancellationToken (HXYCancellationTokenRegistration)

- (void)unregisterRegistration:(HXYCancellationTokenRegistration *)registration;

@end

@interface HXYCancellationTokenRegistration ()

@property (nonatomic, weak) HXYCancellationToken *token;
@property (nonatomic, strong) HXYCancellationBlock cancellationObserverBlock;
@property (nonatomic, strong) NSObject *lock;
@property (nonatomic, assign) BOOL disposed;

@end


@implementation HXYCancellationTokenRegistration

+ (instancetype)registrationWithToken:(HXYCancellationToken *)token delegate:(HXYCancellationBlock)delegate {
    HXYCancellationTokenRegistration *registration = [[HXYCancellationTokenRegistration alloc] init];
    registration.token = token;
    registration.cancellationObserverBlock = delegate;
    return registration;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = [[NSObject alloc] init];
    }
    return self;
}

- (void)dispose {
    @synchronized (self.lock) {
        if (self.disposed) {
            return;
        }
        self.disposed = YES;
    }

    HXYCancellationToken *token = self.token;
    if (token) {
        [token unregisterRegistration:self];
        self.token = nil;
    }
    self.cancellationObserverBlock = nil;
}

- (void)notifyDelegate {
    @synchronized (self.lock) {
        [self throwIfDisposed];
        self.cancellationObserverBlock();
    }
}

- (void)throwIfDisposed {
    NSAssert(!self.disposed, @"Object already disposed");
}

@end
