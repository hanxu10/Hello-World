//
//  HXYDrawViewController.m
//  HelloWorld
//
//  Created by zhangfeng on 2019/8/19.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "HXYDrawViewController.h"
#import "HXYDrawingUtil.h"
#import "UIBezierPath+HXYHandyUtilities.h"

@interface HXYDrawViewController ()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation HXYDrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    [self test];
}

- (void)test {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 300, 300)];
    [self.view addSubview:imageView];
    
    {
        UIImage *image = [HXYDrawingUtil drawImageWithSize:CGSizeMake(300, 300) drawBlock:^(CGContextRef context, CGSize size) {
            CGRect rect = CGRectMake(0, 0, 300, 300);
            //        UIBezierPath *shape1 = [UIBezierPath bezierPathWithOvalInRect:rect];
            //        rect.origin.x += 100;
            UIBezierPath *shape2 = [UIBezierPath bezierPathWithOvalInRect:rect];
            shape2.lineWidth = 5;
            
            // Then draw green
            [[[UIColor greenColor] colorWithAlphaComponent:0.5] set];
            [shape2 fill];
            
            CGContextFillRect(context, rect);
            // First draw purple
            [[UIColor purpleColor] set];
            [shape2 stroke];
        }];
    }
    
    {
        UIImage *alphaImage1 = [HXYDrawingUtil drawImageWithSize:CGSizeMake(300, 300) drawBlock:^(CGContextRef context, CGSize size) {
            NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            CGPoint center = CGPointMake(150, 150);
            CGFloat r = 50;
            UIFont *font = [UIFont systemFontOfSize:14];
            for(int i = 0; i < 26; i++) {
                NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
                CGSize letterSize = [letter sizeWithAttributes:@{NSFontAttributeName:font}];
                CGFloat theta = M_PI - i * (2 * M_PI / 26.0);
                CGFloat x = center.x + r * sin(theta) - letterSize.width / 2.0;
                CGFloat y = center.y + r * cos(theta) - letterSize.height / 2.0;
                [letter drawAtPoint:CGPointMake(x, y) withAttributes:@{NSFontAttributeName:font}];
            }
        }];
    }
    
    {
        UIImage *alphaImage2 = [HXYDrawingUtil drawImageWithSize:CGSizeMake(300, 300) drawBlock:^(CGContextRef context, CGSize size) {
            NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            CGPoint center = CGPointMake(150, 150);
            CGFloat r = 50;
            UIFont *font = [UIFont systemFontOfSize:14];
            
            //从调整原点开始
            CGContextTranslateCTM(context, center.x, center.y);
            
            for(int i = 0; i < 26; i++) {
                NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
                CGSize letterSize = [letter sizeWithAttributes:@{NSFontAttributeName:font}];
                CGFloat theta = i * (2 * M_PI / 26.0);
                
                CGContextSaveGState(context);
                
                CGContextRotateCTM(context, theta);
                //平移到半径的边缘，向左移动一半的字母宽度。高度平移是负的，因为这个绘图序列使用UIKit坐标系。向上移动到更低的y值。
                CGContextTranslateCTM(context, -letterSize.width / 2.0, -r);
                [letter drawAtPoint:CGPointMake(0, 0) withAttributes:@{NSFontAttributeName:font}];
                
                CGContextRestoreGState(context);
            }
        }];
    }
    
    {
        UIImage *alphaImage3 = [HXYDrawingUtil drawImageWithSize:CGSizeMake(300, 300) drawBlock:^(CGContextRef context, CGSize size) {
            NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            CGPoint center = CGPointMake(150, 150);
            CGFloat r = 50;
            UIFont *font = [UIFont systemFontOfSize:14];
            
            //从调整原点开始
            CGContextTranslateCTM(context, center.x, center.y);
            
            
            // Calculate the full extent
            CGFloat fullSize = 0;
            for (int i = 0; i < 26; i++) {
                NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
                CGSize letterSize = [letter sizeWithAttributes:@{NSFontAttributeName:font}];
                fullSize += letterSize.width;
            }
            // Initialize the consumed space
            CGFloat consumedSize = 0.0f;
            // Iterate through each letter, consuming that width
            for (int i = 0; i < 26; i++) {
                // Measure each letter
                NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
                CGSize letterSize = [letter sizeWithAttributes:@{NSFontAttributeName:font}];
                // Move the pointer forward, calculating the
                // new percentage of travel along the path
                consumedSize += letterSize.width / 2.0f;
                CGFloat percent = consumedSize / fullSize;
                CGFloat theta = percent * 2 * M_PI;
                consumedSize += letterSize.width / 2.0f;
                
                // Prepare to draw the letter by saving the state
                CGContextSaveGState(context);
                // Rotate the context by the calculated angle
                CGContextRotateCTM(context, theta);
                // Move to the letter position
                CGContextTranslateCTM(context, -letterSize.width / 2, -r);
                // Draw the letter
                [letter drawAtPoint:CGPointMake(0, 0) withFont:font];
                // Reset the context back to the way it was
                CGContextRestoreGState(context);
            }
        }];
    }
    
    {
        UIImage *cgrectDivide = [HXYDrawingUtil drawImageWithSize:CGSizeMake(300, 300) drawBlock:^(CGContextRef context, CGSize size) {
            CGRect rect = CGRectMake(0, 0, 300, 300);
            
            UIBezierPath *path;
            CGRect remainder;
            CGRect slice;
            
            //从左边切下一片，涂成橙色
            CGRectDivide(rect, &slice, &remainder, 80, CGRectMinXEdge);
            [[UIColor orangeColor] set];
            path = [UIBezierPath bezierPathWithRect:slice];
            [path fill];
            
            //将另一部分水平切成两半
            rect = remainder;
            CGRectDivide(rect, &slice, &remainder, remainder.size.height * 0.5, CGRectMinYEdge);
            
            //将切片部分涂成紫色
            [[UIColor purpleColor] set];
            path = [UIBezierPath bezierPathWithRect:slice];
            [path fill];
            
            //从左下角切出20个点。
            //用灰色画
            rect = remainder;
            CGRectDivide(rect, &slice, &remainder, 20, CGRectMinXEdge);
            [[UIColor grayColor] set];
            path = [UIBezierPath bezierPathWithRect:slice];
            [path fill];
            
            //再从右边切20
            rect = remainder;
            CGRectDivide(rect, &slice, &remainder, 20, CGRectMaxXEdge);
            // Use same color on the right
            path = [UIBezierPath bezierPathWithRect:slice]; [path fill];
            
            // Fill the rest in brown
            [[UIColor brownColor] set];
            path = [UIBezierPath bezierPathWithRect:remainder];
            [path fill];
        }];
    }
    
    {
        CGRect rect = CGRectMake(0, 0, 300, 300);
        UIImage *centerAStringImage = [HXYDrawingUtil drawImageWithSize:rect.size drawBlock:^(CGContextRef context, CGSize size) {
            
            NSString *string = @"Hello World";
            UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:48];
            
            CGSize stringSize = [string sizeWithAttributes:@{NSFontAttributeName : font}];
            CGRect target = RectAroundCenter(RectGetCenter(rect), stringSize);
            
            [[UIColor redColor] set];
            
            CGContextStrokeRect(context, target);
            
            [[UIColor greenColor] set];
            CGRect smallRect = target;
            smallRect.size.width -= 0;
            [string drawInRect:smallRect withFont:font];
        }];
    }
    
    {
        UIImage *colorImage = [HXYDrawingUtil imageWithColor:[UIColor greenColor] size:CGSizeMake(100, 200)];
    }
    
    {
        CGRect rect = CGRectMake(0, 0, 300, 300);
        UIImage *waterimage = [UIImage imageNamed:@"water"];
        //    waterimage = [UIImage imageWithCGImage:waterimage.CGImage scale:[UIScreen mainScreen].scale orientation:waterimage.imageOrientation];
        UIImage *xx = [HXYDrawingUtil thumbnailImage:waterimage targetSize:CGSizeMake(200, 200) useFitting:YES];
        xx = ExtractRectFromImage(waterimage, CGRectMake(0, 0, 576, 300));
        xx = [HXYDrawingUtil grayscaleVersionOfImage:waterimage];
        
        rect = CGRectMake(0, 0, waterimage.size.width, waterimage.size.height);
        xx = [HXYDrawingUtil drawImageWithSize:rect.size drawBlock:^(CGContextRef context, CGSize xxsize) {
            CGRect targetRect = rect;
            UIImage *sourceImage = waterimage;
            CGRect imgRect = rect;
            [sourceImage drawInRect:imgRect];
            
            CGPoint center = RectGetCenter(targetRect);
            CGContextTranslateCTM(context, center.x, center.y);
            CGContextRotateCTM(context, M_PI_4 * 0.5);
            CGContextTranslateCTM(context, -center.x, -center.y);
            
            NSString *watermark = @"watermark";
            UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:48];
            CGSize size = [watermark sizeWithAttributes:@{NSFontAttributeName : font}];
            CGRect stringRect = RectCenteredInRect(RectMakeRect(CGPointZero, size), targetRect);
            
            stringRect.origin.x = 0;
            stringRect.origin.y = 0;
            
            CGContextSetBlendMode(context, kCGBlendModeDifference);
            [watermark drawInRect:stringRect withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:[UIColor whiteColor]}];
            CGContextStrokeRect(context, stringRect);
        }];
    }
    
    {
        UIImage *image = [HXYDrawingUtil drawImageWithSize:CGSizeMake(300, 300) drawBlock:^(CGContextRef context, CGSize size) {
            CGContextSaveGState(context);
            
            UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 100, 100)];
            CGContextAddPath(context, path.CGPath);
            CGContextClip(context);
            
            [[UIColor redColor] setFill];
            UIRectFill(CGRectMake(0, 0, 150, 150));
            
            CGContextRestoreGState(context);
            
            //
            CGContextSaveGState(context);
            UIBezierPath *path1 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(200, 200, 100, 100)];
            CGContextAddPath(context, path1.CGPath);
            CGContextClip(context);
            
            [[UIColor blueColor] setFill];
            UIRectFill(CGRectMake(200, 200, 50, 50));
            CGContextRestoreGState(context);
        }];
        NSLog(@"");
    }
    
    {
        UIImage *image = [HXYDrawingUtil drawImageWithSize:CGSizeMake(300, 300) drawBlock:^(CGContextRef context, CGSize size) {
            CGContextSaveGState(context);
            
            UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 100, 100)];
            CGContextAddPath(context, path.CGPath);
            UIBezierPath *path1 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(50, 50, 100, 100)];
            CGContextAddPath(context, path1.CGPath);
            CGContextClip(context);
            
            [[UIColor redColor] setFill];
            UIRectFill(CGRectMake(0, 0, 150, 150));
            
            CGContextRestoreGState(context);
        }];
        NSLog(@"");
    }
    
    {
        UIImage *image = [HXYDrawingUtil drawImageWithSize:CGSizeMake(300, 300) drawBlock:^(CGContextRef context, CGSize size) {
            CGContextSaveGState(context);
           
            UIBezierPath *boundsPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
            boundsPath.usesEvenOddFillRule = YES;
            
            UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(100, 100, 100, 100)];
            path.usesEvenOddFillRule = YES;
            
            CGContextAddPath(context, boundsPath.CGPath);
            CGContextAddPath(context, path.CGPath);
            
            [[UIColor redColor] setFill];
            CGContextEOFillPath(context);
            CGContextRestoreGState(context);
            
        }];
        NSLog(@"");
    }
    
    {
        UIImage *image = [HXYDrawingUtil drawImageWithSize:CGSizeMake(300, 300) drawBlock:^(CGContextRef context, CGSize size) {
            CGContextSaveGState(context);
            
//            UIBezierPath *boundsPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
//            boundsPath.usesEvenOddFillRule = YES;
            
            UIBezierPath *innerPath = [UIBezierPath bezierPathWithRect:CGRectMake(50, 50, 200, 200)];
            innerPath.usesEvenOddFillRule = YES;
            
            UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(100, 100, 100, 100)];
            path.usesEvenOddFillRule = YES;
            
//            CGContextAddPath(context, boundsPath.CGPath);
            CGContextAddPath(context, innerPath.CGPath);
            CGContextAddPath(context, path.CGPath);
            
            [[UIColor redColor] setFill];
            CGContextEOFillPath(context);
            CGContextRestoreGState(context);
        }];
        NSLog(@"");
    }

    UIImage *image = [UIImage imageNamed:@"big"];
    imageView.image = image;
    imageView.backgroundColor = [UIColor yellowColor];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = imageView.bounds;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:imageView.bounds];
    UIBezierPath *innerPath = [[UIBezierPath bezierPathWithRect:CGRectMake(10, 10, 100, 100)] bezierPathByReversingPath];
    [path appendPath:innerPath];
    
    shapeLayer.fillColor = [UIColor redColor].CGColor;
    shapeLayer.path = path.CGPath;
    imageView.layer.mask = shapeLayer;
    
    NSLog(@"");
    
    self.imageView = imageView;
    self.shapeLayer = shapeLayer;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.imageView.bounds];
    UIBezierPath *innerPath = [[UIBezierPath bezierPathWithRect:CGRectMake(50, 50, 100, 100)] bezierPathByReversingPath];
    [path appendPath:innerPath];
    
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    basicAnimation.duration          = 0.5;
    basicAnimation.fromValue         = (__bridge id)(self.shapeLayer.path);
    basicAnimation.toValue           = (__bridge id)path.CGPath;
    self.shapeLayer.path = path.CGPath;
    [self.shapeLayer addAnimation:basicAnimation forKey:@"lineShapeLayerPath"];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    self.shapeLayer.
}

@end
