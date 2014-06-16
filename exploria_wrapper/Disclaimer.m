//
//  Disclaimer.m
//  exploria_wrapper
//
//  Created by PHI dev on 04/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Disclaimer.h"

@interface Disclaimer ()

@end

@implementation Disclaimer

- (id)initPage
{
    self = [super init];
    if (self) {
        [self.view setFrame:CGRectMake(0, 0, 1024, 768)];
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"disclaimer.jpg"]]];
        
        UIButton *accept = [UIButton buttonWithType:UIButtonTypeCustom];
        [accept setBackgroundImage:[UIImage imageNamed:@"accept.png"] forState:UIControlStateNormal];
        [accept addTarget:self action:@selector(didAccept:) forControlEvents:UIControlEventTouchUpInside];
        [accept setFrame:CGRectMake(200, 400, 203, 43)];
        
        UIButton *decline = [UIButton buttonWithType:UIButtonTypeCustom];
        [decline setBackgroundImage:[UIImage imageNamed:@"decline.png"] forState:UIControlStateNormal];
        [decline addTarget:self action:@selector(didDecline:) forControlEvents:UIControlEventTouchUpInside];
        [decline setFrame:CGRectMake(605, 400, 203, 43)];
        
        [self.view addSubview:accept];
        [self.view addSubview:decline];
        
    }
    return self;
}

-(void)didAccept:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startPresent" object:self];
}

-(void)didDecline:(id)sender{
    UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"info" message:@"Sorry, you must accept to start presentation" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [msg show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        exit(0);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown && interfaceOrientation != UIInterfaceOrientationPortrait);
}

@end
