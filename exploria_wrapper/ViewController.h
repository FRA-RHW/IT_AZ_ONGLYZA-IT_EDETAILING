//
//  ViewController.h
//  exploria_wrapper
//
//  Created by AZuk on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ESPTask;

@interface ViewController : UIViewController<UIWebViewDelegate>{
    UIActivityIndicatorView *spinner;
    ESPTask *esp;
}

@property (nonatomic, retain) UIWebView *wv;

@property (nonatomic, retain) NSString *prevPage;
@property (nonatomic, retain) NSString *currentPage;
@property(nonatomic) BOOL mediaPlaybackRequiresUserAction;
@property(nonatomic) BOOL isLocal;

- (id) initWithPage:(NSString *)page;
- (void) openPDF:(NSString *)fileName;


@end
