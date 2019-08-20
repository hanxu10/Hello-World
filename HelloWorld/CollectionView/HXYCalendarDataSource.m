//
// Created by zhangfeng on 2019-08-20.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import <Bolts/BFAppLinkReturnToRefererController.h>
#import "HXYCalendarDataSource.h"
#import "HXYSampleCalendarEvent.h"
#import "HXYCalendarEventCell.h"
#import "HXYCalendarEventCell.h"
#import "HXYCalendarEvent.h"
#import "HXYCalendarHeaderView.h"


@interface HXYCalendarDataSource ()

@property (nonatomic, strong) NSMutableArray *events;

@end

@implementation HXYCalendarDataSource

- (instancetype)init {
    if (self = [super init]) {
        _events = [NSMutableArray array];
        [self generateSampleData];
    }
    return self;
}

- (void)generateSampleData {
    for (int i = 0; i < 20; ++i) {
        HXYSampleCalendarEvent *event = [HXYSampleCalendarEvent randomEvent];
        [self.events addObject:event];
    }
}

#pragma mark -

- (id<HXYCalendarEvent>)eventAtIndexPath:(NSIndexPath *)indexPath
{
    return self.events[indexPath.item];
}


- (NSArray *)indexPathsOfEventsBetweenMinDayIndex:(NSInteger)minDayIndex maxDayIndex:(NSInteger)maxDayIndex minStartHour:(NSInteger)minStartHour maxStartHour:(NSInteger)maxStartHour
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    [self.events enumerateObjectsUsingBlock:^(id event, NSUInteger idx, BOOL *stop) {
        if ([event day] >= minDayIndex && [event day] <= maxDayIndex && [event startHour] >= minStartHour && [event startHour] <= maxStartHour)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
            [indexPaths addObject:indexPath];
        }
    }];
    return indexPaths;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.events.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id<HXYCalendarEvent> event = self.events[indexPath.item];
    HXYCalendarEventCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CalendarEventCell" forIndexPath:indexPath];
    if (self.configureCellBlock) {
        self.configureCellBlock(cell, indexPath, event);
    }
    return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    HXYCalendarHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    if (self.configureHeaderViewBlock) {
        self.configureHeaderViewBlock(headerView, kind, indexPath);
    }
    return headerView;
}

@end