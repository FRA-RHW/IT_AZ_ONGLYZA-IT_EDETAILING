//
//  ViewController.m
//  exploria_wrapper
//
//  Created by AZuk on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "pagingPDFViewController.h"
#import "Disclaimer.h"
#import "TrackManager.h"
#import "ESPParseRequest.h"

@interface ViewController (){
    
    AppDelegate *app;
}

@end

@implementation ViewController
extern const int EVENT_INFO;
extern const int EVENT_DEBUG;
extern const int EVENT_WARNING;
extern const int EVENT_EXCEPTION;
extern const int EVENT_SYSTEM;
extern const int EVENT_CUSTOM;

@synthesize wv;
@synthesize isLocal;

@synthesize prevPage;
@synthesize currentPage;
@synthesize mediaPlaybackRequiresUserAction;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (id) initWithPage:(NSString *)page{
    self = [super init];
    if(self){
        self.currentPage = page;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isLocal=NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCurrentPage:) name:@"setCurrentPage" object:nil];
    
    spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(512-25, 384-25, 50, 50)];
    [spinner setColor:[UIColor grayColor]];
    
    wv = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    wv.delegate = self;
    
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(polling:) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePage:) name:@"changePage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPDF:) name:@"loadPDF" object:nil];
    
    [self loadPage:self.currentPage];
    
    
    
    [self.view addSubview:wv];
    [self.view addSubview:spinner];

}

- (void)polling:(NSTimer *)timer{
    int length = [[wv stringByEvaluatingJavaScriptFromString:@"CCAPI.CallToESPQueue.length;"] integerValue];
    for(int i = 0; i<length; i++){
        ESPParseRequest *xml = [[ESPParseRequest alloc] initESPRequest:[wv stringByEvaluatingJavaScriptFromString:@"CCAPI.CallToESPQueue.pop().XmlRequest;"]];
        [self checkRequest:[xml getRequestArgs]];
    }
}

- (void)checkRequest:(NSDictionary *)req{
    if([[req objectForKey:@"name"] isEqualToString:@"NAV_goToSlide"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NAV_goToSlide" object:[req objectForKey:@"id"]];
    }
}

- (void)changePage:(NSNotification *)notification{
    [self loadPage:[notification object]];
}

- (void)loadPage:(NSString *)page{
    NSString *filePath = [NSString stringWithFormat:@"%@/Package/phi1/%@",[[NSBundle mainBundle] bundlePath], page];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]];
    wv.mediaPlaybackRequiresUserAction=NO;
    [wv loadRequest:req];
}

-(void) webViewDidStartLoad:(UIWebView *)webView{
    [spinner startAnimating];
}

-(void) webViewDidFinishLoad:(UIWebView *)webView{
    [spinner stopAnimating];
    
    
    /*if (!isLocal){ 
        isLocal=!isLocal;
     
        [self performSelector:@selector(delaydCall) withObject:nil afterDelay:0.2f];
        
     }*/
    
}

/*- (void) delaydCall{
    [wv stringByEvaluatingJavaScriptFromString:@"localStorage.removeItem('tol');"];
    [wv stringByEvaluatingJavaScriptFromString:@"drcom.navigator.hideMenu(true);"];
}*/


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"req: %@", [request URL]);
    
    NSString *tmp=[[[[[[request URL] absoluteString] componentsSeparatedByString:@"/assets/slide"] objectAtIndex:1] componentsSeparatedByString:@"/index.html"]objectAtIndex:0];
    
    app=(AppDelegate *)[UIApplication sharedApplication].delegate;
    app.indexForPdf=[tmp integerValue];
    
    self.currentPage=[[[[request URL] absoluteString] componentsSeparatedByString:@"/Package/"] objectAtIndex:1];
    
    if([[TrackManager sharedInstance] enableTracking]){
        [[TrackManager sharedInstance] traceChangePage:@"" required:self.currentPage];
        NSLog(@"trace changePage: %@",self.currentPage);
    }
    
    
    
    if([[request.URL scheme] isEqualToString:@"ios"]){
        
        /*if([[request.URL host] isEqualToString:@"openPDF"]){
            
            NSString *arguments = [request.URL query];
            NSArray *arg = [arguments componentsSeparatedByString:@"&"];
            NSString *fileName = [[[arg objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1];
            
            [[TrackManager sharedInstance] traceOpenPdf:fileName title:nil];
            NSLog(@"trace openPDF: %@", fileName);
            [self openPDF:fileName];
            
            return NO;
        }*/
        
        if([[request.URL host] isEqualToString:@"trackChangePage"]){
            if([[TrackManager sharedInstance] enableTracking]){
                NSString *arguments = [request.URL query];
                NSArray *arg = [arguments componentsSeparatedByString:@"&"];
                NSString *page = [[[arg objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1];
                
                [[TrackManager sharedInstance] traceChangePage:@"" required:page];
                self.currentPage = page;
                NSLog(@"trace changePage: %@",self.currentPage);
            }
            return NO;
        }
        
        if([[request.URL host] isEqualToString:@"trackLogin"]){
            if([[TrackManager sharedInstance] enableTracking]){
                NSString *arguments = [request.URL query];
                NSArray *arg = [arguments componentsSeparatedByString:@"&"];
                NSString *label = [[[arg objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1];
            
                EventObject *event = [[EventObject alloc] init];
                event.code = @"80000001";
                event.description = label;
                event.type = EVENT_CUSTOM;
            
                NSLog(@"trace: %@",event);
            
                [[TrackManager sharedInstance] traceEvent:event];
            }
            return NO;
        }
    }
    
       
    return YES;
}

- (void)loadPDF:(NSNotification *)notification{
    [self openPDF:[notification object]];
}

- (void) openPDF:(NSString *)fileName{
    
    //NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"pdf" inDirectory:@"WWW/project/resources/pdf"];
    NSString *path = [NSString stringWithFormat:@"%@/Package/phi1/%@",[[NSBundle mainBundle] bundlePath], fileName];
    NSString *pathForPdf=[[path componentsSeparatedByString:@"/Package/"] objectAtIndex:1];
    
    [[TrackManager sharedInstance] traceChangePage:@"PDF" required:pathForPdf];
    pagingPDFViewController *pdf = [[pagingPDFViewController alloc] initWithPDFFile:path title:@"PDF" atPage:0];
    [self presentModalViewController:pdf animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [wv release];
    wv = nil;
    
        
    [spinner release];
    spinner = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown && interfaceOrientation != UIInterfaceOrientationPortrait);
}

@end
