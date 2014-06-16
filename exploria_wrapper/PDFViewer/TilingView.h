
#import <UIKit/UIKit.h>

@interface TilingView : UIView
	{
	CGPDFDocumentRef docRef;
	CGPDFPageRef pageRef;
	}

- (id)initWithPDFPage:(CFURLRef)pdfURL index:(NSUInteger)pageIndex;

@end
