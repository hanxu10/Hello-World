//
// Created by xuxune on 2019-08-08.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HXYModel <NSObject>
@optional

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper;
+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass;
+ (Class)modelCustomClassForDictionary:(NSDictionary *)dictionary;
+ (NSArray<NSString *> *)modelPropertyWhiteList;
- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic;
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic;

@end




@interface NSObject(HXYModel)


@end