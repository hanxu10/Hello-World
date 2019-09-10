//
//  HXYSyntaxHighlightTextStorage.m
//  HelloWorld
//
//  Created by xuxune on 2019/8/11.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "HXYSyntaxHighlightTextStorage.h"

@interface HXYSyntaxHighlightTextStorage()

@property (nonatomic, strong) NSMutableAttributedString *backingStore;

@end

@implementation HXYSyntaxHighlightTextStorage

- (NSMutableAttributedString *)backingStore
{
    if (!_backingStore) {
        _backingStore = [[NSMutableAttributedString alloc] init];
    }
    return _backingStore;
}

- (NSString *)string
{
    return self.backingStore.string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [self.backingStore attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    NSLog(@"replaceCharactersInRange:%@ withString:%@", NSStringFromRange(range), str);
    [self beginEditing];
    [self.backingStore replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:(str.length - range.length)];
    [self endEditing];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    NSLog(@"setAttributes:%@ range:%@", attrs, NSStringFromRange(range));
    [self beginEditing];
    [self.backingStore setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    
    [self endEditing];
}

- (void)processEditing {
    [self applyStylesToToRange:NSMakeRange(0, self.backingStore.length - 1)];
    [super processEditing];
    
}

- (void)applyStylesToToRange:(NSRange)searchRange {
    
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\~\\w+(\\s*\\w+)*\\s*\\~)" options:0 error:NULL];
//    //去除当前段落的颜色属性
//    NSRange paragaphRange = [self.string paragraphRangeForRange:self.editedRange];
//    [self removeAttribute:NSForegroundColorAttributeName range:paragaphRange];
//    //根据正则匹配，添加新属性
//    [regex enumerateMatchesInString:self.string options:NSMatchingReportProgress range:paragaphRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
//        [self addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:result.range];
//    }];
    
    [self setAttributes:@{NSBackgroundColorAttributeName : [UIColor redColor]} range:searchRange];
    
}

@end
