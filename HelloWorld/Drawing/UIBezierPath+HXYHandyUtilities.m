//
//  UIBezierPath+HXYHandyUtilities.m
//  HelloWorld
//
//  Created by zhangfeng on 2019/8/19.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "UIBezierPath+HXYHandyUtilities.h"

@implementation UIBezierPath (HXYHandyUtilities)

- (void)hxy_stroke:(CGFloat)width color:(UIColor *)color {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) {
        NSLog(@"Error: No context to draw to");
        return;
    }
    CGContextSaveGState(context);

    // Set the color
    if (color) {
        [color setStroke];
    }

    // Store the width
    CGFloat holdWidth = self.lineWidth;
    self.lineWidth = width;
    // Draw
    [self stroke];
    // Restore the width
    self.lineWidth = holdWidth;
    CGContextRestoreGState(context);
}

- (void)hxy_fill:(UIColor *)fillColor {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) {
        NSLog(@"Error: No context to draw to");
        return;
    }
    CGContextSaveGState(context);
    [fillColor set];
    [self fill];
    CGContextRestoreGState(context);
}


- (void)hxy_strokeInside:(CGFloat)width color:(UIColor *)color {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) {
        NSLog(@"Error: No context to draw to");
        return;
    }
    CGContextSaveGState(context);
    [self addClip];
    [self hxy_stroke:width * 2 color:color];
    CGContextRestoreGState(context);
}

@end
