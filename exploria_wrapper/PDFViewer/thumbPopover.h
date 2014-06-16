
#import <UIKit/UIKit.h>

@interface thumbPopover : UIView
	{
	UIImageView* backgroundImage;
	UIImageView* previewImage;
	UILabel* previewLabel;
	int maxThumbDim;
	}

- (void)goToPage:(NSInteger)index withPreviewImage:(CGImageRef)pagePreview andLabel:(NSString*)pageLabel;
- (void)setAnchor:(CGPoint)point;
- (void)updateBackground;

@end
