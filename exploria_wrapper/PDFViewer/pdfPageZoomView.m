
#import "pdfPageZoomView.h"
#import "TilingView.h"
#import "thumbBox.h"

@implementation pdfPageZoomView

@synthesize index;
@synthesize pageDelegate;


- (id)initWithFrame:(CGRect)frame
	{
    if ((self = [super initWithFrame:frame]))
		{
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
		self.backgroundColor = [UIColor clearColor];
		}
	return self;
	}


- (void)dealloc
	{
	[pageView release];
    [super dealloc];
	}


- (void)layoutSubviews
	{
    [super layoutSubviews];
	[self recenterPage];
	}


- (void)recenterPage
	{
    
    // center the image as it becomes smaller than the size of the screen
	CGSize boundsSize = self.bounds.size;
	CGRect frameToCenter = pageView.frame;

	// center horizontally
	if (frameToCenter.size.width < boundsSize.width)
		frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) * 0.5;
	else
		frameToCenter.origin.x = 0;

	// center vertically
	if (frameToCenter.size.height < boundsSize.height)
		frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) * 0.5;
	else
		frameToCenter.origin.y = 0;

	pageView.frame = frameToCenter;

	// disable scrolling when at the minumum zoom scale
	// (since we are cropping out the drop shadow portion of the page view at minScale)
	if (self.zoomScale == self.minimumZoomScale)
		{
		CGPoint newOffset = CGPointZero;
		if (frameToCenter.size.width > boundsSize.width)
			newOffset.x = (frameToCenter.size.width - boundsSize.width) * 0.5;
		if (frameToCenter.size.height > boundsSize.height)
			newOffset.y = (frameToCenter.size.height - boundsSize.height) * 0.5;
		self.contentOffset = newOffset;
		self.scrollEnabled = NO;
		}
	else
		self.scrollEnabled = YES;
	}


- (void)updateBounds:(CGRect)newBounds
	{
	BOOL minScale = NO;
	if (self.zoomScale == self.minimumZoomScale)
		minScale = YES;

	[self setFrame:newBounds];

	// update the minimum zoom scale to match the new frame
	CGFloat widthRatio = newBounds.size.width / (pageRect.size.width - 2 * pagePad);
	CGFloat heightRatio = newBounds.size.height / (pageRect.size.height - 2 * pagePad);
	self.minimumZoomScale = MIN(widthRatio, heightRatio);

	if ((self.zoomScale < self.minimumZoomScale) || minScale)
		{
		self.zoomScale = self.minimumZoomScale;
		[self recenterPage];
		}
	}


- (void)resetScale
	{
	// update the minimum zoom scale to match the new frame
	CGFloat widthRatio = self.frame.size.width / (pageRect.size.width - 2 * pagePad);
	CGFloat heightRatio = self.frame.size.height / (pageRect.size.height - 2 * pagePad);
	self.minimumZoomScale = MIN(widthRatio, heightRatio);
	self.zoomScale = self.minimumZoomScale;
	[self recenterPage];
	}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
	{
    return pageView;
	}


- (void)configureForImageSize:(CGSize)imageSize 
	{
    CGSize boundsSize = [self bounds].size;

    // set up our content size and min/max zoomscale
    CGFloat xScale = boundsSize.width / (imageSize.width - 2 * pagePad);	// the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / (imageSize.height - 2 * pagePad);	// the scale needed to perfectly fit the image height-wise

	CGFloat minScale = MIN(xScale, yScale);		// use minimum of these to allow the image to become fully visible
	CGFloat maxScale = 5.0;

    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.) 
    if (minScale > maxScale)
        minScale = maxScale;

	self.contentSize = imageSize;
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;  // start out with the content fully visible
	self.contentOffset = CGPointZero;
	self.contentInset = UIEdgeInsetsZero;
	}


