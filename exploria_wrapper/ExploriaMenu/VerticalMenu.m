//
//  VerticalMenu.m
//  Exploria2.5_wrapper
//
//  Created by Vincenzo Romano on 13/03/13.
//
//

#import "VerticalMenu.h"
#import "Thumb.h"

@implementation VerticalMenu

- (id)initSection:(NSArray *)sub {
    self = [super initWithFrame:CGRectMake(0, -105, 100, 0)];
    if (self) {
        //self.backgroundColor = [UIColor redColor];
        NSLog(@"%@", sub);
        
        float offY = 680;
        vScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 680, 100, 0)];
        
        Thumb *tmp = nil;
        
        tmp = [[Thumb alloc] initWithThumb:[[sub objectAtIndex:0] objectForKey:@"Thumbnail"] subSections:nil link:[[sub objectAtIndex:0] objectForKey:@"StartUpFile"]];
        tmp.frame = CGRectMake(0, offY, 100, 80);
        offY-=85;
        [vScroll addSubview:tmp];
        
        for(int i=sub.count-1; i>0; i--){
            tmp = [[Thumb alloc] initWithThumb:[[sub objectAtIndex:i] objectForKey:@"Thumbnail"] subSections:nil link:[[sub objectAtIndex:i] objectForKey:@"StartUpFile"]];
            tmp.frame = CGRectMake(0, offY, 100, 80);
            offY-=85;
            [vScroll addSubview:tmp];
        }
        [self addSubview:vScroll];
        
        [UIView animateWithDuration:0.5 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            vScroll.frame = CGRectMake(0, 0, 100, 680);
        } completion:^(BOOL finished) {}];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
