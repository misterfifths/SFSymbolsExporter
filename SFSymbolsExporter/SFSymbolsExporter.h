#import <Cocoa/Cocoa.h>


NS_ASSUME_NONNULL_BEGIN

@interface SFSymbolsExporter : NSObject

// Creates a .imageset subdirectory in the provided directory for a vector
// version of the given symbol name.
// Setting isTemplate will cause the fillColor to be ignored; template images
// must be rendered in black.
// By default, the alignmentRectInsets of the symbol are saved in the imageset;
// set includeInsets to false to leave them out.
+(BOOL)writeImageSetForSymbolNamed:(NSString *)symbolName
                       inDirectory:(NSURL *)directoryURL
                          template:(BOOL)isTemplate
                         fillColor:(NSColor * _Nullable)fillColor
            includeAlignmentInsets:(BOOL)includeInsets
                             error:(NSError **)error;

// Returns the data for a single-page PDF containing a vector version of the
// given symbol name in the given color. The alignmentRectInsets of the result
// are returned via the out parameter.
+(NSData *)pdfDataForReferenceSymbolNamed:(NSString *)symbolName
                                fillColor:(NSColor *)fillColor
                      alignmentRectInsets:(NSEdgeInsets *)outInsets;

// Creates a bitmap template image by rendering the given symbol name at its
// native size.
+(NSImage *)bitmapTemplateImageForReferenceSymbolNamed:(NSString *)symbolName;

// Creates a template image of the given symbol name suitable for rendering at
// any size.
+(NSImage *)scalableTemplateImageForReferenceSymbolNamed:(NSString *)symbolName;

// Renders the given symbol image by filling its path at the origin of the given
// conext. Retrieve an appropriate image with
// +[NSImage imageWithSystemSymbolName:accessibilityDescription:].
+(BOOL)renderReferenceSymbolImage:(NSImage *)symbolImage
                asVectorInContext:(CGContextRef)context
                        fillColor:(NSColor *)fillColor;


+(instancetype)new NS_UNAVAILABLE;
-(instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
