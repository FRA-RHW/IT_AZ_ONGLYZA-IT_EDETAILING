//
//  Utils.m
//  sample
//
//  Created by Gianluca Esposito on 21/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (NSString*) readFromPlist:(NSString*)key {	
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:key];
}

+ (NSDictionary*) readDictionaryFromPlist:(NSString*)key {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:key];
}

+ (NSString*) readBundleIdentifier {
	return [self readFromPlist:@"CFBundleIdentifier"];
}

+ (NSString*) readBundleVersion {
	return [self readFromPlist:@"CFBundleVersion"];
}

+ (NSNumber*) readApplicationID {
    return (NSNumber*)[[self readDictionaryFromPlist:@"LSEnvironment"] objectForKey:@"ApplicationID"];
}

+ (NSString*) readStoreDataServiceURL {
    return (NSString*)[[self readDictionaryFromPlist:@"LSEnvironment"] objectForKey:@"StoreDataServiceURL"];
}

+ (NSString*) readStoreDataServiceHostName {
    return (NSString*)[[self readDictionaryFromPlist:@"LSEnvironment"] objectForKey:@"StoreDataServiceHostName"];
}

+ (NSString*) readLastUsedURL {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"LastUsedURL"];
}

+ (void) storeLastUsedURL:(NSString*)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:value forKey:@"LastUsedURL"];
	[defaults synchronize];
}

@end
