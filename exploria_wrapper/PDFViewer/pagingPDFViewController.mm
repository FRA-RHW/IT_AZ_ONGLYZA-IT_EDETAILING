
#import "pagingPDFViewController.h"
//#import "TrackManager.h"

@implementation pagingPDFViewController

@synthesize recycledPages, visiblePages,offSetPage;

#define PADDING		50	// amount of blank space between pages
#define PAGECACHE	0	// number of pages to buffer on either side of the current page
#define DOCCLEAR	5	// max number of pages to load before reloading the PDF (memory bug)


- (id)initWithPDFFile:(NSString*)file title:(NSString*)pdfTitle atPage:(NSString*) pageNum
{
#ifdef DEBUG
    NSLog(@"initWithPDFFile: %@ title: %@", file, pdfTitle); 
#endif 	
    
    fileName = file;
	title = [pdfTitle stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	leftArrow = nil;
	rightArrow = nil;
	self.offSetPage=[pageNum intValue];
    return [self init];
}


- (void)loadView
{
	// init some storage
	self.recycledPages = [NSMutableSet setWithCapacity:0];
	self.visiblePages  = [NSMutableSet setWithCapacity:0];
    
	// load the PDF
    
#ifdef DEBUG
    NSLog(@"pagingPDFController loadView: %@", fileName);
#endif
    
    //pdfURL = CFURLCreateWithString(NULL, (CFStringRef)fileName, NULL);
   pdfURL = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)fileName, kCFURLPOSIXPathStyle, FALSE);
    
	CGPDFDocumentRef pdfDoc = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	pageCount = CGPDFDocumentGetNumberOfPages(pdfDoc);
    
	pageRects = new CGRect[pageCount];
	pagePreviews = new CGImageRef[pageCount];
    
	for (int index = 0; index < pageCount; index++)
    {
		CGPDFPageRef pageRef = CGPDFDocumentGetPage(pdfDoc, (index + 1));
		pageRef = CGPDFPageRetain(pageRef);
		pageRects[index] = CGRectIntegral(CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox));
        
		if (index <= PAGECACHE)
			pagePreviews[index] = genPDFThumbnail(pageRef, pageRects[index], 200);
        
		CGPDFPageRelease(pageRef);
    }
	thumbDone = PAGECACHE + 1;
    
	// add a Table of Contents view
	TOCview = [[TOCpopup alloc] initWithFrame:CGRectZero];
	[TOCview setHidden:YES];
	[TOCview setAnchor:CGPointMake(1024, 0)];
	TOCview.delegate = self;
    
	if (!CGPDFDocumentIsEncrypted(pdfDoc))
		[self readPDF_TOC:pdfDoc];
	CGPDFDocumentRelease(pdfDoc);
    
    // create a scrollview to handle paging behaviors
	
    
    
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView:self.interfaceOrientation];
    
    
    
    //FIX IOS 5
    //CGRect pagingScrollViewFrame=CGRectMake(0, 0, 1024, 768);
    
    
    pagingScrollView = [[TappableScrollView alloc] initWithFrame:pagingScrollViewFrame];
    
    
    pagingScrollView.pagingEnabled = YES;
	pagingScrollView.backgroundColor = [UIColor clearColor];
    pagingScrollView.showsVerticalScrollIndicator = NO;
    pagingScrollView.showsHorizontalScrollIndicator = NO;
    pagingScrollView.contentSize = CGSizeMake(pagingScrollViewFrame.size.width * pageCount,
                                              pagingScrollViewFrame.size.height);
    pagingScrollView.delegate = self;
    
	// set up the view hierarchy
	// (parent view, background image, pdf, thumbnail menu)
	self.view = [[UIView alloc] initWithFrame:[self frameForUIView]];
    
	// to set a colored background
	// !TNG! change this to be more adaptable
	self.view.backgroundColor = [UIColor whiteColor];
	//self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.65 blue:0.9 alpha:1.0];
	//self.view.backgroundColor = [UIColor grayColor];
    
	// to set a background image
	//NSString* backgroundFile = [NSString stringWithFormat:@"%@/back3.jpg", [[NSBundle mainBundle] resourcePath]];
	//UIImage* backIm = [UIImage imageWithContentsOfFile:backgroundFile];
	//UIImageView* backgroundImage = [[UIImageView alloc] initWithImage:backIm];
	//[self.view addSubview:backgroundImage];
	//[backgroundImage release];
    
	[self.view addSubview:pagingScrollView];
    
	// add left/right page buttons for easier navigation during videoOut
    //	if ([[UIApplication sharedApplication] isScreenMirroringActive])
    //		[self enableArrows];
    
	[self.view addSubview:TOCview];
	
    [TOCview reframe:self.interfaceOrientation];
    
	// create a header bar
	
    
    header = [UIToolbar new];
    
    
    
	// [header setBarStyle:UIBarStyleBlack];
    [header setBarStyle:UIBarStyleDefault];
    
    
	//[header setFrame:CGRectMake(0, 0, self.view.frame.size.width, 43)];
    
    [header setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, 43)];
    [header setNeedsLayout];
    
    //IOS 5 fix**********************************
    //[header setFrame:CGRectMake(0, 0, 1024, 43)];
    //*******************************************
    
	//[header setTranslucent:YES];
	//[header setTintColor:[UIColor redColor]];
	[self.view addSubview:header];
    
	UIButton* backButton = [UIButton buttonWithType:(UIButtonType)101];
	
    //[backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
	[backButton setTitle:@"Close" forState:UIControlStateNormal];
	UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	[backButton release];
    
	UIBarButtonItem* tocItem = [[UIBarButtonItem alloc] initWithTitle:@"Table of Contents" style:UIBarButtonItemStyleBordered target:self action:@selector(tocAction)];
	if ([TOCview.bookmarks count] == 0)
		tocItem.enabled = false;
	UIBarButtonItem* flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
	[header setItems:[NSArray arrayWithObjects:backItem, flexSpace, tocItem, nil]];
	[backItem release];
	[flexSpace release];
	[tocItem release];
    
	// add a header label over the toolbar
	
    CGFloat xPos = 0.5 * (self.view.frame.size.width - 510);
	
    headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPos, 0, 510, 43)];
    
    //headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frameForUIView.size.width*.5, 0, 510, 43)];
    
    [headerLabel setTextAlignment:UITextAlignmentCenter];
	[headerLabel setBackgroundColor:[UIColor clearColor]];
    headerLabel.adjustsFontSizeToFitWidth=YES;
	[headerLabel setText:title];
	
    
    
    
    // [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setTextColor:[UIColor blackColor]];
    
	[headerLabel setFont:[UIFont boldSystemFontOfSize:22.0]];
	[headerLabel setShadowColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
	[headerLabel setShadowOffset:CGSizeMake(0, 1.0)];
	
    //FIX IOS5 reset the center of the heaferLabel
    headerLabel.center=CGPointMake((1024-510), headerLabel.center.y);
    
    [self.view addSubview:headerLabel];
    
	// add a blank thumbnail scrubber
	thumbHeight = 120;
	
    
    //IOS5 FIX 
    /*CGRect thumbMenuFrame = CGRectMake(self.view.frame.origin.x,
									   self.view.frame.origin.y + self.view.frame.size.height - 43,
									   self.view.frame.size.width,
									   43);
	*/
    
    
    CGRect thumbMenuFrame = CGRectMake(0,
									   768-43,
									   1024,
									   43);
    
    CGSize thumbSize = CGSizeMake(thumbHeight, thumbHeight);
    
    
    //NSLog(@"THUMB FRAME x:%f y:%f w:%f h:%f",thumbMenuFrame.origin.x,thumbMenuFrame.origin.y, thumbMenuFrame.size.width,thumbMenuFrame.size.height);
    
	thumbMenu = [[pageScrubber alloc] initWithFrame:thumbMenuFrame thumbSize:thumbSize];
	thumbMenu.delegate = self;
	[thumbMenu setTranslucent:YES];
	[thumbMenu setTintColor:[UIColor whiteColor]];
	[thumbMenu addNodes:pageCount];
	[thumbMenu highlightButton:0];
	[self.view addSubview:thumbMenu];
    
	thumbPopup = [[thumbPopover alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
	[thumbPopup setHidden:YES];
	[self.view addSubview:thumbPopup];
    
	// launch background thread to generate page thumbnails
	 
    
    [self performSelectorInBackground:@selector(genPDFthumbs) withObject:nil];
    
	// start displaying the PDF
	[self tilePages];
    
	toolbarsOn = true;
    
    if (self.offSetPage>1){
        [self didSelectPage:self.offSetPage-1];
    }
}

- (void)viewWillAppear:(BOOL)animated{ [self.view setNeedsDisplay];}

-(int)currentPage
{
	// Calculate which page is visible
	CGFloat pageWidth = pagingScrollView.frame.size.width;
	int page = floor((pagingScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	return page;
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// force landscape right orientation when mirroring
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) return YES;
    
	return NO;
    
  /*   if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
     return YES;
     else
     return NO;
   
   */
     
}


- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
	// Release any cached data, images, etc that aren't in use.
	[recycledPages removeAllObjects];
    
	//NSLog(@"didReceiveMemoryWarning : view controller");
}


- (void)viewDidUnload
{
	[super viewDidUnload];
	[header release];
	header = nil;
	[headerLabel release];
	headerLabel = nil;
	[thumbMenu release];
	thumbMenu = nil;
	[thumbPopup release];
	thumbPopup = nil;
	[pagingScrollView release];
	pagingScrollView = nil;
}


- (void)dealloc
{
	if (pageRects)
		delete pageRects;
	if (pagePreviews)
    {
		for (int i = 0; i < pageCount; i++)
			if (pagePreviews[i] != nil)
				CGImageRelease(pagePreviews[i]);
		delete pagePreviews;
    }
	CFRelease(pdfURL);
    
	self.recycledPages = nil;
	self.visiblePages = nil;
    
	[super dealloc];
}


- (CGRect)frameForPagingScrollView:(UIInterfaceOrientation)interfaceOrientation
{
	CGRect frame = [[UIScreen mainScreen] bounds];
	CGFloat screenWidth;
	CGFloat screenHeight;
    
	if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
		|| (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
    {
		// mainScreen bounds values do not rotate with interfaceOrientation
		// (so we need to swap the values to respond logically)
		screenWidth = frame.size.height;
		screenHeight = frame.size.width;
    }
	else
    {
		screenWidth = frame.size.width;
		screenHeight = frame.size.height;
    }
    
	frame.size.width = screenWidth + 2 * PADDING;
	frame.size.height = screenHeight;
	frame.origin.x = - PADDING;
	frame.origin.y = 0;
    
   
    
    
	return frame;
}


- (CGRect)frameForPagingScrollView
{
	CGRect frame = [[UIScreen mainScreen] bounds];
	frame.origin.x -= PADDING;
	frame.size.width += (2 * PADDING);
    return frame;
}


- (CGRect)frameForUIView
{
	CGRect frame = [[UIScreen mainScreen] bounds];
    return frame;
}


- (void)tilePages
{
    // Calculate which pages are visible (buffer pages on each side of visible)
    CGRect visibleBounds = pagingScrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
	firstNeededPageIndex = MAX(firstNeededPageIndex - PAGECACHE, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex + PAGECACHE, pageCount - 1);
	[self tilePageRange:firstNeededPageIndex endIndex:lastNeededPageIndex];
}


// tilePages between indices
- (void)tilePageRange:(NSUInteger)startIndex endIndex:(NSUInteger)endIndex
{
	// remove the no-longer-visible pages
	for (pdfPageZoomView* page in visiblePages)
    {
		if (page.index < startIndex || page.index > endIndex)
        {
			[recycledPages addObject:page];
			[page removeFromSuperview];
        }
    }
	[visiblePages minusSet:recycledPages];
    
    // add missing pages
    for (int index = startIndex; index <= endIndex; index++)
    {
        if (![self isDisplayingPageForIndex:index])
        {
            pdfPageZoomView* page = [self dequeueRecycledPage];
            if (page == nil)
                page = [[[pdfPageZoomView alloc] init] autorelease];
            
            [self configurePage:page forIndex:index];
            [pagingScrollView addSubview:page];
			[visiblePages addObject:page];
        }
    }
}


- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    BOOL foundPage = NO;
    for (pdfPageZoomView* page in visiblePages)
    {
        if (page.index == index)
        {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}


- (pdfPageZoomView*)dequeueRecycledPage
{
    pdfPageZoomView* page = [recycledPages anyObject];
    if (page)
    {
        [[page retain] autorelease];
        [recycledPages removeObject:page];
    }
    return page;
}


- (void)configurePage:(pdfPageZoomView*)page forIndex:(NSUInteger)index
{
    page.index = index;
    page.frame = [self frameForPageAtIndex:index];
	page.pageDelegate = self;
    
	if (thumbDone > index)
		[page displayTiledPage:pdfURL index:index thumbnail:pagePreviews[index] pageFrame:pageRects[index]];
	else
		[page displayTiledPage:pdfURL index:index thumbnail:nil pageFrame:pageRects[index]];
}


- (CGRect)frameForPageAtIndex:(NSUInteger)index
{
	CGRect pageFrame = pagingScrollView.frame;
	pageFrame.origin.x = (pageFrame.size.width * index) + PADDING/* - 5*/;
	pageFrame.size.width -= (2 * PADDING)/* - 10*/;
	pageFrame.origin.y = 0;
	return pageFrame;
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self tilePages];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	// reset the scale on all visible pages except the current one
	int curPage = [self currentPage];
	[thumbMenu highlightButton:curPage];
    
	for (pdfPageZoomView* page in visiblePages)
		if (page.index != curPage)
			[page resetScale];
}


// removed when presentModalViewController was
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	[self updateInterfaceOrientation:interfaceOrientation];
}



- (void)updateInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// update the Table of Contents
	[TOCview reframe:interfaceOrientation];
    
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView:interfaceOrientation];
	CGFloat pageWidth = pagingScrollView.frame.size.width;
	int curPage = floor((pagingScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
	// resize the paging scroller
	[pagingScrollView setFrame:pagingScrollViewFrame];
	pagingScrollView.contentSize = CGSizeMake(pagingScrollViewFrame.size.width * pageCount,
											  pagingScrollViewFrame.size.height);
    
	// make the current page visible in the scrollview (offset)
	CGPoint tmpPt = pagingScrollView.contentOffset;
	tmpPt.x = pagingScrollViewFrame.size.width * curPage;
	pagingScrollView.contentOffset = tmpPt;
    
	// update the content views for the new orientation
	for (pdfPageZoomView* page in visiblePages)
		[page updateBounds:[self frameForPageAtIndex:page.index]];
    
	// update the thumbnail scrubber
	if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
		|| (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
		[thumbMenu setFrame:CGRectMake(0, /*self.view.frame.origin.x + */self.view.frame.size.width - 43, self.view.frame.size.height, 43)];
	else
		[thumbMenu setFrame:CGRectMake(0, /*self.view.frame.origin.y + */self.view.frame.size.height - 43, self.view.frame.size.width, 43)];
    
	// update the header
	if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
		|| (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
    {
		[header setFrame:CGRectMake(0, 0, self.view.frame.size.height, 43)];
		CGFloat xPos = 0.5 * (self.view.frame.size.height - 510);
		[headerLabel setFrame:CGRectMake(xPos, 0, headerLabel.frame.size.width, headerLabel.frame.size.height)];
    }
	else
    {
		[header setFrame:CGRectMake(0, 0, self.view.frame.size.width, 43)];
		CGFloat xPos = 0.5 * (self.view.frame.size.width - 510);
		[headerLabel setFrame:CGRectMake(xPos, 0, headerLabel.frame.size.width, headerLabel.frame.size.height)];
    }
}


- (void)readPDF_TOC:(CGPDFDocumentRef)docRef
{
	if (docRef == NULL)
		return;
    
	CGPDFDictionaryRef catalog = CGPDFDocumentGetCatalog(docRef);
	CGPDFDictionaryRef outline, first;
	if (!CGPDFDictionaryGetDictionary(catalog, "Outlines", &outline))
		return;
    
	if (!CGPDFDictionaryGetDictionary(outline, "First", &first))
		return;
    
	[self readPDF_TOC_Items:docRef outline:first level:0];
}


- (void)readPDF_TOC_Items:(CGPDFDocumentRef)document outline:(CGPDFDictionaryRef)outline level:(int)level
{
	bool isOpen;
	CGPDFStringRef string;
	CGPDFDictionaryRef first;
	CGPDFInteger count;
	CFStringRef titleStr;
	NSInteger pageIndex;
    
	if (document == NULL || outline == NULL)
		return;
    
	do	{
		pageIndex = -1;
		if (CGPDFDictionaryGetString(outline, "Title", &string))
			titleStr = CGPDFStringCopyTextString(string);
        
		isOpen = true;
		if (CGPDFDictionaryGetInteger(outline, "Count", &count))
			isOpen = (count < 0) ? false : true;
        
		CGPDFDictionaryRef aDic;
		if (CGPDFDictionaryGetDictionary(outline, "A", &aDic))
        {
			const char* aStr;
			if (CGPDFDictionaryGetName(aDic, "S", &aStr))
            {
				CGPDFArrayRef destArray;
				if (CGPDFDictionaryGetArray(aDic, "D", &destArray))
                {
					CGPDFDictionaryRef curPage;
					if (CGPDFArrayGetDictionary(destArray, 0, &curPage))
						pageIndex = PageNumberFromPageDictionary(curPage);
                }
            }
        }
        
		[self readPDF_TOC_Item:level title:titleStr isOpen:isOpen];
		if (titleStr && (pageIndex > 0))
			[TOCview addBookmark:[NSString stringWithFormat:@"%@", titleStr] page:pageIndex];
		CFRelease(titleStr);
		titleStr = NULL;
        
		if (CGPDFDictionaryGetDictionary(outline, "First", &first))
			[self readPDF_TOC_Items:document outline:first level:(level + 2)];
    }
	while (CGPDFDictionaryGetDictionary(outline, "Next", &outline));	
}


- (void)readPDF_TOC_Item:(int)level title:(CFStringRef)titleStr isOpen:(bool)isOpen
{
	int k;
	char buffer[1024];
    
	NSString* outlineString = @"";
	for (k = 0; k < level; k++)
		outlineString = [outlineString stringByAppendingString:@" "];
    
    CFStringGetCString(titleStr, buffer, sizeof(buffer), kCFStringEncodingUTF8);
	outlineString = [outlineString stringByAppendingFormat:@"%s", buffer];
    
	if (!isOpen)
		outlineString = [outlineString stringByAppendingString:@" <closed>"];
}


static NSInteger PageNumberFromPageDictionary(CGPDFDictionaryRef target)
{
	// there's nothing in the page dictionary to identify page number
	// so we have to work it out by counting our elder siblings
	// and the descendents of elder siblings of each ancestor
    
	NSInteger pageNumber = 0;
	CGPDFDictionaryRef parent;
	while (CGPDFDictionaryGetDictionary(target, "Parent", &parent))
    {
		CGPDFArrayRef kids;
		if (CGPDFDictionaryGetArray(parent, "Kids", &kids))
        {
			size_t numKids = CGPDFArrayGetCount(kids);
			size_t kidNum;
			for (kidNum = 0; kidNum < numKids; ++kidNum)
            {
				CGPDFDictionaryRef kid;
				if (CGPDFArrayGetDictionary(kids, kidNum, &kid))
                {
					if (kid == target)
						break;
					CGPDFInteger count;
					if (CGPDFDictionaryGetInteger(kid, "Count", &count))
						pageNumber += count;
					else
						pageNumber += 1;
                }
            }
        }
		target = parent;
    }
	return pageNumber + 1;
}


CGImageRef genPDFThumbnail(CGPDFPageRef page, CGRect pageRect, int thumbSide)
{
	CGRect scaledRect;
	scaledRect.origin.x = 0;
	scaledRect.origin.y = 0;
	if (pageRect.size.width > pageRect.size.height)
    {
		scaledRect.size.width = thumbSide;
		scaledRect.size.height = floor(thumbSide * pageRect.size.height / pageRect.size.width);
    }
	else
    {
		scaledRect.size.width = floor(thumbSide * pageRect.size.width / pageRect.size.height);
		scaledRect.size.height = thumbSide;
    }
    
	// pad for drop shadow
	CGRect fullRect = scaledRect;
	scaledRect.origin.x += 3;
	scaledRect.origin.y += 3;
	fullRect.size.width += 6;
	fullRect.size.height += 6;
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, fullRect.size.width, fullRect.size.height,
												 8, fullRect.size.width * 4, colorSpace, 
												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
    
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSetShadow(context, CGSizeMake(0,0), 3);
	CGContextFillRect(context, scaledRect);
	CGContextSetShadowWithColor(context, CGSizeMake(0,0), 0, NULL);
    
	CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, scaledRect, 0, true));
	CGContextClipToRect(context, pageRect);
	CGContextDrawPDFPage(context, page);
    
	CGImageRef image = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	return image;
}


- (void)genPDFthumbs
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	// load the PDF
	CGPDFDocumentRef pdfDoc = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
    
	for (int index = PAGECACHE + 1; index < pageCount; index++)
    {
		CGPDFPageRef pageRef = CGPDFDocumentGetPage(pdfDoc, (index + 1));
		pageRef = CGPDFPageRetain(pageRef);
        pagePreviews[index] = genPDFThumbnail(pageRef, pageRects[index], 200);
		CGPDFPageRelease(pageRef);
		thumbDone++;
        
		if ((index % DOCCLEAR) == 0)
        {
			CGPDFDocumentRelease(pdfDoc);
			pdfDoc = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
        }
    }
    
	CGPDFDocumentRelease(pdfDoc);
    
	[pool drain];
}


- (void)gotoPage:(NSInteger)index
{
	CGRect pagingScrollViewFrame = pagingScrollView.frame;
	CGPoint tmpPt = pagingScrollView.contentOffset;
	tmpPt.x = pagingScrollViewFrame.size.width * index;
	pagingScrollView.contentOffset = tmpPt;
}

- (void)didSelectPage:(NSInteger)index
{
	[thumbMenu highlightButton:index];
	[thumbPopup setHidden:YES];
	[self gotoPage:index];
	if (!TOCview.hidden)
		[TOCview updatePageSelection:index];
}

- (void)didScrubPage:(NSInteger)index atPoint:(CGPoint)point
{
	if (thumbDone > index)
		[thumbPopup goToPage:index withPreviewImage:pagePreviews[index] andLabel:[NSString stringWithFormat:@"Page %i", (index + 1)]];
	else
		[thumbPopup goToPage:index withPreviewImage:nil andLabel:[NSString stringWithFormat:@"Page %i", (index + 1)]];
    
	CGPoint localPoint = [self.view convertPoint:point fromView:thumbMenu];
	[thumbPopup setAnchor:localPoint];
	[thumbPopup setHidden:NO];
}

- (void)backAction:(id)sender
{
  //  [[TrackManager sharedInstance] traceClosePdf];
    [self dismissModalViewControllerAnimated:YES];
    [self release];
}

- (void)tocAction
{
	if (TOCview.hidden)
    {
		[TOCview updatePageSelection:[self currentPage]];
		[TOCview reframe:self.interfaceOrientation];
		[TOCview setHidden:NO];
    }
	else
		[TOCview setHidden:YES];
}


- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	
    if ([touches count] != 1)
		return;
    
	[self toggleToolbars];
	[TOCview setHidden:YES];
}

