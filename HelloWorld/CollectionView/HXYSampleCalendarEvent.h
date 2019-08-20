//
// Created by zhangfeng on 2019-08-20.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXYCalendarEvent.h"


@interface HXYSampleCalendarEvent : NSObject <HXYCalendarEvent>

+ (instancetype)randomEvent;

+ (instancetype)eventWithTitle:(NSString *)title day:(NSUInteger)day startHour:(NSUInteger)startHour durationInHours:(NSUInteger)durationInHours;


@end