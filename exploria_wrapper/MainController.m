//
//  MainController.m
//  exploria_wrapper
//
//  Created by Vincenzo Romano on 05/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainController.h"

@interface MainController ()

@end

@implementation MainController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavigationBarHidden:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown && interfaceOrientation != UIInterfaceOrientationPortrait);
}

@end