- (void)toggleToolbars
{
	if (toolbarsOn)
		[self hideToolbars];
	else
		[self showToolbars];
}

- (void)hideToolbars
{
	if (toolbarsOn)
    {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationDelegate:self];
        
        header.alpha = 0.0;
        headerLabel.alpha = 0.0;
        thumbMenu.alpha = 0.0;
        
		[UIView commitAnimations];
        
		toolbarsOn = false;
    }
}

- (void)showToolbars
{
	if (!toolbarsOn)
    {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationDelegate:self];
        
        header.alpha = 1.0;
        headerLabel.alpha = 1.0;
        thumbMenu.alpha = 1.0;
        
		[UIView commitAnimations];
        
		toolbarsOn = true;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self hideToolbars];
	[TOCview setHidden:YES];
}

- (void)didZoomPage
{
	[self hideToolbars];
	[TOCview setHidden:YES];
}

- (void)didDragPage
{
	[self hideToolbars];
	[TOCview setHidden:YES];
}


/*
 - (void)enableArrows
 {
 // create clear buttons in the pdfViewer for navigation
 if (leftArrow)
 {
 [leftArrow removeFromSuperview];
 [leftArrow release];
 leftArrow = nil;
 }
 leftArrow = [[UIButton alloc] initWithFrame:CGRectMake(100, 320, 128, 128)];
 leftArrow.backgroundColor = [UIColor clearColor];
 NSString* imageFile = [NSString stringWithFormat:@"%@/clear.png", [[NSBundle mainBundle] resourcePath]];
 [leftArrow setImage:[UIImage imageWithContentsOfFile:imageFile] forState:UIControlStateNormal];
 [leftArrow addTarget:self action:@selector(leftArrowClicked) forControlEvents:UIControlEventTouchUpInside];
 [self.view addSubview:leftArrow];
 
 if (rightArrow)
 {
 [rightArrow removeFromSuperview];
 [rightArrow release];
 rightArrow = nil;
 }
 rightArrow = [[UIButton alloc] initWithFrame:CGRectMake(796, 320, 128, 128)];
 rightArrow.backgroundColor = [UIColor clearColor];
 [rightArrow setImage:[UIImage imageWithContentsOfFile:imageFile] forState:UIControlStateNormal];
 [rightArrow addTarget:self action:@selector(rightArrowClicked) forControlEvents:UIControlEventTouchUpInside];
 [self.view addSubview:rightArrow];
 
 // create images on the iPad screen that line up with the buttons
 [[[UIApplication sharedApplication] currentMirrorView] enablePDFArrows];
 }
 
 
 - (void)disableArrows
 {
 if (leftArrow)
 {
 [leftArrow removeFromSuperview];
 [leftArrow release];
 leftArrow = nil;
 }
 
 if (rightArrow)
 {
 [rightArrow removeFromSuperview];
 [rightArrow release];
 rightArrow = nil;
 }
 
 // remove the iPad screen images too
 [[[UIApplication sharedApplication] currentMirrorView] disablePDFArrows];
 }
 
 
 - (void)leftArrowClicked
 {
 [self hideToolbars];
 [TOCview setHidden:YES];
 int newPage = [self currentPage] - 1;
 if (newPage >= 0)
 [self didSelectPage:newPage];
 }
 
 
 - (void)rightArrowClicked
 {
 [self hideToolbars];
 [TOCview setHidden:YES];
 int newPage = [self currentPage] + 1;
 if (newPage < pageCount)
 [self didSelectPage:newPage];
 }
 */
@end

