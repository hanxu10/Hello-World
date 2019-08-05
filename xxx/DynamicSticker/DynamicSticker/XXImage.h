//
//  XXImage.h
//  DynamicSticker
//
//  Created by zhangfeng on 2019/7/31.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <CoreImage/CoreImage.h>
#import "InfoModel.h"

@interface XXImage : NSImage

#pragma mark - NSView 转 NSImage
+ (NSImage *)imageFromView:(NSView *)cview;

+ (XXImage *)imageWithNSView:(NSView *)cview;

#pragma mark - 保存图片到本地
// filename必须为绝对路径
+ (BOOL)saveImage:(NSImage *)image fileName:(NSString *)fileName;

#pragma mark - 将图片按照比例压缩(修改图片的占用空间)
//rate 压缩比0.1～1.0之间
+ (NSData *)compressedImageDataWithImg:(NSImage *)img rate:(CGFloat)rate;

#pragma mark - 修改图片尺寸
+ (NSImage *)resizeImage:(NSImage*)sourceImage forSize:(NSSize)size;
+ (NSImage*)resizeImage1:(NSImage*)sourceImage forSize:(NSSize)targetSize;

#pragma mark - 将图片压缩到指定大小（KB）
+ (NSData *)compressImgData:(NSData *)imgData toAimKB:(NSInteger)aimKB;

#pragma mark - 组合图片
+ (NSImage *)jointedImageWithImages:(NSArray *)imgArray colCount:(NSInteger)colCount shape:(ShapesJson **)retShape;

#pragma mark -  NSImage转CIImage
+ (CIImage *)getCIImageWithNSImage:(NSImage *)myImage;

@end

