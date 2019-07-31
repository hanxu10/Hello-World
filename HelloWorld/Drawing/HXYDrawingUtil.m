//
//  HXYDrawingUtil.m
//  HelloWorld
//
//  Created by zhangfeng on 2019/7/17.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "HXYDrawingUtil.h"

#pragma mark -

UIEdgeInsets BuildInsets(CGRect alignmentRect, CGRect imageBounds) {
    CGRect targetRect = CGRectIntersection(alignmentRect, imageBounds);
    
    UIEdgeInsets insets;
    insets.left = CGRectGetMinX(targetRect) - CGRectGetMinX(imageBounds);
    insets.right = CGRectGetMaxX(imageBounds) - CGRectGetMaxX(targetRect);
    insets.top = CGRectGetMinY(targetRect) - CGRectGetMinY(imageBounds);
    insets.bottom = CGRectGetMaxY(imageBounds) - CGRectGetMaxY(targetRect);
    
    return insets;
}

NSData *BytesFromRGBImage(UIImage *sourceImage) {
    if (!sourceImage) {
        return nil;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        return nil;
    }
    
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    
    CGRect rect = (CGRect){.size = sourceImage.size};
    CGContextDrawImage(context, rect, sourceImage.CGImage);
    
    NSData *data = [NSData dataWithBytes:CGBitmapContextGetData(context) length:width * height * 4];
    CGContextRelease(context);
    return data;
}

UIImage *ImageFromBytes(NSData *data, CGSize targetSize) {
    int width = targetSize.width;
    int height = targetSize.height;
    
    if (data.length < width * height * 4) {
        return nil;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        return nil;
    }
    
    Byte *bytes = (Byte *)data.bytes;
    CGContextRef context = CGBitmapContextCreate(bytes, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(context);
    CFRelease(imageRef);
    
    return image;
}

CGRect RectByFillingRect(CGRect sourceRect, CGRect destinationRect) {
    CGFloat aspect = AspectScaleFill(sourceRect.size, destinationRect);
    CGSize targetSize = SizeScaleByFactor(sourceRect.size, aspect);
    return RectAroundCenter(RectGetCenter(destinationRect), targetSize);
}

CGRect RectByFittingInRect(CGRect sourceRect, CGRect destinationRect) {
    CGFloat aspect = AspectScaleFit(sourceRect.size, destinationRect);
    CGSize targetSize = SizeScaleByFactor(sourceRect.size, aspect);
    return RectAroundCenter(RectGetCenter(destinationRect), targetSize);
}

CGSize SizeScaleByFactor(CGSize aSize, CGFloat factor) {
    return CGSizeMake(aSize.width * factor, aSize.height * factor);
}

CGFloat AspectScaleFit(CGSize sourceSize, CGRect destRect) {
    CGSize destSize = destRect.size;
    CGFloat scaleW = destSize.width / sourceSize.width;
    CGFloat scaleH = destSize.height / sourceSize.height;
    return MIN(scaleW, scaleH);
}

CGFloat AspectScaleFill(CGSize sourceSize, CGRect destRect) {
    CGSize destSize = destRect.size;
    CGFloat scaleW = destSize.width / sourceSize.width;
    CGFloat scaleH = destSize.height / sourceSize.height;
    return MAX(scaleW, scaleH);
}

CGRect RectMakeRect(CGPoint origin, CGSize size) {
    return (CGRect){.origin = origin, .size = size};
}

CGPoint RectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CGRect RectAroundCenter(CGPoint center, CGSize size) {
    CGFloat halfWidth = size.width / 2.0f;
    CGFloat halfHeight = size.height / 2.0f;
    return CGRectMake(center.x - halfWidth, center.y - halfHeight, size.width, size.height);
}

CGRect RectCenteredInRect(CGRect rect, CGRect mainRect) {
    CGFloat dx = CGRectGetMidX(mainRect) - CGRectGetMidX(rect);
    CGFloat dy = CGRectGetMidY(mainRect) - CGRectGetMidY(rect);
    return CGRectOffset(rect, dx, dy);
}

#pragma mark -

void FilpContextVertically(CGSize size) {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) {
        NSLog(@"Erro: NO context to filp");
        return;
    }
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
    transform = CGAffineTransformTranslate(transform, 0.0, -size.height);
    CGContextConcatCTM(context, transform);
}

void FlipImageContextVertically() {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) {
        NSLog(@"Error: NO context to flip");
        return;
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    FilpContextVertically(image.size);
}

CGSize GetUIKitContextSize()
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) {
        return CGSizeZero;
    }
    
    CGSize size = CGSizeMake(CGBitmapContextGetWidth(context),CGBitmapContextGetHeight(context));
    CGFloat scale = [UIScreen mainScreen].scale;
    return CGSizeMake(size.width / scale, size.height / scale);
}

UIImage *ExtractRectFromImage(UIImage *sourceImage, CGRect subRect) {
    // Extract image
    CGImageRef imageRef = CGImageCreateWithImageInRect(sourceImage.CGImage, subRect);
    if (imageRef != NULL) {
        UIImage *output = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        return output;
    }
    NSLog(@"Error: Unable to extract subimage");
    return nil;
}
// This is a little less flaky
// when moving to and from Retina images
UIImage *ExtractSubimageFromRect(UIImage *sourceImage, CGRect rect) {
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1);
    CGRect destRect = CGRectMake(-rect.origin.x, -rect.origin.y,sourceImage.size.width, sourceImage.size.height);
    [sourceImage drawInRect:destRect];
    UIImage *newImage =
    UIGraphicsGetImageFromCurrentImageContext(); UIGraphicsEndImageContext();
    return newImage;
}

@implementation HXYDrawingUtil

+ (UIImage *)drawImageWithSize:(CGSize)size drawBlock:(void (^)(CGContextRef context, CGSize size))drawBlock {
    //1-4
    //创建color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        NSLog(@"Error allocating color space");
        return nil;
    }
    
    //创建bitmap context
    CGFloat width = size.width;
    CGFloat height = size.height;
    NSInteger BIT_PER_COMPONENT = 8;
    NSInteger ARGB_COUNT = 4;
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 width,
                                                 height,
                                                 BIT_PER_COMPONENT, // bit = 8 per component
                                                 width * ARGB_COUNT,// 4bytes for ARGB
                                                 colorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaPremultipliedFirst
                                                 );
    if (context == NULL) {
        NSLog(@"Error: Context not created!");
        CGColorSpaceRelease(colorSpace);
        return nil;
    }
    
    // Push the context.这是可选的
    UIGraphicsPushContext(context);
    // 执行绘制操作
    
    FilpContextVertically(CGSizeMake(width, height));
    
    if (drawBlock) {
        drawBlock(context, size);
    }
    
    UIGraphicsPopContext();
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    //
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    [color setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)thumbnailImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize useFitting:(BOOL)useFitting {
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = RectMakeRect(CGPointZero, targetSize);
    
    CGRect naturalRect = RectMakeRect(CGPointZero, sourceImage.size);
    
    CGRect destinationRect = useFitting ? RectByFittingInRect(naturalRect, targetRect) : RectByFillingRect(naturalRect, targetRect);
    
    [sourceImage drawInRect:destinationRect];
    
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return thumbnail;
}

+ (UIImage *)grayscaleVersionOfImage:(UIImage *)sourceImage {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, width, colorSpace, kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    CGRect rect = RectMakeRect(CGPointZero, sourceImage.size);
    CGContextDrawImage(context, rect, sourceImage.CGImage);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *output = [UIImage imageWithCGImage:imageRef];
    CFRelease(imageRef);
    return output;
}

@end
