#import "NSImage+SFSymbolsHackery.h"
#import <objc/runtime.h>


@implementation NSImage (SFSymbolsHackery)

-(nullable NSImageRep *)firstSymbolImageRep
{
    Class symbolImageRepClass = NSClassFromString(@"NSSymbolImageRep");
    for(NSImageRep *rep in self.representations) {
        if(rep.class == symbolImageRepClass)
            return rep;
    }

    return nil;
}

-(BOOL)isSymbol
{
    return [self firstSymbolImageRep] != nil;
}

-(NSObject<VectorGlyph> *)vectorGlyph
{
    NSImageRep *rep = [self firstSymbolImageRep];

    if(!rep) {
        NSLog(@"Image %@ does not seem to be a symbol!", self);
        return nil;
    }

    Ivar ivar = class_getInstanceVariable([rep class], "_vectorGlyph");
    NSObject<VectorGlyph> *vectorGlyph = object_getIvar(rep, ivar);

    if(vectorGlyph.class != NSClassFromString(@"CUINamedVectorGlyph")) {
        NSLog(@"Vector glyph %@ is not a CUINamedVectorGlyph!", vectorGlyph);
        return nil;
    }

    return vectorGlyph;
}

@end
