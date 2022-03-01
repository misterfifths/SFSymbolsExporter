#import "SFSymbolsExporter.h"
#import "NSImage+SFSymbolsHackery.h"
#import "NSImage+AlignmentRectUtils.h"
#import "DrawingCategories.h"


@implementation SFSymbolsExporter

+(BOOL)renderReferenceSymbolImage:(NSImage *)symbolImage
                asVectorInContext:(CGContextRef)context
                        fillColor:(NSColor *)fillColor
{
    id<VectorGlyph> vectorGlyph = symbolImage.vectorGlyph;
    if(!vectorGlyph) {
        NSLog(@"%@ doesn't seem to have a vectorGlyph! Yikes!", symbolImage);
        return NO;
    }

    CGPathRef path = [vectorGlyph _referencePathForTemplateMode];
    if(!path) {
        NSLog(@"vectorGlyph %@ returned a nil reference path!", [vectorGlyph debugDescription]);
        return NO;
    }

    // The vector glyph has a different alignment rect than the overall image,
    // and it's what we should use to determine the origin of the path.
    NSRect glyphAlignmentRect = [vectorGlyph alignmentRect];

    CGAffineTransform xform = CGAffineTransformMakeTranslation(glyphAlignmentRect.origin.x, glyphAlignmentRect.origin.y);
    CGPathRef shiftedPath = CGPathCreateCopyByTransformingPath(path, &xform);

    CGContextAddPath(context, shiftedPath);
    CGPathRelease(shiftedPath);

    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextFillPath(context);

    return YES;
}

+(NSImage *)bitmapTemplateImageForReferenceSymbolNamed:(NSString *)symbolName
{
    NSImage *referenceSymbolImage = [NSImage imageWithSystemSymbolName:symbolName accessibilityDescription:nil];

    id<VectorGlyph> vectorGlyph = referenceSymbolImage.vectorGlyph;
    NSLog(@"vectorGlyph: %@", [vectorGlyph debugDescription]);

    NSImage *image = [NSImage bitmapImageOfSize:referenceSymbolImage.size
                                withScaleFactor:2.0
                                        flipped:YES
                                      byDrawing:^(CGContextRef context)
    {
        [self renderReferenceSymbolImage:referenceSymbolImage
                       asVectorInContext:context
                               fillColor:NSColor.blackColor];
    }];

    image.template = YES;
    image.alignmentRect = referenceSymbolImage.alignmentRect;

    return image;
}

+(NSImage *)scalableTemplateImageForReferenceSymbolNamed:(NSString *)symbolName
{
    NSImage *referenceSymbolImage = [NSImage imageWithSystemSymbolName:symbolName accessibilityDescription:nil];

    NSImage *image = [NSImage imageWithSize:referenceSymbolImage.size
                                    flipped:YES
                             drawingHandler:^BOOL(NSRect dstRect)
    {
        CGContextRef context = [NSGraphicsContext currentContext].CGContext;
        [self renderReferenceSymbolImage:referenceSymbolImage
                       asVectorInContext:context
                               fillColor:NSColor.blackColor];
        return YES;
    }];

    image.template = YES;
    image.alignmentRect = referenceSymbolImage.alignmentRect;

    return image;
}

+(NSData *)pdfDataForReferenceSymbolNamed:(NSString *)symbolName
                                fillColor:(NSColor *)fillColor
                      alignmentRectInsets:(NSEdgeInsets *)outInsets
{
    NSImage *referenceSymbolImage = [NSImage imageWithSystemSymbolName:symbolName accessibilityDescription:nil];

    *outInsets = referenceSymbolImage.alignmentRectInsets;

    return [NSData pdfDataForSinglePageOfSize:referenceSymbolImage.size
                                      flipped:YES
                                    byDrawing:^(CGContextRef context)
    {
        [self renderReferenceSymbolImage:referenceSymbolImage
                       asVectorInContext:context
                               fillColor:fillColor];
    }];
}

+(NSData *)contentsJSONForImageSetOfPDFNamed:(NSString *)pdfFilename
                         alignmentRectInsets:(NSEdgeInsets)insets
                                    template:(BOOL)isTemplate
{
    NSMutableDictionary *imageDict = [@{
        @"filename" : pdfFilename,
        @"idiom" : @"universal"
    } mutableCopy];

    if(!NSEdgeInsetsEqual(insets, NSEdgeInsetsZero)) {
        imageDict[@"alignment-insets"] = @{
            @"bottom" : @(insets.bottom),
            @"left" : @(insets.left),
            @"right" : @(insets.right),
            @"top" : @(insets.top)
        };
    }

    NSDictionary *jsonObject = @{
        @"images": @[ imageDict ],
        @"info": @{
            @"author": @"xcode",
            @"version": @1
        },
        @"properties": @{
            @"preserves-vector-representation": @YES,
            @"template-rendering-intent": isTemplate ? @"template" : @"original"
        }
    };

    return [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:nil];
}

+(BOOL)writeImageSetForSymbolNamed:(NSString *)symbolName
                       inDirectory:(NSURL *)directoryURL
                          template:(BOOL)isTemplate
                         fillColor:(NSColor * _Nullable)fillColor
            includeAlignmentInsets:(BOOL)includeInsets
                             error:(NSError **)error
{
    // Prep the PDF.

    if(isTemplate || !fillColor)
        fillColor = [NSColor blackColor];

    NSEdgeInsets alignmentRectInsets;
    NSData *pdfData = [self pdfDataForReferenceSymbolNamed:symbolName
                                                 fillColor:fillColor
                                       alignmentRectInsets:&alignmentRectInsets];

    if(!includeInsets) {
        // Zero out the insets if we're not writing them
        alignmentRectInsets = NSEdgeInsetsZero;
    }


    // Write it out.

    NSString *symbolExportName = [NSString stringWithFormat:@"sf-symbols.%@", symbolName];

    NSString *imageSetDirName = [symbolExportName stringByAppendingString:@".imageset"];
    NSURL *imageSetDirURL = [directoryURL URLByAppendingPathComponent:imageSetDirName isDirectory:YES];

    if(![[NSFileManager defaultManager] createDirectoryAtURL:imageSetDirURL
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:error])
    {
        return NO;
    }

    NSString *pdfFileName = [symbolExportName stringByAppendingString:@".pdf"];
    NSURL *pdfURL = [imageSetDirURL URLByAppendingPathComponent:pdfFileName isDirectory:NO];

    if(![pdfData writeToURL:pdfURL options:0 error:error])
        return NO;

    NSURL *contentsJSONURL = [imageSetDirURL URLByAppendingPathComponent:@"Contents.json" isDirectory:NO];
    NSData *contentsJSONData = [self contentsJSONForImageSetOfPDFNamed:pdfFileName
                                                   alignmentRectInsets:alignmentRectInsets
                                                              template:isTemplate];

    if(![contentsJSONData writeToURL:contentsJSONURL options:0 error:error])
        return NO;

    return YES;
}

@end
