//
//  User.h
//  HelloWorld
//
//  Created by zhangfeng on 2019/8/13.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    SexMale,
    SexFemale
} Sex;

@interface User : NSObject
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *icon;
@property (assign, nonatomic) unsigned int age;
@property (copy, nonatomic) NSString *height;
@property (strong, nonatomic) NSNumber *money;
@property (assign, nonatomic) Sex sex;
@property (assign, nonatomic, getter=isGay) BOOL gay;
@end

NS_ASSUME_NONNULL_END
