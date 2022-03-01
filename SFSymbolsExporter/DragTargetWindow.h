#import <Cocoa/Cocoa.h>


NS_ASSUME_NONNULL_BEGIN

// A window that accepts dragged symbols from the SF Symbols app.
// If its contentViewController implements the protocol below,
// handleDragOfSymbols: will be called on it when symbols are dropped onto the
// window.
@interface DragTargetWindow : NSWindow <NSDraggingDestination>

@end


// To be implemented by the contentViewController of a DragTargetWindow
@protocol SFSymbolsDragTarget <NSObject>

-(void)handleDragOfSymbols:(NSDictionary<NSString *, NSString *> *)symbolsByName;

@end

NS_ASSUME_NONNULL_END
