
#import "thumbBox.h"

@implementation thumbBox


- (id)initWithPDFPage:(CFURLRef)pdfURL index:(NSUInteger)pageIndex frame:(CGRect)frame
	{
	docURL = pdfURL;
	pageNumber = pageIndex;

	// create a blank white image as a temporary background
	self = [super initWithFrame:frame];
	self.backgroundColor = [UIColor whiteColor];

	// launch PDF image load in background
	[self retain];
	[self performSelectorInBackground:@selector(drawPDFPage) withObject:nil];
	return self;
	}


- (id)initWithThumbnail:(CGImageRef)thumbnail frame:(CGRect)frame
	{
	// if the thumbnail is ready, use it
	// otherwise just use a blank white page
	if (thumbnail == nil)
		self = [super initWithFrame:frame];
	else
		{
		self = [super initWithImage:[UIImage imageWithCGImage:thumbnail]];
		[self setFrame:frame];
		}

	self.backgroundColor = [UIColor clearColor];
	return self;
	}


- (void)drawPDFPage
	{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	CGPDFDocumentRef docRef = CGPDFDocumentCreateWithURL(docURL);
	CGPDFPageRef pageRef = CGPDFDocumentGetPage(docRef, (pageNumber + 1));
	CGPDFPageRetain(pageRef);
	CGRect pageRect = CGRectIntegral(CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox));

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, pageRect.size.width, pageRect.size.height,
												 8, pageRect.size.width * 4, colorSpace, 
												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
	CGContextTranslateCTM(context, CGRectGetMinX(pageRect), CGRectGetMinY(pageRect));
	CGContextTranslateCTM(context, pageRect.origin.x, pageRect.origin.y);
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextFillRect(context, pageRect);
	CGContextDrawPDFPage(context, pageRef);
	CGPDFPageRelease(pageRef);
	CGPDFDocumentRelease(docRef);

	CGImageRef image = CGBitmapContextCreateImage(context);
	CGContextRelease(context);

	[self performSelectorOnMainThread:@selector(assignImageToImageView:)
						   withObject:[UIImage imageWithCGImage:image] waitUntilDone:YES];
	CGImageRelease(image);
	[pool drain];
	[self performSelectorOnMainThread:@selector(doneLoading) withObject:nil waitUntilDone:NO];
	}


- (void)assignImageToImageView:(UIImage *)img	{ [self setImage:img]; }
- (void)doneLoading								{ [self release]; }
- (void)dealloc									{ [super dealloc]; }


/*
- (void)setFrame:(CGRect)newValue
	{
	NSLog(@"thumbBox setFrame");

//	CGRect modFrame = newValue;
//	modFrame.origin.x += 100;
//	modFrame.origin.y += 100;

//	[super setFrame:modFrame];
	[super setFrame:newValue];
//	[self setNeedsDisplay];
	}


- (void)setBounds:(CGRect)newValue
	{
	NSLog(@"thumbBox setBounds");
	[super setBounds:newValue];
	}


- (void)setCenter:(CGPoint)newValue
	{
	NSLog(@"thumbBox setCenter");
	[super setCenter:newValue];
	}


- (void)setTransform:(CGAffineTransform)newValue
	{
	NSLog(@"thumbBox setTransform");

	CGAffineTransform modTrans = newValue;
//	modTrans.tx += newValue.ty - self.transform.ty;
//	modTrans.ty += newValue.tx - self.transform.tx;
	modTrans.tx += 100;
	modTrans.ty += 100;

	[super setTransform:modTrans];
	//[super setTransform:newValue];
	//[self setNeedsDisplay];
	}
*/

@end
