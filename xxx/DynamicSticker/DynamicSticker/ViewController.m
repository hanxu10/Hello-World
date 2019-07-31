//
//  ViewController.m
//  DynamicSticker
//
//  Created by xuxune on 2019/7/31.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "ViewController.h"
#import <BlocksKit/BlocksKit.h>

@interface ViewController () <XXDragDropViewDelegate>

@end

@implementation ViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.dragDropView.delegate = self;

}

- (void)viewDidLoad {
    [super viewDidLoad];

}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)dragDropFilePathList:(NSArray<NSString *> *)filePathList {
    
    NSArray<NSImage *> *images = [filePathList bk_map:^id(NSString *filePath) {
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:filePath];
        return image;
    }];
    

}

@end
