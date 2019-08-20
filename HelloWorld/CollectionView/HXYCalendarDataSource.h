//
// Created by zhangfeng on 2019-08-20.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXYCalendarHeaderView;
@class HXYCalendarEventCell;
@protocol HXYCalendarEvent;

typedef void (^ConfigureCellBlock)(HXYCalendarEventCell *cell, NSIndexPath *indexPath, id<HXYCalendarEvent> event);
typedef void (^ConfigureHeaderViewBlock)(HXYCalendarHeaderView *headerView, NSString *kind, NSIndexPath *indexPath);

@interface HXYCalendarDataSource : NSObject <UICollectionViewDataSource>

@property (copy, nonatomic) ConfigureCellBlock configureCellBlock;
@property (copy, nonatomic) ConfigureHeaderViewBlock configureHeaderViewBlock;

- (id<HXYCalendarEvent>)eventAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)indexPathsOfEventsBetweenMinDayIndex:(NSInteger)minDayIndex maxDayIndex:(NSInteger)maxDayIndex minStartHour:(NSInteger)minStartHour maxStartHour:(NSInteger)maxStartHour;

@end