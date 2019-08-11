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


@end
