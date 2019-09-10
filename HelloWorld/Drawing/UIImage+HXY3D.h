//
//  UIImage+HXY3D.h
//  HelloWorld
//
//  Created by zhangfeng on 2019/9/9.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (HXY3D)
+ (UIImage *)create3DImageWithText:(NSString *)_text
                              Font:(UIFont*)_font
                   ForegroundColor:(UIColor*)_foregroundColor
                       ShadowColor:(UIColor*)_shadowColor
                      outlineColor:(UIColor*)_outlineColor
                             depth:(int)_depth
                          useShine:(BOOL)_shine;
@end

NS_ASSUME_NONNULL_END
