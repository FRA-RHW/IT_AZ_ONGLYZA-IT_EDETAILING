//
//  Menu.h
//  Exploria2.5_wrapper
//
//  Created by Vincenzo Romano on 12/03/13.
//
//

#import <UIKit/UIKit.h>

@class VerticalMenu;

@interface Menu : UIView{
    UIScrollView *hScroll;
    UIView *container;
    UIButton *toggle;
    VerticalMenu *menu;
    UIImage *img;
    UIImage *img2;
    UIButton *pdfBtn;
}

- (id)initWithTree:(NSArray *)presentation;

@end
