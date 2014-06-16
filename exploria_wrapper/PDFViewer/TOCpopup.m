
#import "TOCpopup.h"
#import "CGDrawHelpers.h"

@implementation TOCpopup

@synthesize bookmarks;
@synthesize delegate;


#define PADDING 8
#define VERTICAL_SHIFT 45
#define BACKGROUND_RADIUS 20
#define TABLE_PADDING_X 20
#define TABLE_PADDING_Y 10
#define FONT_SIZE 13
#define ROW_HEIGHT 25
#define MAX_TABLE_WIDTH 500
#define MAX_TABLE_HEIGHT_PORTRAIT 900
#define MAX_TABLE_HEIGHT_LANDSCAPE 644


- (id)initWithFrame:(CGRect)frame
	{
	if ((self = [super initWithFrame:frame]))
		{
        // Initialization code
		self.backgroundColor = [UIColor clearColor];

		// background image (frame + drop shadow)
		backgroundImage = [[UIImageView alloc] initWithFrame:self.frame];
		[self generateBackground];
		[self addSubview:backgroundImage];

		// create empty table view and bookmark list
		bookmarks = [[NSMutableArray alloc] initWithCapacity:0];
		CGRect tableRect = CGRectMake(PADDING + TABLE_PADDING_X,
									  PADDING + TABLE_PADDING_Y, 
									  frame.size.width - 2 * (PADDING + TABLE_PADDING_X) + 10, 
									  frame.size.height - 2 * (PADDING + TABLE_PADDING_Y));
		bookmarkTable = [[UITableView alloc] initWithFrame:tableRect];
		bookmarkTable.separatorStyle = UITableViewCellSeparatorStyleNone;
		bookmarkTable.rowHeight = ROW_HEIGHT;
		bookmarkTable.dataSource = self;
		bookmarkTable.delegate = self;
		[self addSubview:bookmarkTable];
		tableSize = CGSizeMake(0,0);
		anchor = CGPointMake(0,0);
		}
    return self;
	}


- (void)dealloc
	{
	[bookmarks release];

	[bookmarkTable removeFromSuperview];
	[bookmarkTable release];
	bookmarkTable = nil;

	[backgroundImage removeFromSuperview];
	[backgroundImage release];
	backgroundImage = nil;

    [super dealloc];
	}


- (void)reframe:(UIInterfaceOrientation)orientation
	{
	// only enable scrolling if necessary
	bookmarkTable.scrollEnabled = NO;

	// calculate a new frame for the view based on the current table size
	CGRect viewFrame = CGRectMake(anchor.x,
								  anchor.y,
								  tableSize.width + 2 * (PADDING + TABLE_PADDING_X),
								  tableSize.height + 2 * (PADDING + TABLE_PADDING_Y));

	// make sure large tables don't fall offscreen
	if ((orientation == UIInterfaceOrientationPortrait)
		|| (orientation == UIInterfaceOrientationPortraitUpsideDown))
		{
		if (viewFrame.size.height > MAX_TABLE_HEIGHT_PORTRAIT)
			{
			viewFrame.size.height = MAX_TABLE_HEIGHT_PORTRAIT + 2 * (PADDING + TABLE_PADDING_Y);
			bookmarkTable.scrollEnabled = YES;
			}
		}
	else
		{
		if (viewFrame.size.height > MAX_TABLE_HEIGHT_LANDSCAPE)
			{
			viewFrame.size.height = MAX_TABLE_HEIGHT_LANDSCAPE + 2 * (PADDING + TABLE_PADDING_Y);
			bookmarkTable.scrollEnabled = YES;
			}
		}

	// table frame is slightly smaller
	CGRect tableFrame = CGRectMake(PADDING + TABLE_PADDING_X,
								   PADDING + TABLE_PADDING_Y, 
								   viewFrame.size.width - 2 * (PADDING + TABLE_PADDING_X) + 10, 
								   viewFrame.size.height - 2 * (PADDING + TABLE_PADDING_Y));

	// update the view and table frames
	[self setFrame:viewFrame];
	[bookmarkTable setFrame:tableFrame];
//	[self refreshPosition];
	[self refreshPositionWithOrientation:orientation];
	[self generateBackground];

	// make sure selected entry doesn't fall offscreen
	NSIndexPath* selected = [bookmarkTable indexPathForSelectedRow];
	if (selected)
		[bookmarkTable selectRowAtIndexPath:selected animated:NO scrollPosition:UITableViewScrollPositionMiddle];

	// flash the scroll indicators if appropriate
	if (bookmarkTable.scrollEnabled)
		[bookmarkTable flashScrollIndicators];
	}


