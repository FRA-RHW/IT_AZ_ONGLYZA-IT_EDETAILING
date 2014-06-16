//
//  Utils.h
//  sample
//
//  Created by Gianluca Esposito on 21/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utils : NSObject { }

+ (NSDictionary*) readDictionaryFromPlist:(NSString*)key;
+ (NSString*) readFromPlist:(NSString*)key;

+ (NSString*) readBundleIdentifier;
+ (NSString*) readBundleVersion;

+ (NSNumber*) readApplicationID;
+ (NSString*) readStoreDataServiceURL;
+ (NSString*) readStoreDataServiceHostName;

+ (NSString*) readLastUsedURL;
+ (void) storeLastUsedURL:(NSString*)value;;


@end
