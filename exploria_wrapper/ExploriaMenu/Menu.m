//
//  Menu.m
//  Exploria2.5_wrapper
//
//  Created by Vincenzo Romano on 12/03/13.
//
//

#import "Menu.h"
#import "Thumb.h"
#import "VerticalMenu.h"
#import "AppDelegate.h"

@interface Menu (){

    AppDelegate *app;
}

@end

@implementation Menu

- (id)initWithTree:(NSArray *)presentation{
    self = [super initWithFrame:CGRectMake(0, 0, 1024, 768)];
    app=(AppDelegate *)[UIApplication sharedApplication].delegate;
    if (self) {
        container = [[UIView alloc] initWithFrame:CGRectMake(0, 768, 1024, 88)];
        
        
        pdfBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        pdfBtn.frame=CGRectMake(860, 5, 48, 38);
        //pdfBtn.backgroundColor=[UIColor redColor];
        img=[UIImage imageNamed:@"rcpPdf.png"];
        img2=[UIImage imageNamed:@"rcpPdfK.png"];
        [pdfBtn setImage:img forState:UIControlStateNormal];
        [pdfBtn addTarget:self action:@selector(openPresentationPdf:) forControlEvents:UIControlEventTouchUpInside];
        
        toggle = [UIButton buttonWithType:UIButtonTypeCustom];
        toggle.frame = CGRectMake(920, 680, 110, 88);
        [toggle addTarget:self action:@selector(toggleMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        hScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 850, 88)];
        
        Thumb *tmp = nil;
        float offX = 5;
        for(int i=0; i<presentation.count; i++){
            NSArray *section = [presentation objectAtIndex:i];
            NSArray *ss = (section.count > 1) ? section : nil;
            tmp = [[Thumb alloc] initWithThumb:[[section objectAtIndex:0] objectForKey:@"Thumbnail"] subSections:ss link:[[section objectAtIndex:0] objectForKey:@"StartUpFile"]];
            tmp.frame = CGRectMake(offX, 4, 100, 80);
            offX+=110;
            [hScroll addSubview:tmp];
        }
        hScroll.contentSize = CGSizeMake(offX, 88);
        [container addSubview:hScroll];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleSubMenu:) name:@"toggleVerticalMenu" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeMenu:) name:@"closeMenu" object:nil];
        
        [container addSubview:pdfBtn];
        [self addSubview:container];
        [self addSubview:toggle];
    }
    return self;
}

- (void)closeMenu:(NSNotification *)notification{
    toggle.userInteractionEnabled = NO;
    [self closeSubMenu];
    [UIView animateWithDuration:0.3 animations:^{
        container.frame = CGRectMake(0, 768, 1024, 88);
    } completion:^(BOOL finished) {
        toggle.userInteractionEnabled = YES;
    }];
}

- (void)toggleMenu:(id)sender{
     [self closeSubMenu];
    toggle.userInteractionEnabled = NO;
    if(app.indexForPdf<31){
    
        [pdfBtn setImage:img forState:UIControlStateNormal];
    }else{
        [pdfBtn setImage:img2 forState:UIControlStateNormal];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        container.frame = CGRectMake(0, (container.frame.origin.y==768) ? 680 : 768, 1024, 88);
    } completion:^(BOOL finished) {
        toggle.userInteractionEnabled = YES;
        
    }];
}

- (void)toggleSubMenu:(NSNotification *)notification{
    NSArray *pages = [[notification object] objectAtIndex:0];
    int offX = [[[notification object] objectAtIndex:1] integerValue];
    if(!menu){
        [hScroll setScrollEnabled:NO];
        menu = [[VerticalMenu alloc] initSection:pages];
        menu.frame = CGRectMake(offX-hScroll.contentOffset.x, 5, 100, 680);
        [self addSubview:menu];
    }else{
        [self closeSubMenu];
    }
}

- (void)closeSubMenu{
    if(!menu) return;
    [hScroll setScrollEnabled:YES];
    [menu removeFromSuperview];
    menu = nil;
}

-(void)openPresentationPdf:(id)sender{
    
    if(app.indexForPdf<31){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NAV_goToSlide" object:@"2DE8FB96-2165-B57F-5BBE-201310044158"];
    }else{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NAV_goToSlide" object:@"642911FC-FA6F-0EB6-BBD7-201310044187"];
    }

    [self toggleMenu:self];
    
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        if (!view.hidden && view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event]){
            return YES;
        }
    }
    [self closeSubMenu];
    return NO;
}

@end