- (void)generateBackground
	{
	// figure out background rect
	CGRect backRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

	// draw a rounded rectangle and set it as the background image
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, backRect.size.width, backRect.size.height,
												 8, backRect.size.width * 4, colorSpace, 
												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);

	CGRect smallerRect = CGRectMake(backRect.origin.x + PADDING,
									backRect.origin.y + PADDING, 
									backRect.size.width - 2 * PADDING, 
									backRect.size.height - 2 * PADDING);
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSetShadow(context, CGSizeMake(0,0), PADDING);
	CGContextAddRoundedRect(context, smallerRect, BACKGROUND_RADIUS);
	CGContextFillPath(context);
	CGContextSetShadowWithColor(context, CGSizeMake(0,0), 0, NULL);
	CGContextSetLineWidth(context, 1);
	CGContextSetRGBStrokeColor(context, 0.2, 0.2, 0.2, 1);
	CGContextAddRoundedRect(context, smallerRect, BACKGROUND_RADIUS);
	CGContextStrokePath(context);

	CGImageRef image = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	[backgroundImage setFrame:backRect];
	[backgroundImage setImage:[UIImage imageWithCGImage:image]];
	CGImageRelease(image);
	}


- (void)setAnchor:(CGPoint)point
	{
	anchor = point;
	[self refreshPosition];
	}


