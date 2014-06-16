//
//  SAS_Parser.h
//  Exploria2.5_wrapper
//
//  Created by Vincenzo Romano on 12/03/13.
//
//

#import <Foundation/Foundation.h>

@interface SAS_Parser : NSObject<NSXMLParserDelegate>{
    NSString *basePath;
    NSXMLParser *xml;
    
    NSMutableDictionary *slide;
    NSMutableArray *slides;
    
    NSMutableArray *presentation;
    NSString *currentElement;
    NSMutableString *ID, *StartUpFile, *Thumbnail, *Icon, *DisplayNameLine1, *DisplayNameLine2, *InternalName, *Description, *Product, *ProductMessage;
    
    BOOL isThumb, isIcon;
}

- (NSArray *)getSlides;

@end
