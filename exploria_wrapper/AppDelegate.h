//
//  AppDelegate.h
//  exploria_wrapper
//
//  Created by AZuk on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;
@class MainController;
@class Splash;
@class Disclaimer;
@class Menu;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    Splash *splashScreen;
    BOOL disclaimerShowed;
    Menu *menu;
    NSMutableArray *presentation, *slides;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) MainController *mainController;
@property (nonatomic) BOOL restart;
@property (nonatomic) int indexForPdf;


- (void) dumpLog:(id)sender;
- (int)checkFileType:(NSString *)path;

@end
