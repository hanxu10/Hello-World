//
// Created by zhangfeng on 2019-08-20.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import "HXYCalendarHeaderView.h"


@implementation HXYCalendarHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textColor = [UIColor redColor];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    bounds.size.height = 30;
    self.titleLabel.frame = bounds;
}

@end