//
//  EventObject.h
//  sample
//
//  Created by Gianluca Esposito on 21/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EventObject : NSObject {
	int type;
	NSString *code;
	NSString *description;
	NSString *extended;
	NSString *sender;
	double clientTime;
	float latitude;
	float longitude;
	float weight;
	int applicationID;
	
	NSString *bundleIdentifier;
	NSString *bundleVersion;
}

@property int type;
@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *extended;
@property (nonatomic, retain) NSString *sender;
@property double clientTime;
@property float latitude;
@property float longitude;
@property float weight;
@property int applicationID;

@property (nonatomic, retain) NSString *bundleIdentifier;
@property (nonatomic, retain) NSString *bundleVersion;

- (id) init;

@end
