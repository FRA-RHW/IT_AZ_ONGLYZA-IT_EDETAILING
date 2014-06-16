//
//  EventObject.m
//  sample
//
//  Created by Gianluca Esposito on 21/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventObject.h"
#import "Utils.h"

@implementation EventObject

@synthesize type;
@synthesize code;
@synthesize description;
@synthesize extended;
@synthesize sender;
@synthesize clientTime;
@synthesize latitude;
@synthesize longitude;
@synthesize weight;
@synthesize applicationID;
@synthesize bundleIdentifier;
@synthesize bundleVersion;

- (id) init {
	type = -1;
	code = [[NSString alloc] initWithString:@""];
	description = [[NSString alloc] initWithString:@""];
	extended = [[NSString alloc] initWithString:@""];
	sender = [[NSString alloc] initWithString:@""];
	clientTime =  [[NSDate date] timeIntervalSince1970];
	latitude = 0;
	longitude = 0;
	weight = 0;
	applicationID = [[Utils readApplicationID]intValue];
	bundleIdentifier = [[NSString alloc] initWithString:[Utils readBundleIdentifier]];
	bundleVersion = [[NSString alloc] initWithString:[Utils readBundleVersion]];	
	return self;
}

- (void) dealloc {
	[code release];
	[description release];
	[extended release];
	[sender release];
	[bundleIdentifier release];
	[bundleVersion release];
		
	code = nil;
	description = nil;
	extended = nil;
	sender = nil;
	bundleVersion = nil;
	bundleIdentifier = nil;
		
	[super dealloc];
}

@end


