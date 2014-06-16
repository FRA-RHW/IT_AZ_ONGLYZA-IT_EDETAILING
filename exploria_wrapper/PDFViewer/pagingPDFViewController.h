
#import <UIKit/UIKit.h>
#import "pageScrubber.h"
#import "pdfPageZoomView.h"
#import "TappableScrollView.h"
#import "thumbPopover.h"
#import "TOCpopup.h"

@class TappableScrollView;
@class pdfPageZoomView;

@interface pagingPDFViewController : UIViewController <UIScrollViewDelegate, pageScrubberDelegate, 
														pdfPageZoomViewDelegate, TOCpopupDelegate>
{
	NSString* fileName;
	NSString* title;

	TappableScrollView* pagingScrollView;

	NSMutableSet* recycledPages;
	NSMutableSet* visiblePages;

	NSUInteger pageCount;
	CGRect* pageRects;
	CGImageRef* pagePreviews;
	thumbPopover* thumbPopup;
	TOCpopup* TOCview;

	UIToolbar* header;
	UILabel* headerLabel;
	pageScrubber* thumbMenu;
	bool toolbarsOn;

	CFURLRef pdfURL;
	int thumbDone;
	int thumbHeight;
        
    int offSetPage;

	UIButton* leftArrow;
	UIButton* rightArrow;
}

@property (nonatomic, retain) NSMutableSet* recycledPages;
@property (nonatomic, retain) NSMutableSet* visiblePages;
@property (nonatomic)  int offSetPage;

- (id)initWithPDFFile:(NSString*)file title:(NSString*)pdfTitle atPage:(NSString*) pageNum;

- (void)tilePages;
- (void)tilePageRange:(NSUInteger)startIndex endIndex:(NSUInteger)endIndex;
- (void)configurePage:(pdfPageZoomView*)page forIndex:(NSUInteger)index;
- (pdfPageZoomView*)dequeueRecycledPage;

- (CGRect)frameForUIView;
- (CGRect)frameForPagingScrollView:(UIInterfaceOrientation)interfaceOrientation;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (int)currentPage;
- (void)gotoPage:(NSInteger)index;

- (void)readPDF_TOC:(CGPDFDocumentRef)docRef;
- (void)readPDF_TOC_Items:(CGPDFDocumentRef)document outline:(CGPDFDictionaryRef)outline level:(int)level;
- (void)readPDF_TOC_Item:(int)level title:(CFStringRef)title isOpen:(bool)isOpen;
static NSInteger PageNumberFromPageDictionary(CGPDFDictionaryRef target);

- (void)genPDFthumbs;
CGImageRef genPDFThumbnail(CGPDFPageRef page, CGRect pageRect, int thumbSide);
- (void)updateInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

- (void)toggleToolbars;
- (void)hideToolbars;
- (void)showToolbars;

- (void)backAction:(id)sender;
- (void)tocAction;
/*
- (void)enableArrows;
- (void)disableArrows;
- (void)leftArrowClicked;
- (void)rightArrowClicked;
*/
@end
