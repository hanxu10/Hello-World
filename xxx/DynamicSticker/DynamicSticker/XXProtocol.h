#ifndef XXProtocol_h
#define XXProtocol_h

#import <Foundation/Foundation.h>

#pragma mark - XXDragDropViewDelegate

@protocol XXDragDropViewDelegate <NSObject>

- (void)dragDropFilePathList:(NSArray<NSString *> *)filePathList;

@end

#endif
