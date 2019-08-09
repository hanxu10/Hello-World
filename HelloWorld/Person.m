//
//  Person.m
//  HelloWorld
//
//  Created by zhangfeng on 2019/8/5.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>

void doitFunc(id self, SEL _cmd)
{
    NSLog(@"动态实现doit");
}


@interface CanDoit : NSObject
- (void)doit;
@end

@implementation CanDoit
- (void)doit {
    NSLog(@"你不能do我来do");
}
@end


@implementation Person

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(doit)) {
//        class_addMethod(self.class, sel, doitFunc, "v@:");
        return NO;
    }
    
    return [super resolveInstanceMethod:sel];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if (aSelector == @selector(doit)) {
//        return [[CanDoit alloc] init];
        return nil;
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    id target = anInvocation.target;
    SEL sel = anInvocation.selector;
    NSString *xx = NSStringFromSelector(sel);
    [anInvocation getReturnValue:nil];
    NSLog(@"");
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if (aSelector == @selector(doit)) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }
    return [super methodSignatureForSelector:aSelector];
}


- (void)doesNotRecognizeSelector:(SEL)aSelector {
    
}

@end
