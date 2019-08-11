//
// Created by xuxune on 2019-08-11.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import "HXYTextKitViewController.h"
#import "HXYSyntaxHighlightTextStorage.h"

@implementation HXYTextKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //NSTextStorage 添加了 NSLayoutManager， NSLayoutManager 添加了 NSTextContainer
    [self test2];
    
    
    
}

- (void)test2
{
    NSTextContainer * container1 = [[NSTextContainer alloc] initWithSize:CGSizeMake(150, 150)];
    NSLayoutManager * layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:container1];
    
    NSAttributedString *attrs = [[NSAttributedString alloc] initWithString:@"时代峰峻流口水耳机" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]}];
    HXYSyntaxHighlightTextStorage *textStorage = [[HXYSyntaxHighlightTextStorage alloc] init];
    [textStorage appendAttributedString:attrs];
    [textStorage addLayoutManager:layoutManager];
    
    container1.widthTracksTextView = YES;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds textContainer:container1];
    textView.delegate = self;
    [self.view addSubview:textView];
    
    
}


- (void)test1
{
    //定义Container
    NSTextContainer * container1 = [[NSTextContainer alloc] initWithSize:CGSizeMake(150, 150)];
    NSTextContainer * container2 = [[NSTextContainer alloc] initWithSize:CGSizeMake(100, 100)];
    
    
    //定义布局管理类
    NSLayoutManager * layoutManager = [[NSLayoutManager alloc] init];
    //    layoutManager.showsInvisibleCharacters = YES;
    layoutManager.showsControlCharacters = YES;
    //将container添加进布局管理类管理
    [layoutManager addTextContainer:container1];
    [layoutManager addTextContainer:container2];
    
    //定义一个Storage
    NSTextStorage * storage = [[NSTextStorage alloc] initWithString:@"The\nNSTextContainer class defines a region where text is laid out. An NSLayoutManager uses NSTextContainer to determine where to break lines, lay out portions of text, and so on. 顾名思义，NSLayoutManager专门负责对文本的布局渲染，简单理解，其从NSTextStorage从拿去展示的内容，将去处理后布局到NSTextContainer中。"];
    //为Storage添加一个布局管理器
    [storage addLayoutManager:layoutManager];
    
    //将要显示的container与视图TextView绑定
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, 200);
    {
        UITextView * textView = [[UITextView alloc]initWithFrame:frame textContainer:container1];
        [self.view addSubview:textView];
    }
    {
        frame.origin.y = 200;
        UITextView * textView = [[UITextView alloc]initWithFrame:frame textContainer:container2];
        [self.view addSubview:textView];
    }
}

@end
