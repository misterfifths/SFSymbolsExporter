#import "NSImage+AlignmentRectUtils.h"


@implementation NSImage (AlignmentRectUtils)

-(NSEdgeInsets)alignmentRectInsets
{
    NSRect rect = self.alignmentRect;
    return NSEdgeInsetsMake(self.size.height - NSMaxY(rect),
                            rect.origin.x,
                            rect.origin.y,
                            self.size.width - NSMaxX(rect));
}

@end