- (void)refreshPosition
{
    [self refreshPositionWithOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    // [self refreshPositionWithOrientation:[[UIDevice currentDevice] orientation]]; <-- giaesp: CAUSES WARNING

	//	- (void)refreshPositionWithOrientation:(UIInterfaceOrientation)orientation

	/*
	CGRect newFrame = CGRectMake(anchor.x - 0.5 * self.frame.size.width, 
								 anchor.y + VERTICAL_SHIFT, 
								 self.frame.size.width, 
								 self.frame.size.height);
	CGRect screenRect = [[UIScreen mainScreen] bounds];

	if (([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft)
		|| ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight))
		{
		CGFloat swapVal = screenRect.size.width;
		screenRect.size.width = screenRect.size.height;
		screenRect.size.height = swapVal;
		}

	if (newFrame.origin.x < 0)
		newFrame.origin.x = 0;
	else if (newFrame.origin.x + newFrame.size.width > screenRect.size.width)
		newFrame.origin.x = screenRect.size.width - newFrame.size.width;

	if (newFrame.origin.y < 0)
		newFrame.origin.y = 0;
	else if (newFrame.origin.y + newFrame.size.height > screenRect.size.height)
		newFrame.origin.y = screenRect.size.height - newFrame.size.height;

	[self setFrame:newFrame];
	*/
	}


- (void)refreshPositionWithOrientation:(UIInterfaceOrientation)orientation
	{
	CGRect newFrame = CGRectMake(anchor.x - 0.5 * self.frame.size.width, 
								anchor.y + VERTICAL_SHIFT, 
								self.frame.size.width, 
								self.frame.size.height);
	CGRect screenRect = [[UIScreen mainScreen] bounds];

	if ((orientation == UIInterfaceOrientationLandscapeLeft)
		|| (orientation == UIInterfaceOrientationLandscapeRight))
		{
		CGFloat swapVal = screenRect.size.width;
		screenRect.size.width = screenRect.size.height;
		screenRect.size.height = swapVal;
		}

	if (newFrame.origin.x < 0)
		newFrame.origin.x = 0;
	else if (newFrame.origin.x + newFrame.size.width > screenRect.size.width)
		newFrame.origin.x = screenRect.size.width - newFrame.size.width;

	if (newFrame.origin.y < 0)
		newFrame.origin.y = 0;
	else if (newFrame.origin.y + newFrame.size.height > screenRect.size.height)
		newFrame.origin.y = screenRect.size.height - newFrame.size.height;

	[self setFrame:newFrame];
	}

- (void)addBookmark:(NSString*)title page:(NSInteger)page
	{
	CGSize constraint = CGSizeMake(MAX_TABLE_WIDTH, 20000.0f);
	CGSize textSize = [title sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	Bookmark* newBookmark = [[Bookmark alloc] initWithTitle:title page:page size:textSize];
	[self.bookmarks addObject:newBookmark];
	[newBookmark release];

	tableSize.width = MAX(tableSize.width, textSize.width);
	tableSize.height += bookmarkTable.rowHeight;
	}


- (void)updatePageSelection:(NSInteger)page
	{
	page++;

	// ignore an empty TOC
	if ([bookmarks count] == 0)
		return;

	// get the index for the current page
	// (only find a new selection if the current one doesn't already match)
	NSIndexPath* selected = [bookmarkTable indexPathForSelectedRow];
	if (selected)
		{
		NSInteger curIndex = [[bookmarks objectAtIndex:selected.row] page];
		if (curIndex == page)
			return;
		}

	// find the first TOC entry that is >= page
	NSInteger setIndex = 0;
	for (int i = 0; i < [bookmarks count]; i++)
		{
		NSInteger thisPage = [[bookmarks objectAtIndex:i] page];
		if (thisPage > page)
			{
			NSIndexPath* newIP = [NSIndexPath indexPathForRow:setIndex inSection:0];
			[bookmarkTable selectRowAtIndexPath:newIP animated:NO scrollPosition:UITableViewScrollPositionMiddle];
			return;
			}
		else if (thisPage == page)
			{
			NSIndexPath* newIP = [NSIndexPath indexPathForRow:i inSection:0];
			[bookmarkTable selectRowAtIndexPath:newIP animated:NO scrollPosition:UITableViewScrollPositionMiddle];
			return;
			}
		setIndex = i;
		}

	// set the last entry active if we got here
	NSIndexPath* newIP = [NSIndexPath indexPathForRow:([bookmarks count] - 1) inSection:0];
	[bookmarkTable selectRowAtIndexPath:newIP animated:NO scrollPosition:UITableViewScrollPositionMiddle];
	}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
	{
    // Return the number of sections.
    return 1;
	}


- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
	{
    // Return the number of rows in the section.
    return [bookmarks count];
	}


- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
	{
	UITableViewCell* cell;
	UILabel* label = nil;

	cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	if (cell == nil)
    {
		// cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"Cell"] autorelease]; <-- DEPRECATED
        // cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.opaque = YES;
            
		label = [[UILabel alloc] initWithFrame:CGRectZero];
		[label setLineBreakMode:UILineBreakModeWordWrap];
		[label setMinimumFontSize:FONT_SIZE];
		[label setNumberOfLines:0];
		[label setFont:[UIFont systemFontOfSize:FONT_SIZE]];
		[label setTag:1];

		[[cell contentView] addSubview:label];
		[label release];
		}

	NSString* text = [[bookmarks objectAtIndex:indexPath.row] title];
	CGSize constraint = CGSizeMake(self.frame.size.width, 20000.0f);
	CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];

	label = (UILabel*)[cell viewWithTag:1];

	CGRect labelFrame = CGRectMake(0, 0, bookmarkTable.frame.size.width, MAX(size.height, tableView.rowHeight));
	[label setText:text];
	[label setFrame:labelFrame];
	cell.selectedBackgroundView = [[[tableBackground alloc] initWithFrame:labelFrame textWidth:size.width] autorelease];

	return cell;
	}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
	{
	// Navigation logic may go here. Create and push another view controller.
	[self.delegate didSelectPage:([[bookmarks objectAtIndex:indexPath.row] page] - 1)];
	}


@end


@implementation Bookmark
@synthesize title,page,size;

- (id)initWithTitle:(NSString*)text page:(NSInteger)pg size:(CGSize)sz
	{
	self.title = text;
	self.page = pg;
	self.size = sz;
	return self;
	}

@end


@implementation tableBackground

- (id)initWithFrame:(CGRect)frame textWidth:(NSInteger)width
	{
	// draw a line the width of the text in an image
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, frame.size.width, frame.size.height,
												 8, frame.size.width * 4, colorSpace, 
												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
	CGRect lineRect = CGRectMake(0, 1, width, 3);
	CGContextSetRGBFillColor(context, 0.3, 0.7, 0.84, 1.0);
	CGContextFillRect(context, lineRect);
	CGImageRef image = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	[super initWithImage:[UIImage imageWithCGImage:image]];
	CGImageRelease(image);
	return self;
	}

@end

