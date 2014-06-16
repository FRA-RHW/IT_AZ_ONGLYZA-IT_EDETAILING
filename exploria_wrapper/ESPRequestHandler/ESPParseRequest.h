//
//  ESPRequest.h
//  Exploria2.5_wrapper
//
//  Created by PHI dev on 13/03/13.
//
//

#import <Foundation/Foundation.h>

@interface ESPParseRequest : NSObject<NSXMLParserDelegate>{
    NSXMLParser *xml;
    BOOL isArgs;
    
    NSString *currentElement;
    NSString *name, *ID;
}

- (id)initESPRequest:(NSString *)req;
- (NSDictionary *)getRequestArgs;

@end
