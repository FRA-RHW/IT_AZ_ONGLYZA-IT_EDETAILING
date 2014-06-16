//
//  SAS_Parser.m
//  Exploria2.5_wrapper
//
//  Created by Vincenzo Romano on 12/03/13.
//
//

#import "SAP_Parser.h"
#import "SAS_Parser.h"

@implementation SAP_Parser

- (id)init{
    self = [super init];
    if(self){
        basePath = [NSString stringWithFormat:@"%@/Package",[[NSBundle mainBundle] bundlePath]];
        NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:nil];
        NSArray *sapFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.sap'"]];
    
        NSString *sapPath = [NSString stringWithFormat:@"%@/%@",basePath, [sapFiles objectAtIndex:0]];
    
        xml = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:sapPath]];
        xml.delegate = self;
        [xml setShouldProcessNamespaces:NO];
        [xml setShouldReportNamespacePrefixes:NO];
        [xml setShouldResolveExternalEntities:NO];
        [xml parse];
    }
    return self;
}

- (void) parserDidStartDocument: (NSXMLParser *) parser {
    presentation = [[NSMutableArray alloc] init];
}

- (void) parser: (NSXMLParser *) parser parseErrorOccurred: (NSError *) parseError {
    NSLog(@"Errore nel parser!");
}

- (void) parser: (NSXMLParser *) parser didStartElement: (NSString *) elementName
                                           namespaceURI: (NSString *) namespaceURI
                                          qualifiedName: (NSString *) qName
                                             attributes: (NSDictionary *) attributeDict{
    currentElement = [elementName copy];
    if ([elementName isEqualToString:@"Slide"]){
        slide = [[NSMutableDictionary alloc] init];
        section = [[NSMutableArray alloc] init];
        
        ID = [[NSMutableString alloc] init];
        DisplayNameLine1 = [[NSMutableString alloc] init];
        DisplayNameLine2 = [[NSMutableString alloc] init];
    }else if([elementName isEqualToString:@"MenuItemLayer1"]){
        [section addObject:slide];
        slide = [[NSMutableDictionary alloc] init];
        
        ID = [[NSMutableString alloc] init];
        DisplayName = [[NSMutableString alloc] init];
    }
}

- (void) parser: (NSXMLParser *) parser foundCharacters: (NSString *) string{
    @try {
        if ([currentElement isEqualToString:@"ID"]) {
            if([string componentsSeparatedByString:@"\n"].count>1 ||
               [string componentsSeparatedByString:@"\t"].count>1)return;
            
            [ID appendString:string];
            if(ID.length<36)return;
            [slide setObject:ID forKey:@"id"];
            
            ID = [[NSMutableString alloc] init];
        }else if ([currentElement isEqualToString:@"DisplayNameLine1"]){
            if([string componentsSeparatedByString:@"\n"].count>1 ||
               [string componentsSeparatedByString:@"\t"].count>1)return;
            
            [DisplayNameLine1 appendString:string];
            [slide setObject:DisplayNameLine1 forKey:@"DisplayNameLine1"];
            DisplayNameLine1 = [[NSMutableString alloc] init];
            
        }else if ([currentElement isEqualToString:@"DisplayNameLine2"]){
            if([string componentsSeparatedByString:@"\n"].count>1 ||
               [string componentsSeparatedByString:@"\t"].count>1)return;
            
            [DisplayNameLine2 appendString:string];
            [slide setObject:DisplayNameLine2 forKey:@"DisplayNameLine2"];
            DisplayNameLine2 = [[NSMutableString alloc] init];
            
        }else if ([currentElement isEqualToString:@"DisplayName"]){
            if([string componentsSeparatedByString:@"\n"].count>1 ||
               [string componentsSeparatedByString:@"\t"].count>1)return;
            
            [DisplayName appendString:string];
            [slide setObject:DisplayName forKey:@"DisplayName"];
            DisplayName = [[NSMutableString alloc] init];
            
        }
    }@catch (NSException *e) { }
}

- (void) parser: (NSXMLParser *) parser didEndElement: (NSString *) elementName
                                         namespaceURI: (NSString *) namespaceURI
                                        qualifiedName: (NSString *) qName{
    
    if ([elementName isEqualToString:@"Slide"]){
        [section addObject:slide];
        [presentation addObject:section];
    }else if([elementName isEqualToString:@"MenuItemLayer1"]){
    }
}

- (void) parserDidEndDocument: (NSXMLParser *)parser {
    NSLog(@"SAP Parsed!!");
}

- (NSMutableArray *) getPresentation{
    return presentation;
}

- (void) dealloc {
    [super dealloc];
}


@end
