
#import "TilingView.h"
#import <QuartzCore/CATiledLayer.h>


@implementation TilingView

+ (Class)layerClass	{ return [CATiledLayer class]; }


- (id)initWithPDFPage:(CFURLRef)pdfURL index:(NSUInteger)pageIndex
	{
	// load the PDF
	docRef = CGPDFDocumentCreateWithURL(pdfURL);
	pageRef = CGPDFDocumentGetPage(docRef, (pageIndex + 1));
	CGPDFPageRetain(pageRef);
	CGRect pageRect = CGRectIntegral(CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox));
	pageRect.origin.x = 0;
	pageRect.origin.y = 0;

/*
kCGPDFMediaBox = 0,
kCGPDFCropBox = 1,
kCGPDFBleedBox = 2,
kCGPDFTrimBox = 3,
kCGPDFArtBox = 4
*/

	if (self = [super initWithFrame:pageRect])
		{
		// create a tiled view to hold the full size page
		CATiledLayer* tiledLayer = (CATiledLayer *)[self layer];
		tiledLayer.tileSize = CGSizeMake(2048.0, 2048.0);
		tiledLayer.levelsOfDetail = 3;
		tiledLayer.levelsOfDetailBias = 2;
		tiledLayer.frame = pageRect;
		tiledLayer.backgroundColor = [[UIColor clearColor] CGColor];
		}
	return self;
	}


- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
	{
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(ctx, CGContextGetClipBoundingBox(ctx));
    CGContextTranslateCTM(ctx, 0.0, layer.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextConcatCTM(ctx, CGPDFPageGetDrawingTransform(pageRef, kCGPDFCropBox, layer.bounds, 0, true));
    CGContextDrawPDFPage(ctx, pageRef);
	}

- (void)dealloc
	{
	CGPDFPageRelease(pageRef);
	CGPDFDocumentRelease(docRef);
    [super dealloc];
	}


@end
