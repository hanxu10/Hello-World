//
// Created by zhangfeng on 2019-08-16.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import "HXYCancellationToken.h"
#import "HXYCancellationTokenRegistration.h"

@interface HXYCancellationTokenRegistration (HXYCancellationToken)

- (void)notifyDelegate;
+ (instancetype)registrationWithToken:(HXYCancellationToken *)token delegate:(HXYCancellationBlock)delegate;

@end

@interface HXYCancellationToken ()

@property (nonatomic, strong) NSMutableArray *registrations;
@property (nonatomic, strong) NSObject *lock;
@property (nonatomic, assign) BOOL disposed;
@property (nonatomic, assign) BOOL cancellationRequested;

@end

@implementation HXYCancellationToken

- (instancetype)init {
    self = [super init];
    if (self) {
        _registrations = [@[] mutableCopy];
        _lock = [[NSObject alloc] init];
    }
    return self;
}

- (BOOL)isCancellationRequested {
    @synchronized (self.lock) {
        [self throwIfDisposed];
        return _cancellationRequested;
    }
}

- (void)cancel {
    NSArray *registrations;
    @synchronized (self.lock) {
        [self throwIfDisposed];
        if (_cancellationRequested) {
            return;
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelPrivate) object:nil];
        _cancellationRequested = YES;
        registrations = [self.registrations copy];
    }

    [self notifyCancellation:registrations];
}

- (void)notifyCancellation:(NSArray *)registrations {
    for (HXYCancellationTokenRegistration *registration in registrations) {
        [registration notifyDelegate];
    }
}

- (HXYCancellationTokenRegistration *)registerCancellationObserverWithBlock:(HXYCancellationBlock)block {
    @synchronized (self.lock) {
        HXYCancellationTokenRegistration *registration = [HXYCancellationTokenRegistration registrationWithToken:self delegate:[block copy]];
        [self.registrations addObject:registration];
        return registration;
    }
}

- (void)unregisterRegistration:(HXYCancellationTokenRegistration *)registration {
    @synchronized (self.lock) {
        [self throwIfDisposed];
        [self.registrations removeObject:registration];
    }
}

- (void)cancelPrivate {
    [self cancel];
}

- (void)cancelAfterDelay:(int)millis {
    [self throwIfDisposed];
    if (millis < -1) {
        [NSException raise:NSInvalidArgumentException format:@"Delay must be >= -1"];
    }
    if (millis == 0) {
        [self cancel];
        return;
    }

    @synchronized (self.lock) {
        [self throwIfDisposed];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelPrivate) object:nil];
        if (self.cancellationRequested) {
            return;
        }

        if (millis != -1) {
            double delay = (double) millis / 1000;
            [self performSelector:@selector(cancelPrivate) withObject:nil afterDelay:delay];
        }
    }
}

- (void)dispose {
    @synchronized (self.lock) {
        if (self.disposed) {
            return;
        }
        [self.registrations makeObjectsPerformSelector:@selector(disposed)];
        self.registrations = nil;
        self.disposed = YES;
    }
}

- (void)throwIfDisposed {
    if (self.disposed) {
        [NSException raise:NSInternalInconsistencyException format:@"Object already disposed"];
    }
}
@end
