#import "XXDragDropView.h"

@implementation XXDragDropView

- (void)awakeFromNib {
    [super awakeFromNib];
    // The type of data that is monitored by the registered view drag event type
    // 注册view拖动事件所监听的数据类型为'文件'类型
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

#pragma mark - 当文件拖入到view中
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    // 过滤掉非法的数据类型 <-> Filter out illegal data types
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

#pragma mark - 拖入文件后松开鼠标
- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    // Extract the required NSFilenamesPboardType data from the clipboard
    // 从粘贴板中提取需要的NSFilenamesPboardType数据
    NSArray *filePathList = [pboard propertyListForType:NSFilenamesPboardType];
    
    // 将文件数路径组通过代理回调出去
    if(_delegate && [_delegate respondsToSelector:@selector(dragDropFilePathList:)]) {
        [_delegate dragDropFilePathList:filePathList];
    }
    
    return YES;
}

@end
