
#import "pageScrubber.h"

@implementation pageScrubber

@synthesize delegate;

#define PADDING		5	// amount of blank space between thumbnails


- (id)initWithFrame:(CGRect)frame thumbSize:(CGSize)thumbSz
	{
	self = [super initWithFrame:frame];
	self.delegate = self;

	thumbSize = thumbSz;
	selectedIndex = -1;
	pageCount = -1;
	dotWidth = 0;

	[self createScrubberIconsWithColor:[UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.5]
						 selectedColor:[UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.5]];

	// add a button view to scrub
	scrubberButtons = [[UIView alloc] initWithFrame:CGRectZero];

	// add a page label
	scrubberLabel = [[UILabel alloc] init];
	[scrubberLabel setFrame:CGRectMake(0, 0, 85, 13)];
	[scrubberLabel setTextAlignment:UITextAlignmentLeft];
	[scrubberLabel setBackgroundColor:[UIColor clearColor]];
	[scrubberLabel setText:@"0 of 0"];
	
    [scrubberLabel setTextColor:[UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:1.0]];
	
    [scrubberLabel setFont:[UIFont systemFontOfSize:12.0]];

	return self;
	}


- (void)createScrubberIconsWithColor:(UIColor*)inactiveColor selectedColor:(UIColor*)activeColor
	{
	// draw the inactive block graphic
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, 15, 13, 8, 60, colorSpace, 
								kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);

	CGColorRef dotColor = [inactiveColor CGColor];
	const CGFloat* dotColors = CGColorGetComponents(dotColor);
	CGContextSetRGBFillColor(context, dotColors[0], dotColors[1], dotColors[2], dotColors[3]);
	CGContextFillRect(context, CGRectMake(5, 4, 5, 5));
	CGImageRef image = CGBitmapContextCreateImage(context);
	scrubInactive = [UIImage imageWithCGImage:image];
	CGImageRelease(image);

	// draw the active block graphic
	CGContextClearRect(context, CGRectMake(5, 4, 5, 5));
	CGContextSetLineWidth(context, 4);
	CGColorRef boxColor = [activeColor CGColor];
	const CGFloat* boxColors = CGColorGetComponents(boxColor);
	CGContextSetRGBStrokeColor(context, boxColors[0], boxColors[1], boxColors[2], boxColors[3]);
	CGContextStrokeRect(context, CGRectMake(1, 1, 13, 11));
	CGImageRef imageB = CGBitmapContextCreateImage(context);
	scrubActive = [UIImage imageWithCGImage:imageB];
	CGImageRelease(imageB);
	CGContextRelease(context);
	}


- (void)dealloc
	{
	// release all buttons
	for (UIView* tmpView in [scrubberButtons subviews])
		{
		[tmpView removeFromSuperview];
		[tmpView release];
		}
	[scrubberButtons removeFromSuperview];
	[scrubberButtons release];
	[scrubInactive release];
	[scrubActive release];
	[scrubberLabel removeFromSuperview];
	[scrubberLabel release];
	[super dealloc];
	}


- (void)addNodes:(NSInteger)nodeCount
	{
	// figure out how to center these scrubber blocks
	pageCount = nodeCount;
	dotWidth = nodeCount * 15 - 10;
	int curX = 0;
	[scrubberButtons setFrame:CGRectMake(0, 0, dotWidth, 13)];
	[self addSubview:scrubberButtons];

	for (int i = 0; i < nodeCount; i++)
		{
		// create a button
		UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
		CGRect buttonFrame = CGRectMake(curX, 0, 15, 13);
		[button setFrame:buttonFrame];
		button.backgroundColor = [UIColor clearColor];
		[button setTag:(i + 1)];
		button.userInteractionEnabled = NO;
		[button setImage:scrubInactive forState:UIControlStateNormal];
		[button setImage:scrubActive forState:UIControlStateHighlighted];
		[button setImage:scrubActive forState:UIControlStateSelected];
		[scrubberButtons addSubview:button];

		curX += 15;
		}

	// position the page label
	[scrubberLabel setFrame:CGRectMake(0, (self.frame.size.height - 13) * 0.5, 85, 13)];
	[scrubberLabel setText:[NSString stringWithFormat:@"0 of %i", pageCount]];
	[self addSubview:scrubberLabel];

	// update screen positions
	[self setFrame:self.frame];
	}


- (void)createButtonGraphics:(UIButton*)button
	{
	// draw the inactive block graphic
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, 15, 13, 8, 60, colorSpace, 
							kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);

	CGContextSetRGBFillColor(context, 0.16, 0.19, 0.5, 1.0);
	CGContextFillRect(context, CGRectMake(5, 4, 5, 5));
	CGImageRef image = CGBitmapContextCreateImage(context);

	// draw the active block graphic
	CGContextClearRect(context, CGRectMake(5, 4, 5, 5));
	CGContextSetLineWidth(context, 4);
	CGContextSetRGBStrokeColor(context, 0.3, 0.7, 0.84, 1.0);
	CGContextStrokeRect(context, CGRectMake(1, 1, 13, 11));
	CGImageRef imageB = CGBitmapContextCreateImage(context);

	CGContextRelease(context);

	UIImage* buttonImage = [UIImage imageWithCGImage:image];
	UIImage* buttonImageB = [UIImage imageWithCGImage:imageB];
	CGImageRelease(image);
	CGImageRelease(imageB);
	[button setImage:buttonImage forState:UIControlStateNormal];
	[button setImage:buttonImageB forState:UIControlStateHighlighted];
	[button setImage:buttonImageB forState:UIControlStateSelected];
	}


