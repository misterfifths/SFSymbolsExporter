#import <Cocoa/Cocoa.h>


NS_ASSUME_NONNULL_BEGIN

@interface NSImage (BlockDrawing)

+(NSImage *)bitmapImageOfSize:(NSSize)size
              withScaleFactor:(CGFloat)scaleFactor
                      flipped:(BOOL)flipped
                    byDrawing:(void (^)(CGContextRef context))drawFunc;

@end


@interface NSData (PDFBlockDrawing)

+(NSData *)pdfDataForSinglePageOfSize:(NSSize)size
                              flipped:(BOOL)flipped
                            byDrawing:(void (^)(CGContextRef context))drawFunc;

@end

NS_ASSUME_NONNULL_END
