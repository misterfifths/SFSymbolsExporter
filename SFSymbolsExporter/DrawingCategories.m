#import "DrawingCategories.h"


@implementation NSImage (BlockDrawing)

+(NSImage *)bitmapImageOfSize:(NSSize)size
              withScaleFactor:(CGFloat)scaleFactor
                      flipped:(BOOL)flipped
                    byDrawing:(void (^)(CGContextRef context))drawFunc
{
    CGColorSpaceRef deviceRGBColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, size.width * scaleFactor, size.height * scaleFactor, 8, 0, deviceRGBColorSpace, kCGImageAlphaPremultipliedLast);

    if(flipped) {
        CGAffineTransform flipXform = CGAffineTransformMake(1, 0, 0, -1, 0, size.height * scaleFactor);
        CGContextConcatCTM(bitmapContext, flipXform);
    }

    CGContextScaleCTM(bitmapContext, scaleFactor, scaleFactor);

    CGContextSetShouldAntialias(bitmapContext, TRUE);

    drawFunc(bitmapContext);

    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);

    CGContextRelease(bitmapContext);
    CGColorSpaceRelease(deviceRGBColorSpace);

    NSImage *image = [[NSImage alloc] initWithCGImage:cgImage size:size];
    CGImageRelease(cgImage);

    return image;
}

@end


@implementation NSData (PDFBlockDrawing)

+(NSData *)pdfDataForSinglePageOfSize:(NSSize)size
                              flipped:(BOOL)flipped
                            byDrawing:(void (^)(CGContextRef context))drawFunc
{
    NSMutableData *data = [NSMutableData new];
    CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((__bridge CFMutableDataRef)data);

    CGRect pdfMediaBox = CGRectMake(0, 0, size.width, size.height);
    CGContextRef pdfContext = CGPDFContextCreate(consumer, &pdfMediaBox, nil);

    NSData *mediaBoxData = [NSData dataWithBytes:&pdfMediaBox length:sizeof(pdfMediaBox)];
    NSDictionary *pageInfo = @{ (NSString *)kCGPDFContextMediaBox: mediaBoxData };

    CGPDFContextBeginPage(pdfContext, (__bridge CFDictionaryRef)pageInfo);

    if(flipped) {
        CGAffineTransform flipXform = CGAffineTransformMake(1, 0, 0, -1, 0, size.height);
        CGContextConcatCTM(pdfContext, flipXform);
    }

    CGContextSetShouldAntialias(pdfContext, TRUE);

    drawFunc(pdfContext);

    CGPDFContextEndPage(pdfContext);
    CGPDFContextClose(pdfContext);

    CGContextRelease(pdfContext);
    CGDataConsumerRelease(consumer);

    return data;
}

@end
