//
// Created by zhangfeng on 2019-08-20.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import "HXYCalendarCollectionViewViewController.h"
#import "HXYCalendarDataSource.h"
#import "HXYWeekCalendarLayout.h"
#import "HXYCalendarEventCell.h"
#import "HXYCalendarHeaderView.h"
#import "HXYCalendarEvent.h"
#import <Masonry/Masonry.h>

@interface HXYCalendarCollectionViewViewController ()

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) HXYCalendarDataSource *calendarDataSource;

@end

@implementation HXYCalendarCollectionViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    self.calendarDataSource = [[HXYCalendarDataSource alloc] init];
    self.calendarDataSource.configureCellBlock = ^(HXYCalendarEventCell *cell, NSIndexPath *indexPath, id<HXYCalendarEvent> event) {
        cell.titleLabel.text = event.title;
    };
    self.calendarDataSource.configureHeaderViewBlock = ^(HXYCalendarHeaderView *headerView, NSString *kind, NSIndexPath *indexPath) {
        if ([kind isEqualToString:@"DayHeaderView"]) {
            headerView.titleLabel.text = [NSString stringWithFormat:@"天 %d", (int) (indexPath.item + 1)];
        } else if ([kind isEqualToString:@"HourHeaderView"]) {
            headerView.titleLabel.text = [NSString stringWithFormat:@"%2d:00", (int) (indexPath.item + 1)];
        }
    };
    
    HXYWeekCalendarLayout *layout = [[HXYWeekCalendarLayout alloc] init];

    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self.calendarDataSource;
    [self.collectionView registerClass:[HXYCalendarEventCell class] forCellWithReuseIdentifier:@"CalendarEventCell"];
    [self.collectionView registerClass:[HXYCalendarHeaderView class] forSupplementaryViewOfKind:@"DayHeaderView" withReuseIdentifier:@"HeaderView"];
    [self.collectionView registerClass:[HXYCalendarHeaderView class] forSupplementaryViewOfKind:@"HourHeaderView" withReuseIdentifier:@"HeaderView"];

    [self.view addSubview:self.collectionView];
}

@end
