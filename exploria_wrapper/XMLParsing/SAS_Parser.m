//
//  SAS_Parser.m
//  Exploria2.5_wrapper
//
//  Created by Vincenzo Romano on 12/03/13.
//
//

#import "SAS_Parser.h"

@implementation SAS_Parser

- (id)init{
    self = [super init];
    if(self){
        basePath = [NSString stringWithFormat:@"%@/Package/phi1",[[NSBundle mainBundle] bundlePath]];
        NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:nil];
        NSArray *sasFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.sas'"]];
        slides = [[NSMutableArray alloc] init];
        
        for(int i=0; i<sasFiles.count; i++){
            NSString *sasPath = [NSString stringWithFormat:@"%@/%@",basePath, [sasFiles objectAtIndex:i]];
        
            xml = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:sasPath]];
            xml.delegate = self;
            [xml setShouldProcessNamespaces:NO];
            [xml setShouldReportNamespacePrefixes:NO];
            [xml setShouldResolveExternalEntities:NO];
            [xml parse];
        }
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
        
        ID = nil;
        StartUpFile = [[NSMutableString alloc] init];
        Thumbnail = [[NSMutableString alloc] init];
        Icon = [[NSMutableString alloc] init];
        DisplayNameLine1 = [[NSMutableString alloc] init];
        DisplayNameLine2 = [[NSMutableString alloc] init];
        InternalName = [[NSMutableString alloc] init];
        Description = [[NSMutableString alloc] init];
        Product = [[NSMutableString alloc] init];
        ProductMessage = [[NSMutableString alloc] init];
        isThumb = NO;
        isIcon = NO;
        
    }else if ([currentElement isEqualToString:@"StartUpFile"]) {
        NSString *revert = [[[attributeDict objectForKey:@"href"] componentsSeparatedByString:@"\\"] componentsJoinedByString:@"/"];
        [StartUpFile appendString:revert];
        [slide setObject:StartUpFile forKey:@"StartUpFile"];
    }else if ([currentElement isEqualToString:@"Thumbnails"]) {
        isThumb = YES;
    }else if ([currentElement isEqualToString:@"Icons"]) {
        isIcon = YES;
    }else if ([currentElement isEqualToString:@"Image"]) {
        if(isThumb){
            NSString *revert = [[[attributeDict objectForKey:@"href"] componentsSeparatedByString:@"\\"] componentsJoinedByString:@"/"];
            [Thumbnail appendString:revert];
            [slide setObject:Thumbnail forKey:@"Thumbnail"];
            isThumb = NO;
        }else if(isIcon){
            NSString *revert = [[[attributeDict objectForKey:@"href"] componentsSeparatedByString:@"\\"] componentsJoinedByString:@"/"];
            [Icon appendString:revert];
            [slide setObject:Thumbnail forKey:@"Icon"];
            isIcon = NO;
        }
    }
}

- (void) parser: (NSXMLParser *) parser foundCharacters: (NSString *) string{
    @try {
        if ([currentElement isEqualToString:@"ID"] && ID==nil) {
            ID = [[NSMutableString alloc] init];
            if([string componentsSeparatedByString:@"\n"].count>1 ||
               [string componentsSeparatedByString:@"\t"].count>1)return;
            
            [ID appendString:string];
            if(ID.length<36)return;
            [slide setObject:ID forKey:@"id"];
        }else if ([currentElement isEqualToString:@"DisplayNameLine1"]){
            if([string componentsSeparatedByString:@"\n"].count>1 ||
               [string componentsSeparatedByString:@"\t"].count>1)return;
            
            [DisplayNameLine1 appendString:string];
            [slide setObject:DisplayNameLine1 forKey:@"DisplayNameLine1"];
            
        }else if ([currentElement isEqualToString:@"DisplayNameLine2"]){
            if([string componentsSeparatedByString:@"\n"].count>1 ||
               [string componentsSeparatedByString:@"\t"].count>1)return;
            
            [DisplayNameLine2 appendString:string];
            [slide setObject:DisplayNameLine2 forKey:@"DisplayNameLine2"];
            
        }else if ([currentElement isEqualToString:@"InternalName"]){
            if([string componentsSeparatedByString:@"\n"].count>1 ||
               [string componentsSeparatedByString:@"\t"].count>1)return;
            
            [InternalName appendString:string];
            [slide setObject:InternalName forKey:@"InternalName"];
            
        }else if ([currentElement isEqualToString:@"Description"]){
            if([string componentsSeparatedByString:@"\n"].count>1 ||
               [string componentsSeparatedByString:@"\t"].count>1)return;
            
            [Description appendString:string];
            [slide setObject:Description forKey:@"Description"];
            
        }else if ([currentElement isEqualToString:@"Product"]){
            if([string componentsSeparatedByString:@"\n"].count>1 ||
               [string componentsSeparatedByString:@"\t"].count>1)return;
            
            [Product appendString:string];
            [slide setObject:Product forKey:@"Product"];
            
        }else if ([currentElement isEqualToString:@"ProductMessage"]){
            if([string componentsSeparatedByString:@"\n"].count>1 ||
               [string componentsSeparatedByString:@"\t"].count>1)return;
            
            [ProductMessage appendString:string];
            [slide setObject:ProductMessage forKey:@"ProductMessage"];
            
        }
    }@catch (NSException *e) { }
}

- (void) parser: (NSXMLParser *) parser didEndElement: (NSString *) elementName
   namespaceURI: (NSString *) namespaceURI
  qualifiedName: (NSString *) qName{
    
    /*if ([elementName isEqualToString:@"Slide"]){
        [section addObject:slide];
        [presentation addObject:section];
    }else if([elementName isEqualToString:@"MenuItemLayer1"]){
    }*/
}

- (void) parserDidEndDocument: (NSXMLParser *)parser {
    [slides addObject:slide];
}

- (NSArray *)getSlides{
    return slides;
}

- (void) dealloc {
    [super dealloc];
}


@end
