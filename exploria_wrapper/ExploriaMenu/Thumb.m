//
//  Thumb.m
//  Exploria2.5_wrapper
//
//  Created by Vincenzo Romano on 12/03/13.
//
//

#import "Thumb.h"
#import "VerticalMenu.h"
#import <QuartzCore/QuartzCore.h>

@implementation Thumb

- (id)initWithThumb:(NSString *)path subSections:(NSArray *)sub link:(NSString *)page
{
    self = [super initWithFrame:CGRectMake(0, 0, 100, 80)];
    if (self) {
        self.clipsToBounds = YES;
        pages = sub;
        link = page;
        NSString *img_path = [NSString stringWithFormat:@"%@/Package/phi1/%@",[[NSBundle mainBundle] bundlePath], path];
        thumb = [UIButton buttonWithType:UIButtonTypeCustom];
        thumb.frame = self.frame;
        [thumb setImage:[UIImage imageWithContentsOfFile:img_path] forState:UIControlStateNormal];
        [thumb addTarget:self action:@selector(selectPage:) forControlEvents:UIControlEventTouchUpInside];
        //thumb = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:img_path]];
        [self addSubview:thumb];
        
        arrow = [UIButton buttonWithType:UIButtonTypeCustom];
        [arrow setImage:[UIImage imageNamed:@"arrow.png"] forState:UIControlStateNormal];
        arrow.frame = CGRectMake(65, 0, 40, 40);
        if(sub){
            [arrow addTarget:self action:@selector(toggleSubMenu:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:arrow];
        }else{
            arrow.hidden = YES;
        }
    }
    return self;
}

- (void)selectPage:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changePage" object:link];
    //[self toggleSubMenu:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeMenu" object:nil];
}

- (void)toggleSubMenu:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"toggleVerticalMenu" object:[NSArray arrayWithObjects:pages, [NSNumber numberWithInt:self.frame.origin.x], nil]];
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
