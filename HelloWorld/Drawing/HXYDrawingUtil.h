//
//  HXYDrawingUtil.h
//  HelloWorld
//
//  Created by zhangfeng on 2019/7/17.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import <UIKit/UIKit.h>

CGRect RectMakeRect(CGPoint origin, CGSize size);
CGPoint RectGetCenter(CGRect rect);
CGRect RectAroundCenter(CGPoint center, CGSize size);
CGRect RectCenteredInRect(CGRect rect, CGRect mainRect);
CGSize SizeScaleByFactor(CGSize aSize, CGFloat factor);
CGFloat AspectScaleFit(CGSize sourceSize, CGRect destRect);
CGFloat AspectScaleFill(CGSize sourceSize, CGRect destRect);
UIImage *ExtractRectFromImage(UIImage *sourceImage, CGRect subRect);

NSData *BytesFromRGBImage(UIImage *sourceImage);
UIImage *ImageFromBytes(NSData *data, CGSize targetSize);

UIEdgeInsets BuildInsets(CGRect alignmentRect, CGRect imageBounds);

@interface HXYDrawingUtil : NSObject

+ (UIImage *)drawImageWithSize:(CGSize)size drawBlock:(void (^)(CGContextRef context, CGSize size))drawBlock;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)thumbnailImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize useFitting:(BOOL)useFitting;
+ (UIImage *)grayscaleVersionOfImage:(UIImage *)sourceImage;

@end
