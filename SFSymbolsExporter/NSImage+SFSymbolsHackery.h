#import <Cocoa/Cocoa.h>


NS_ASSUME_NONNULL_BEGIN

@protocol VectorGlyph <NSObject>

// These are the things we really care about:

// This is different than the alignmentRect of the image and seems to be the
// alignmentRect of the path itself. Presently we only do anything with its
// origin, but we should probably interpret its size as well.
-(CGRect)alignmentRect;

// This is the path at default scale, seemingly so that it aligns with
// alignmentRect. The CGPath property is scaled differently.
-(CGPathRef)_referencePathForTemplateMode;


// These are potentially useful but not used in the export process right now:

//-(CGFloat)referencePointSize;
//-(CGSize)referenceCanvasSize;
//-(CGFloat)baselineOffset;
//-(CGFloat)capHeight;
//-(CGPathRef)CGPath;
//-(CGRect)contentBounds;
//-(void)drawInContext:(CGContextRef)context;
//-(CGImageRef)NS_templateCGImageWithPixelSize:(CGSize)size;

// -glyphWeight
// -glyphSize
// _interpolatedCanvasSizeWithWeight:glyphSize:fromUltralight:regular:black:
// _interpolatedAlignmentRectInsetsWithWeight:glyphSize:fromUltralight:regular:black:

@end


@interface NSImage (SFSymbolsHackery)

@property (nonatomic, readonly) BOOL isSymbol;
@property (nonatomic, readonly, nullable) NSObject<VectorGlyph> *vectorGlyph;

@end

NS_ASSUME_NONNULL_END
