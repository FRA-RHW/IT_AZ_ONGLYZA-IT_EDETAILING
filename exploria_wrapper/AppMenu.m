//
//  AppMenu.m
//  iressa
//
//  Created by AzDeployment on 11/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppMenu.h"
#import "TrackManager.h"

@implementation AppMenu

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      /*  UIButton* btn=nil;
        
       btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(150, 0, 203, 43)];
        [self addSubview:btn];
        btn.tag = 1;    
        [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_practice.png"] forState:UIControlStateNormal];
        
        btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(410, 0, 203, 43)];
        [self addSubview:btn];
        btn.tag = 2;    
        [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_start.png"] forState:UIControlStateNormal];
        
        btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(671, 0, 203, 43)];
        [self addSubview:btn];
        btn.tag=3;    
        [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_sync.png"] forState:UIControlStateNormal];
*/
        
    }
    return self;
}

- (void) buttonPressed:(id)sender{
    if ([sender tag] == 1) {
        [[TrackManager sharedInstance] setEnableTracking:NO];
    }
    else if ([sender tag] == 2) {
        [[TrackManager sharedInstance] setEnableTracking:YES];
        [[TrackManager sharedInstance] traceStartSession];
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"showDisclaimer" object:self];
        //return;
    }
    else if ([sender tag]==3){
        [[TrackManager sharedInstance] traceDump];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dumpLog" object:self];
        return;
    }
    else {
        // DO NOTHING
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startPresent" object:self];
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"playIntro" object:self];
}

- (void)dealloc
{
    [super dealloc];
}

@end
