//
//  AppDelegate.m
//  exploria_wrapper
//
//  Created by AZuk on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Disclaimer.h"
#import "ViewController.h"
#import "MainController.h"
#import "Splash.h"
#import "TrackManager.h"
#import "Reachability.h"
#import "Utils.h"
#import "syncModalUI.h"

#import "SAP_Parser.h"
#import "SAS_Parser.h"
#import "Menu.h"

@implementation AppDelegate

extern const int EVENT_INFO;
extern const int EVENT_DEBUG;
extern const int EVENT_WARNING;
extern const int EVENT_EXCEPTION;
extern const int EVENT_SYSTEM;
extern const int EVENT_CUSTOM;

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize mainController;
@synthesize restart;
@synthesize indexForPdf;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [splashScreen release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   
    self.restart = YES;
    
    // Prevent dimming
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    /* INITIALIZE TRACKMANAGER */
    [[TrackManager sharedInstance] checkAndCreateDabase];
    [[TrackManager sharedInstance] setEnableTracking:YES];
    [self dumpLogAuto];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPresent:) name:@"startPresent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dumpLog:) name:@"dumpLog" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropDataBase:) name:@"dropDataBase" object:nil];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    int cacheSizeMemory = 40*1024*1024; // 4MB
    int cacheSizeDisk = 4*1024*1024; // 32MB
    NSURLCache *sharedCache = [[[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"] autorelease];
    [NSURLCache setSharedURLCache:sharedCache];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    splashScreen = [[Splash alloc] init];	
    self.mainController = [[MainController alloc] init];
    [self.mainController pushViewController:splashScreen animated:NO];
    [self startPresent:nil];
    self.window.rootViewController = self.mainController;
    [self.window makeKeyAndVisible];
    return YES;
}



- (void) startPresent:(id)sender {
    [[TrackManager sharedInstance] traceStart];
    [self.mainController.visibleViewController.view setUserInteractionEnabled:YES];
    [self.mainController.view setUserInteractionEnabled:YES];
    
    [self createTree];
    //[self initRootSection];
}

- (void)createTree{
    NSLog(@"init parsing");
    SAP_Parser *sap = [[SAP_Parser alloc] init];
    SAS_Parser *sas = [[SAS_Parser alloc] init];
    
    presentation = [sap getPresentation];
    slides = [[NSMutableArray alloc] initWithArray:[sas getSlides]];
    NSMutableArray *cp_slides = [NSMutableArray arrayWithArray:[sas getSlides]];
    
    for(int i=0; i<presentation.count; i++){
        NSArray *section = [presentation objectAtIndex:i];
        for(int j=0; j<section.count; j++){
            NSString *ID = [[section objectAtIndex:j] objectForKey:@"id"];
            for(int k=0; k<cp_slides.count; k++){
                NSMutableDictionary *tmp = [cp_slides objectAtIndex:k];
                if([ID isEqualToString:[tmp objectForKey:@"id"]]){
                    [[section objectAtIndex:j] addEntriesFromDictionary:tmp];
                    [cp_slides removeObjectAtIndex:k];
                    break;
                }
            }
        }
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NAV_goToSlide:) name:@"NAV_goToSlide" object:nil];
    
    menu = [[Menu alloc] initWithTree:presentation];
    [self.mainController.view addSubview:menu];
    [self initRootSection];
}

- (void)NAV_goToSlide:(NSNotification *)notification{
    
    
    NSDictionary *dict = nil;
    
    for(int i=0; i<slides.count; i++){
        dict = [slides objectAtIndex:i];
        if([[dict objectForKey:@"id"] isEqualToString:[notification object]]){
            int type = [self checkFileType:[dict objectForKey:@"StartUpFile"]];
            
            switch (type) {
                case 0:
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadPDF" object:[dict objectForKey:@"StartUpFile"]];
                    break;
                case 1:
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changePage" object:[dict objectForKey:@"StartUpFile"]];
                    break;
                default:
                    break;
            }
            
            return;
        }
    }
}



- (int)checkFileType:(NSString *)path{
    
    NSArray *comp = [path componentsSeparatedByString:@"."];
    NSString *ext = [comp objectAtIndex:comp.count-1];
    NSLog(@"ext: %@", ext);
    if([[ext uppercaseString] isEqualToString:@"PDF"])
        return 0;
    else if([[ext uppercaseString] isEqualToString:@"HTML"])
        return 1;
    else return -1;
}

- (void)initRootSection {
    [splashScreen removeFromParentViewController];
    [splashScreen release];
    splashScreen = nil;
        
    self.viewController = [[ViewController alloc] initWithPage:[[[presentation objectAtIndex:0] objectAtIndex:0] objectForKey:@"StartUpFile"]];
    [self.mainController pushViewController:self.viewController animated:NO];
    
    [[TrackManager sharedInstance] traceChangeSection:@"0" required:@"1"];
    NSLog(@"%i",[[TrackManager sharedInstance] enableTracking]);
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if(animationID == @"splashOut") {
		[splashScreen.view removeFromSuperview];
        [splashScreen release];
        splashScreen=nil;
	}
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if(self.restart){
        [[TrackManager sharedInstance] traceStopSession];
        exit(0);
    }
    [[TrackManager sharedInstance] traceMinimize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if(!self.restart){
        EventObject *event = [[EventObject alloc] init];
        event.code = @"80000003";
        event.description = @"Close PI";
        event.type = EVENT_CUSTOM;
        
        NSLog(@"trace: %@",event);
        
        self.restart = YES;
        
        [[TrackManager sharedInstance] traceEvent:event];
    }
    
    [[TrackManager sharedInstance] traceRestore];
    [self dumpLogAuto];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[TrackManager sharedInstance] traceStop];
}

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

//***********

- (void) dumpLog:(id)sender{
    if ([[Reachability  reachabilityWithHostName:[Utils readStoreDataServiceHostName]] currentReachabilityStatus]==0){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"No internet connection available. Please verify your internet connection and retry." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return;
    }
    syncModalUI* syncUI = [[syncModalUI alloc] init];
    syncUI.modalPresentationStyle=2;
    syncUI.modalTransitionStyle=2;
    [self.viewController presentModalViewController:syncUI animated:YES];
    [[TrackManager sharedInstance] postData];
    [[[TrackManager sharedInstance] request] setDownloadProgressDelegate:[syncUI progress]];
    [syncUI release];
}

- (void) dropDataBase:(id)sender{
    [[TrackManager sharedInstance] dropDatabase];
}

- (void) dumpLogAuto {
    @try {
        [[TrackManager sharedInstance] saveOldDB];
        [[TrackManager sharedInstance] postQueuedData];
    }
    @catch (NSException *exception) {
        // DO NOTHING
    }
    @finally {
        // DO NOTHING
    }
}

@end
