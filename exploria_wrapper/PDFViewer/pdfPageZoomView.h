
#import <UIKit/UIKit.h>
#import "TappableScrollView.h"

@class TappableScrollView;
@class pdfPageZoomView;

@protocol pdfPageZoomViewDelegate <NSObject>
@optional
	- (void)didZoomPage;
	- (void)didDragPage;
@end

@interface pdfPageZoomView : TappableScrollView <UIScrollViewDelegate, pdfPageZoomViewDelegate>
	{
    UIView* pageView;
	CGRect pageRect;
	NSUInteger index;

	int pagePad;

	id <pdfPageZoomViewDelegate> pageDelegate;
	}

@property NSUInteger index;
@property (nonatomic, assign) id <pdfPageZoomViewDelegate> pageDelegate;

- (void)displayTiledPage:(CFURLRef)pdfURL index:(NSUInteger)pageIndex;
- (void)displayTiledPage:(CFURLRef)pdfURL index:(NSUInteger)pageIndex
				thumbnail:(CGImageRef)thumbnail pageFrame:(CGRect)pageFrame;

- (void)configureForImageSize:(CGSize)imageSize;
- (void)updateBounds:(CGRect)newBounds;
- (void)recenterPage;
- (void)resetScale;

@end
