//
//  ViewController.h
//  DynamicSticker
//
//  Created by xuxune on 2019/7/31.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XXDragDropView.h"

@interface ViewController : NSViewController

@property (weak) IBOutlet XXDragDropView *dragDropView;
@property (weak) IBOutlet NSImageView *staticImageView;
@property (weak) IBOutlet NSTextField *staticImageLabel;
@property (weak) IBOutlet NSImageView *frameOneImageView;
@property (weak) IBOutlet NSImageView *frameTwoImageView;
@property (weak) IBOutlet NSImageView *frameThreeImageView;
@property (weak) IBOutlet NSTextField *colCountTextField;
@property (weak) IBOutlet NSTextField *frameRateTextField;
@property (weak) IBOutlet NSTableView *tableView;


@end

