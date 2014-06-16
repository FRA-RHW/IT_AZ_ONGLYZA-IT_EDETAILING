//
//  ClientObject.h
//  sample
//
//  Created by Gianluca Esposito on 21/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ClientObject : NSObject {
	NSString *uniqueIdentifier;
	NSString *systemName;
	NSString *systemVersion;
}

@property (nonatomic, retain) NSString *uniqueIdentifier;
@property (nonatomic, retain) NSString *systemName;
@property (nonatomic, retain) NSString *systemVersion;

- (id) init;

@end
