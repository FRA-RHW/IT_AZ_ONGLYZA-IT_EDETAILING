//
//  APNSManager.m
//  iressa
//
//  Created by Gianluca Esposito on 30/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "APNSManager.h"
#import "ASIFormDataRequest.h"
#import "OpenUDID.h"
const int MAX_RUNS_WITH_PENDING_UPDATE = 3;

@implementation APNSManager

+ (int) incrementRunsCount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int runsCount = [defaults integerForKey:@"APP_RUNS_COUNT"];
    runsCount = runsCount + 1;
    [defaults setInteger:runsCount forKey:@"APP_RUNS_COUNT"];
    return runsCount;
}

+ (void) resetRunsCount {
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"APP_RUNS_COUNT"];
}

+ (int) currentVersion {
    return [[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"LSEnvironment"] objectForKey:@"CurrentVersion"] intValue];
}

+ (BOOL) checkForUpdate:(int)badgeVersion {
    if ([self currentVersion] < badgeVersion) return YES;
    return NO;
}

+ (void) sendDeviceToken:(NSString*)deviceToken {
    NSString *baseURL = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"LSEnvironment"] objectForKey:@"DataServiceBaseURL"];
    NSString *completeURL = [[NSString alloc] initWithFormat:@"%@%@", baseURL, @"SetDeviceToken.axd"];
    NSString *bundleIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString *preferredLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];

    NSURL *url = [NSURL URLWithString:completeURL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    //[request setPostValue:[UIDevice currentDevice].uniqueIdentifier forKey:@"_uniqueIdentifier"];
    [request setPostValue:[OpenUDID value] forKey:@"_uniqueIdentifier"];
    NSLog(@"%@--------------",[OpenUDID value]);
    [request setPostValue:deviceToken forKey:@"_deviceToken"];
    [request setPostValue:bundleIdentifier forKey:@"_bundleIdentifier"];
    [request setPostValue:preferredLanguage forKey:@"_preferredLanguage"];
 
    [request setDelegate:self];
    [request startAsynchronous];

    [baseURL release];
    [completeURL release];
    [bundleIdentifier release];
    [preferredLanguage release];
}

+ (void) launchUpdate:(NSString*)username password:(NSString*)password {
    NSString *baseURL = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"LSEnvironment"] objectForKey:@"DataServiceBaseURL"];
    NSString *completeURL = [[NSString alloc] initWithFormat:@"%@%@", baseURL, @"AuthenticateUser.axd"];
    NSString *bundleIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    
    NSURL *url = [NSURL URLWithString:completeURL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:username forKey:@"_username"];
    [request setPostValue:password forKey:@"_password"];
    [request setPostValue:bundleIdentifier forKey:@"_bundleIdentifier"];
    
    [request setDelegate:self];
    [request startSynchronous];
    
    if ([request responseString] != nil) {
        NSString *response = [NSString stringWithString:[request responseString]];
#ifdef DEBUG
        NSLog(@"%@", response);
#endif
        
        NSString *responseMessage = [[response componentsSeparatedByString:@"|"] objectAtIndex:0];
        if ([responseMessage isEqualToString:@"SUCCESS"]) {
            NSString *updateUrl = [[response componentsSeparatedByString:@"|"] objectAtIndex:1];
#ifdef DEBUG
            NSLog(@"%@", updateUrl);
#endif
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl]];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"ERROR", nil)]
                                                                message:[NSString stringWithFormat:@"%@", NSLocalizedString(@"UPDATE_ERROR", nil)]
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil
                                      ];
            [alertView show];
            [alertView release];
            
        }
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"ERROR", nil)]
                                                            message:[NSString stringWithFormat:@"%@", NSLocalizedString(@"UPDATE_ERROR", nil)]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil
                                  ];
        [alertView show];
        [alertView release];        
    }
    
    [baseURL release];
    [completeURL release];
    [bundleIdentifier release];
}

+ (void) launchUpdate:(NSString*)deviceToken {
    NSString *baseURL = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"LSEnvironment"] objectForKey:@"DataServiceBaseURL"];
    NSString *completeURL = [[NSString alloc] initWithFormat:@"%@%@", baseURL, @"Authenticate.axd"];
    NSString *bundleIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    
    NSURL *url = [NSURL URLWithString:completeURL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    //[request setPostValue:[UIDevice currentDevice].uniqueIdentifier forKey:@"_uniqueIdentifier"];
    [request setPostValue:[OpenUDID value] forKey:@"_uniqueIdentifier"];

    [request setPostValue:deviceToken forKey:@"_deviceToken"];
    [request setPostValue:bundleIdentifier forKey:@"_bundleIdentifier"];
    
    [request setDelegate:self];
    [request startSynchronous];
    
    if ([request responseString] != nil) {
    NSString *response = [NSString stringWithString:[request responseString]];
#ifdef DEBUG
    NSLog(@"%@", response);
#endif
    
    NSString *responseMessage = [[response componentsSeparatedByString:@"|"] objectAtIndex:0];
    if ([responseMessage isEqualToString:@"SUCCESS"]) {
        NSString *updateUrl = [[response componentsSeparatedByString:@"|"] objectAtIndex:1];
#ifdef DEBUG
        NSLog(@"%@", updateUrl);
#endif
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl]];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"ERROR", nil)]
                                                            message:[NSString stringWithFormat:@"%@", NSLocalizedString(@"UPDATE_ERROR", nil)]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil
                                  ];
        [alertView show];
        [alertView release];

    }
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"ERROR", nil)]
                                                            message:[NSString stringWithFormat:@"%@", NSLocalizedString(@"UPDATE_ERROR", nil)]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil
                                  ];
        [alertView show];
        [alertView release];
        
    }
    
    [baseURL release];
    [completeURL release];
    [bundleIdentifier release];
}

+ (BOOL) storeDeviceToken:(NSString*)deviceToken {
    BOOL retVal = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* currentToken = [defaults stringForKey:@"APNS_DEVICE_TOKEN"];
    if (![currentToken isEqualToString:deviceToken]) {
        [defaults setObject:deviceToken forKey:@"APNS_DEVICE_TOKEN"];
        retVal = YES;
    }
    return retVal;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
	// Use when fetching text data
	NSString *responseString = [request responseString];
	
#ifdef DEBUG
    NSLog(@"requestFinished");
	NSLog(@"Data received:");
	NSLog(@"%@", responseString);
#endif
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"requestFinished" object:self];
    
    [defaults release];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
#ifdef DEBUG
	NSLog(@"requestFailed");
	NSLog(@"Error: %@", [error code]);
    NSLog(@"Error: %@", [error description]);
#endif 
    
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"requestFailed" object:self];
}


@end
