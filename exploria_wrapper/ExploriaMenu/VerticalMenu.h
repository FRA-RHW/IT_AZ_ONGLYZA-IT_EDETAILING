//
//  VerticalMenu.h
//  Exploria2.5_wrapper
//
//  Created by Vincenzo Romano on 13/03/13.
//
//

#import <UIKit/UIKit.h>

@interface VerticalMenu : UIView{
    UIScrollView *vScroll;
}

- (id)initSection:(NSArray *)sub;

@end
