
#import <UIKit/UIKit.h>

@interface thumbBox : UIImageView
	{
	CFURLRef docURL;
	NSUInteger pageNumber;
	}

- (id)initWithPDFPage:(CFURLRef)pdfURL index:(NSUInteger)pageIndex frame:(CGRect)frame;
- (id)initWithThumbnail:(CGImageRef)thumbnail frame:(CGRect)frame;

- (void)drawPDFPage;
- (void)assignImageToImageView:(UIImage *)img;
- (void)doneLoading;

@end
