//
//  XXWindowController.m
//  DynamicSticker
//
//  Created by xuxune on 2019/7/31.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "XXWindowController.h"

@interface XXWindowController ()

@end

@implementation XXWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // 设置titlebar为透明 <-> Set titlebar as transparent
    self.window.titlebarAppearsTransparent = YES;
    // 隐藏title
    self.window.titleVisibility = NSWindowTitleHidden;
    // 隐藏最大化按钮
    [self.window standardWindowButton:NSWindowZoomButton].hidden = YES;
}

@end
