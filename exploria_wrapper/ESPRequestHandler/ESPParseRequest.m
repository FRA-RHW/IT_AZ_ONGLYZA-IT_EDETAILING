//
//  ESPRequest.m
//  Exploria2.5_wrapper
//
//  Created by PHI dev on 13/03/13.
//
//

#import "ESPParseRequest.h"

@implementation ESPParseRequest

- (id)initESPRequest:(NSString *)req{
    self = [super init];
    if(self){
        NSData *data = [req dataUsingEncoding:NSUTF8StringEncoding];
        xml = [[NSXMLParser alloc] initWithData:data];
        xml.delegate = self;
        [xml setShouldProcessNamespaces:NO];
        [xml setShouldReportNamespacePrefixes:NO];
        [xml setShouldResolveExternalEntities:NO];
        [xml parse];
    }
    return self;
}

- (void) parserDidStartDocument: (NSXMLParser *) parser {
    isArgs = NO;
}

- (void) parser: (NSXMLParser *) parser parseErrorOccurred: (NSError *) parseError {
    NSLog(@"Errore nel parser!");
}

- (void) parser: (NSXMLParser *) parser didStartElement: (NSString *) elementName
   namespaceURI: (NSString *) namespaceURI
  qualifiedName: (NSString *) qName
     attributes: (NSDictionary *) attributeDict{
    
    currentElement = [elementName copy];
    
    if ([elementName isEqualToString:@"invoke"]){
        name = [attributeDict objectForKey:@"name"];
    }else if([elementName isEqualToString:@"arguments"]){
        isArgs = YES;
    }
    
}

- (void) parser: (NSXMLParser *) parser foundCharacters: (NSString *) string{
    @try {
        if([currentElement isEqualToString:@"string"] && isArgs){
            if([string componentsSeparatedByString:@"\n"].count>1 ||
               [string componentsSeparatedByString:@"\t"].count>1)return;
            
            ID = string;
        }
    }@catch (NSException *e) { }
}

- (void) parser: (NSXMLParser *) parser didEndElement: (NSString *) elementName
   namespaceURI: (NSString *) namespaceURI
  qualifiedName: (NSString *) qName{
    
    if([elementName isEqualToString:@"arguments"]){
        isArgs = NO;
    }
}

- (void) parserDidEndDocument: (NSXMLParser *)parser {
}

- (NSDictionary *)getRequestArgs{
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:name, ID, nil]
                                      forKeys:[NSArray arrayWithObjects:@"name", @"id", nil]];
}



@end
