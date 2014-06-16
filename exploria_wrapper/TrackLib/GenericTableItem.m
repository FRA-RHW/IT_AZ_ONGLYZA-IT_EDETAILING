//
//  GenericTableItem.m
//  BMS
//
//  Created by gianluca esposito on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GenericTableItem.h"

@implementation GenericTableItem

@synthesize label;
@synthesize detail;
@synthesize value;

- (id) init {
	label = @"";
	detail = @"";
	value = 0;
	return self;
}

- (void) dealloc{
	[label release];
	label = nil;
	[detail release];
	detail = nil;
	[super dealloc];
}

@end
