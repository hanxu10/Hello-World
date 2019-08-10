//
//  Person.h
//  HelloWorld
//
//  Created by zhangfeng on 2019/8/5.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@protocol ProtocolXXX <NSObject>

@end

@protocol ProtocolYYY <NSObject>

@end


@interface Person : NSObject

@property (nonatomic, assign) CGRect pRect;
@property (nonatomic, strong) id<ProtocolXXX, ProtocolYYY> pxy;
@property (nonatomic, strong) NSArray<Person *> *children;
@property (nonatomic, strong) NSArray *stringArray;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *bookId;
@property (nonatomic, strong) Person *nextPerson;
@property (nonatomic, strong) void (^doSomeThingBlock)(NSString *some);

- (void)doit;

@end

NS_ASSUME_NONNULL_END
