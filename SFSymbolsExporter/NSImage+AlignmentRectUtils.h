#import <Cocoa/Cocoa.h>


NS_ASSUME_NONNULL_BEGIN

@interface NSImage (AlignmentRectUtils)

// Translates alignmentRect to its insets representation
@property (nonatomic, readonly) NSEdgeInsets alignmentRectInsets;

@end

NS_ASSUME_NONNULL_END
