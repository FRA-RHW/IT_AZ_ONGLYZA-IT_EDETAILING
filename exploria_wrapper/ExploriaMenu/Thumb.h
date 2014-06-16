//
//  Thumb.h
//  Exploria2.5_wrapper
//
//  Created by Vincenzo Romano on 12/03/13.
//
//

#import <UIKit/UIKit.h>

@class VerticalMenu;

@interface Thumb : UIView{
    UIButton *thumb;
    UIButton *arrow;
    NSArray *pages;
    NSString *link;
}

- (id)initWithThumb:(NSString *)path subSections:(NSArray *)sub link:(NSString *)page;

@end