- (void)highlightButton:(NSInteger)index
	{
	if ((index < 0) || (index >= pageCount))
		return;

	// change the selected button
	if ((selectedIndex > -1) && (selectedIndex < pageCount))
		{
		UIButton* tmpButton = (UIButton*)[self viewWithTag:(selectedIndex + 1)];
		[tmpButton setSelected:NO];
		}

	UIButton* tmpButton = (UIButton*)[self viewWithTag:(index + 1)];
	[tmpButton setSelected:YES];

	// update the page label
	[scrubberLabel setText:[NSString stringWithFormat:@"%i of %i", (index + 1), pageCount]];

	selectedIndex = index;
	}


- (void)highlightButton:(NSInteger)index updateLabel:(BOOL)updateLabel
	{
	if ((index < 0) || (index >= pageCount))
		return;
	
	// change the selected button
	if ((selectedIndex > -1) && (selectedIndex < pageCount))
		{
		UIButton* tmpButton = (UIButton*)[self viewWithTag:(selectedIndex + 1)];
		[tmpButton setSelected:NO];
		}
	
	UIButton* tmpButton = (UIButton*)[self viewWithTag:(index + 1)];
	[tmpButton setSelected:YES];
	
	// update the page label
	if (updateLabel)
		[scrubberLabel setText:[NSString stringWithFormat:@"%i of %i", (index + 1), pageCount]];

	selectedIndex = index;
	}


- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
	{
	if ([touches count] != 1)	return;
	UITouch* touch = [touches anyObject];
	CGPoint p = [touch locationInView:self];
	[self scrubToPoint:p];
	}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
	{
	if ([touches count] != 1)	return;
	UITouch* touch = [touches anyObject];
	CGPoint p = [touch locationInView:self];
	[self scrubToPoint:p];
	}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
	{
	if ([touches count] != 1)
		return;

	[self highlightButton:selectedIndex];
	[delegate didSelectPage:selectedIndex];
	}

- (void)scrubToPoint:(CGPoint)point
	{
	point.x -= scrubberButtons.frame.origin.x;
	for (UIView* child in scrubberButtons.subviews)
		{
		if ((point.x >= child.frame.origin.x)
			&& (point.x <= (child.frame.origin.x + child.frame.size.width)))
			{
			if (child != scrubberLabel)
				{
				int newPage = child.tag - 1;
				if (selectedIndex != newPage)
					{
					CGPoint centerPoint = CGPointMake(child.frame.origin.x + 0.5 * child.frame.size.width + scrubberButtons.frame.origin.x,
													  child.frame.origin.y + 0.5 * child.frame.size.height);
					[delegate didScrubPage:newPage atPoint:centerPoint];
					}
				[self highlightButton:(child.tag - 1) updateLabel:NO];
				}
			}
		}
	}


- (void)setFrame:(CGRect)frameRect
	{
	[super setFrame:frameRect];

	int maxDotWidth = frameRect.size.width - 220;
	if (dotWidth > maxDotWidth)
		{
		// scale everything down to fit on screen
		CGFloat newScale = maxDotWidth / (CGFloat)dotWidth;
		NSInteger curX = 0;
		for (UIView* child in scrubberButtons.subviews)
			{
			CGRect tmpFrame = child.frame;
			tmpFrame.origin.x = newScale * curX;
			tmpFrame.size.width = newScale * 15;
			[child setFrame:tmpFrame];
			curX += 15;
			}

		[scrubberButtons setFrame:CGRectMake(110,
											 (self.frame.size.height - scrubberButtons.frame.size.height) * 0.5,
											 maxDotWidth,
											 scrubberButtons.frame.size.height)];
		[scrubberLabel setFrame:CGRectMake(self.frame.size.width - 95,
										   (self.frame.size.height - scrubberLabel.frame.size.height) * 0.5,
										   scrubberLabel.frame.size.width,
										   scrubberLabel.frame.size.height)];
		}
	else
		{
		int endOffset = (self.frame.size.width - dotWidth) * 0.5;
		NSInteger curX = 0;
		for (UIView* child in scrubberButtons.subviews)
			{
			CGRect tmpFrame = child.frame;
			tmpFrame.origin.x = curX;
			tmpFrame.size.width = 15;
			[child setFrame:tmpFrame];
			curX += 15;
			}

		[scrubberButtons setFrame:CGRectMake(endOffset,
											 (self.frame.size.height - scrubberButtons.frame.size.height) * 0.5,
											 dotWidth,
											 scrubberButtons.frame.size.height)];
		[scrubberLabel setFrame:CGRectMake(scrubberButtons.frame.origin.x + scrubberButtons.frame.size.width + 15,
										   (self.frame.size.height - scrubberLabel.frame.size.height) * 0.5,
										   scrubberLabel.frame.size.width,
										   scrubberLabel.frame.size.height)];
		}
	}

@end

