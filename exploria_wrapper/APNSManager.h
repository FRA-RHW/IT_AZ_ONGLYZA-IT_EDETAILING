//
//  APNSManager.h
//  iressa
//
//  Created by Gianluca Esposito on 30/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APNSManager : NSObject {
}

+ (int) incrementRunsCount;
+ (void) resetRunsCount;
+ (int) currentVersion;
+ (BOOL) checkForUpdate:(int)badgeVersion;
+ (void) launchUpdate:(NSString*)deviceToken;
+ (void) launchUpdate:(NSString*)username password:(NSString*)password;
+ (void) sendDeviceToken:(NSString*)deviceToken;
+ (BOOL) storeDeviceToken:(NSString*)deviceToken;

@end
