//
//  SAS_Parser.m
//  Exploria2.5_wrapper
//
//  Created by Vincenzo Romano on 12/03/13.
//
//

#import <Foundation/Foundation.h>

@interface SAP_Parser : NSObject<NSXMLParserDelegate>{
    NSString *basePath, *phiPath;
    NSXMLParser *xml;
    
    NSMutableDictionary *slide;
    
    NSMutableArray *section;
    
    NSMutableArray *presentation;
    NSString *currentElement;
    NSMutableString *ID, *DisplayNameLine1, *DisplayNameLine2, *DisplayName;
}

- (NSMutableArray *) getPresentation;

@end
