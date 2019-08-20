//
// Created by zhangfeng on 2019-08-20.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HXYCalendarEvent <NSObject>

@property(copy, nonatomic) NSString *title;
@property(assign, nonatomic) NSInteger day;
@property(assign, nonatomic) NSInteger startHour;
@property(assign, nonatomic) NSInteger durationInHours;

@end