- (void)displayTiledPage:(CFURLRef)pdfURL index:(NSUInteger)pageIndex
	{
	// clear the previous pageView
	// (in case this is being recycled)
	[pageView removeFromSuperview];
	[pageView release];
	pageView = nil;

	// reset our zoomScale to 1.0 before doing any further calculations
	self.zoomScale = 1.0;

	// load the PDF
	CGPDFDocumentRef pdfDoc = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	CGPDFPageRef pageRef = CGPDFDocumentGetPage(pdfDoc, (pageIndex + 1));
	CGPDFPageRetain(pageRef);
	pageRect = CGRectIntegral(CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox));
	CGPDFPageRelease(pageRef);
	CGPDFDocumentRelease(pdfDoc);

	// create a low res image layer under a tiled layer
	pageView = [[thumbBox alloc] initWithPDFPage:pdfURL index:pageIndex frame:pageRect];

	pagePad = 0;
	TilingView* tiledView = [[TilingView alloc] initWithPDFPage:pdfURL index:pageIndex];
	[pageView addSubview:tiledView];
	[tiledView release];

	[self addSubview:pageView];
	[self configureForImageSize:pageRect.size];
	}


- (void)displayTiledPage:(CFURLRef)pdfURL index:(NSUInteger)pageIndex
				thumbnail:(CGImageRef)thumbnail pageFrame:(CGRect)pageFrame
	{
	// clear the previous pageView
	// (in case this is being recycled)
	[pageView removeFromSuperview];
	[pageView release];
	pageView = nil;

	// reset our zoomScale to 1.0 before doing any further calculations
	self.zoomScale = 1.0;
	pageRect = pageFrame;

	// create a low res image layer under a tiled layer
	pageView = [[thumbBox alloc] initWithThumbnail:thumbnail frame:pageRect];
	//pageView = [[UIView alloc] initWithFrame:pageRect];
	//pageView.backgroundColor = [UIColor grayColor];

	TilingView* tiledView = [[TilingView alloc] initWithPDFPage:pdfURL index:pageIndex];

	// make room for padding
	pagePad = rint(3 * pageRect.size.height / (CGImageGetHeight(thumbnail) - 6)) - 2;
	[tiledView setFrame:CGRectMake(tiledView.frame.origin.x + pagePad,
								   tiledView.frame.origin.y + pagePad,
								   tiledView.frame.size.width - 2 * pagePad,
								   tiledView.frame.size.height - 2 * pagePad)];
	[pageView addSubview:tiledView];
	[tiledView release];

	[self addSubview:pageView];
	[self configureForImageSize:pageRect.size];
	}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
	{
	[pageDelegate didZoomPage];
	}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
	{
	[pageDelegate didDragPage];
	}

/*
- (void)setTransform:(CGAffineTransform)newValue
	{
	NSLog(@"scroll UIView setTransform");
	[super setTransform:newValue];
//	[self setNeedsDisplay];
	}
*/
/*
- (void)setFrame:(CGRect)newValue
	{
	NSLog(@"pageZoomView setFrame");

	//	CGRect modFrame = newValue;
	//	modFrame.origin.x += 100;
	//	modFrame.origin.y += 100;

	[super setFrame:newValue];
	//	[super setFrame:newValue];
	//	[self setNeedsDisplay];
	}


- (void)setBounds:(CGRect)newValue
{
	NSLog(@"pageZoomView setBounds");
	[super setBounds:newValue];
}


- (void)setCenter:(CGPoint)newValue
{
	NSLog(@"pageZoomView setCenter");
	[super setCenter:newValue];
}


- (void)setTransform:(CGAffineTransform)newValue
{
	NSLog(@"pageZoomView setTransform");
	
//	CGAffineTransform modTrans = newValue;
	//	modTrans.tx += newValue.ty - self.transform.ty;
	//	modTrans.ty += newValue.tx - self.transform.tx;
//	modTrans.tx += 100;
//	modTrans.ty += 100;
	
//	[super setTransform:modTrans];
	[super setTransform:newValue];
	//[self setNeedsDisplay];
}
*/

@end
