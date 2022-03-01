#import <Cocoa/Cocoa.h>
#import "DragTargetWindow.h"


NS_ASSUME_NONNULL_BEGIN

@interface ViewController : NSViewController <SFSymbolsDragTarget>

-(void)handleDragOfSymbols:(NSDictionary<NSString *, NSString *> *)symbolsByName;

@end

NS_ASSUME_NONNULL_END
