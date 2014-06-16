//
//  GenericTableItem.h
//
//  Created by gianluca esposito on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenericTableItem : NSObject {
	@public NSString* label;
	@public NSString* detail;
	@public int value;
}

@property (nonatomic, retain) NSString* label;
@property (nonatomic, retain) NSString* detail;
@property int value;

- (id) init;

@end
