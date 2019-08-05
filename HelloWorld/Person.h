//
//  Person.h
//  HelloWorld
//
//  Created by zhangfeng on 2019/8/5.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ProtocolXXX <NSObject>

@end

@protocol ProtocolYYY <NSObject>

@end


@interface Person : NSObject

@property (nonatomic, strong) id<ProtocolXXX, ProtocolYYY> pxy;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong) void (^doSomeThingBlock)(NSString *some);


@end

NS_ASSUME_NONNULL_END
