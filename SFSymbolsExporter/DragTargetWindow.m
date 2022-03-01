#import "DragTargetWindow.h"


@implementation DragTargetWindow

-(void)awakeFromNib
{
    [self registerForDraggedTypes:@[ NSPasteboardTypeString, @"com.apple.SFSymbols.symbolidentifiers" ]];
}

-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    return YES;
}

-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    return NSDragOperationGeneric;
}

-(NSArray<NSString *> *)composedCharacterSequencesOfString:(NSString *)s
{
    NSMutableArray *sequences = [NSMutableArray new];

    [s enumerateSubstringsInRange:NSMakeRange(0, s.length)
                          options:NSStringEnumerationByComposedCharacterSequences
                       usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop)
    {
        [sequences addObject:substring];
    }];

    return sequences;
}

-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pb = sender.draggingPasteboard;
    NSString *stringVal = [pb stringForType:NSPasteboardTypeString];
    NSData *symbolIdsPlistData = [pb dataForType:@"com.apple.SFSymbols.symbolidentifiers"];

    NSError *plistErr;
    NSArray<NSString *> *symbolNames = [NSPropertyListSerialization propertyListWithData:symbolIdsPlistData
                                                                                 options:0
                                                                                  format:nil
                                                                                   error:&plistErr];

    if(!symbolNames) {
        NSLog(@"Error deserializing dragged data: %@", plistErr);
        return NO;
    }

    if(![symbolNames isKindOfClass:[NSArray class]]) {
        NSLog(@"Dragged plist data was not an array!");
        return NO;
    }

    NSLog(@"Drag: %@ %@", stringVal, symbolNames);

    NSArray<NSString *> *symbolSubstrings = [self composedCharacterSequencesOfString:stringVal];

    if(symbolSubstrings.count != symbolNames.count) {
        NSLog(@"The string value and symbol names array don't have the same number of elements!");
        return NO;
    }

    NSMutableDictionary<NSString *, NSString *> *symbolsByName = [NSMutableDictionary new];
    for(NSUInteger i = 0; i < symbolNames.count; i++) {
        symbolsByName[symbolNames[i]] = symbolSubstrings[i];
    }

    id<SFSymbolsDragTarget> target = (id<SFSymbolsDragTarget>)self.contentViewController;
    if([target respondsToSelector:@selector(handleDragOfSymbols:)])
        [target handleDragOfSymbols:symbolsByName];

    return YES;
}

@end
