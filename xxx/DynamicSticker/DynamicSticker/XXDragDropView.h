#import <Cocoa/Cocoa.h>
#import "XXProtocol.h"

@interface XXDragDropView : NSView

@property (nonatomic, weak) id<XXDragDropViewDelegate> delegate;

@end
