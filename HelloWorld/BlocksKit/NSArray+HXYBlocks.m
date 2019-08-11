//
// Created by xuxune on 2019-08-11.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import "NSArray+HXYBlocks.h"


@implementation NSArray(HXYBlocks)

- (void)bk_each:(void (^)(id obj))block
{
    NSParameterAssert(block != nil);

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

- (void)bk_apply:(void (^)(id obj))block
{
    NSParameterAssert(block != nil);

    [self enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

- (nullable id)hb_match:(BOOL (^)(id))block
{
    NSUInteger index = [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }];
    if (index == NSNotFound) {
        return nil;
    }
    return self[index];
}



@end