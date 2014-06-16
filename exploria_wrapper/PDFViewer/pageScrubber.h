
#import <UIKit/UIKit.h>


@class pageScrubber;

@protocol pageScrubberDelegate <NSObject>
@optional
	- (void)didSelectPage:(NSInteger)index;
	- (void)didScrubPage:(NSInteger)index atPoint:(CGPoint)point;
@end


@interface pageScrubber : UIToolbar <pageScrubberDelegate>
	{
	CGSize thumbSize;
	id <pageScrubberDelegate> delegate;
	int pageCount;
	int selectedIndex;
	int dotWidth;

	UIImage* scrubInactive;
	UIImage* scrubActive;
	UILabel* scrubberLabel;

	UIView* scrubberButtons;
	}

@property (nonatomic, assign) id <pageScrubberDelegate> delegate;

- (id)initWithFrame:(CGRect)frame thumbSize:(CGSize)thumbSz;
- (void)addNodes:(NSInteger)nodeCount;
- (void)highlightButton:(NSInteger)index;
- (void)highlightButton:(NSInteger)index updateLabel:(BOOL)updateLabel;

- (void)createButtonGraphics:(UIButton*)button;
- (void)createScrubberIconsWithColor:(UIColor*)inactiveColor selectedColor:(UIColor*)activeColor;
- (void)scrubToPoint:(CGPoint)point;

- (void)setFrame:(CGRect)frameRect;

@end

