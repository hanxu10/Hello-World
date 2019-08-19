//
//  UIBezierPath+HXYHandyUtilities.h
//  HelloWorld
//
//  Created by zhangfeng on 2019/8/19.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBezierPath (HXYHandyUtilities)

- (void)hxy_stroke:(CGFloat)width color:(UIColor *)color;

- (void)hxy_fill:(UIColor *)fillColor;

- (void)hxy_strokeInside:(CGFloat)width color:(UIColor *)color;
@end

NS_ASSUME_NONNULL_END
