//
//  ClientObject.m
//  sample
//
//  Created by Gianluca Esposito on 21/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ClientObject.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OpenUDID.h"
@implementation ClientObject

@synthesize uniqueIdentifier;
@synthesize systemName;
@synthesize systemVersion;

- (id) init {
	//uniqueIdentifier =[[NSString alloc] initWithString:[UIDevice currentDevice].uniqueIdentifier];
    uniqueIdentifier =[[NSString alloc] initWithString:[OpenUDID value]]; 
    
	systemName = [[NSString alloc] initWithString:[UIDevice currentDevice].systemName];
	systemVersion = [[NSString alloc] initWithString:[UIDevice currentDevice].systemVersion];
	return self;
}

- (void) dealloc {
	[uniqueIdentifier release];
	[systemName release];
	[systemVersion release];
	[super dealloc];
}

@end
