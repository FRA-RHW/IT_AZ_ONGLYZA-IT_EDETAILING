//
//  Splash.m
//  exploria_wrapper
//
//  Created by Vincenzo Romano on 05/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Splash.h"
#import "AppMenu.h"
#import "AppDelegate.h"

@interface Splash ()

@end

@implementation Splash

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIImage *image = [UIImage imageNamed:@"splash.jpg"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	[self.view addSubview:imageView];
	[image release];	
    
    AppMenu* menu=[[AppMenu alloc] initWithFrame:CGRectMake(0, 650, 1024, 50)];
    
    menu.alpha=0;
    
    [self.view addSubview:menu];
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.75f];
	menu.alpha = 1;	
	
	[UIView commitAnimations];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [super dealloc];
}

@end
