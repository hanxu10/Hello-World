//
// Created by xuxune on 2019-08-11.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>

@interface NSArray<ObjectType> (HXYBlocks)

- (void)hb_each:(void (^)(ObjectType obj))block;
- (void)hb_apply:(void (^)(ObjectType obj))block;
- (nullable id)hb_match:(BOOL (^)(ObjectType obj))block;
- (NSArray *)hb_select:(BOOL (^)(ObjectType obj))block;
- (NSArray *)hb_reject:(BOOL (^)(ObjectType obj))block;
- (NSArray *)hb_map:(id (^)(ObjectType obj))block;
- (NSArray *)hb_compact:(id (^)(ObjectType obj))block;
- (nullable id)hb_reduce:(nullable id)initial withBlock:(__nullable id (^)(__nullable id sum, ObjectType obj))block;
- (NSInteger)hb_reduceInteger:(NSInteger)initial withBlock:(NSInteger(^)(NSInteger result, ObjectType obj))block;
- (CGFloat)hb_reduceFloat:(CGFloat)inital withBlock:(CGFloat(^)(CGFloat result, ObjectType obj))block;
- (BOOL)hb_any:(BOOL (^)(ObjectType obj))block;
- (BOOL)hb_none:(BOOL (^)(ObjectType obj))block;
- (BOOL)hb_all:(BOOL (^)(ObjectType obj))block;
- (BOOL)hb_corresponds:(NSArray *)list withBlock:(BOOL (^)(ObjectType obj1, id obj2))block;

@end