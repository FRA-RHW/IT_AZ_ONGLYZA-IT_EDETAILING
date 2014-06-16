
#import "thumbPopover.h"
#import "CGDrawHelpers.h"

@implementation thumbPopover

#define PADDING 4
#define VERTICAL_SHIFT 10
#define BACKGROUND_RADIUS 4


- (id)initWithFrame:(CGRect)frame
	{
    if ((self = [super initWithFrame:frame]))
		{
        // Initialization code
		maxThumbDim = 120;
		self.backgroundColor = [UIColor clearColor];

		// background image (frame + drop shadow)
		backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, maxThumbDim, maxThumbDim)];
		[self addSubview:backgroundImage];

		// thumbnail image
		previewImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, maxThumbDim, maxThumbDim)];
		[self addSubview:previewImage];

		// add a page label
		previewLabel = [[UILabel alloc] init];
		[previewLabel setFrame:CGRectMake(0, 0, maxThumbDim, 20)];
		[previewLabel setTextAlignment:UITextAlignmentCenter];
		[previewLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
		[previewLabel setBackgroundColor:[UIColor clearColor]];
		[previewLabel setText:@"Page 1"];
		//[previewLabel setTextColor:[UIColor colorWithRed:0.23 green:0.17 blue:0.42 alpha:1.0]];
		[previewLabel setTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0]];
        [previewLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
		[self addSubview:previewLabel];
		}
    return self;
	}


- (void)dealloc
	{
	[previewLabel removeFromSuperview];
	[previewLabel release];
	previewLabel = nil;

	[previewImage removeFromSuperview];
	[previewImage release];
	previewImage = nil;

	[backgroundImage removeFromSuperview];
	[backgroundImage release];
	backgroundImage = nil;

    [super dealloc];
	}


- (void)goToPage:(NSInteger)index withPreviewImage:(CGImageRef)pagePreview andLabel:(NSString*)pageLabel
	{
	CGRect scaledRect;
	scaledRect.origin.x = 2 * PADDING;
	scaledRect.origin.y = 2 * PADDING;
	scaledRect.size.width = (pagePreview) ? CGImageGetWidth(pagePreview) : maxThumbDim;
	scaledRect.size.height = (pagePreview) ? CGImageGetHeight(pagePreview) : 1;

	if (pagePreview)
		{
		if (scaledRect.size.width > scaledRect.size.height)
			{
			scaledRect.size.height = floor(maxThumbDim * scaledRect.size.height / scaledRect.size.width);
			scaledRect.size.width = maxThumbDim;
			}
		else
			{
			scaledRect.size.width = floor(maxThumbDim * scaledRect.size.width / scaledRect.size.height);
			scaledRect.size.height = maxThumbDim;
			}
		}

	[previewImage setFrame:scaledRect];
	if (pagePreview)
		[previewImage setImage:[UIImage imageWithCGImage:pagePreview]];

	CGRect newFrame = CGRectMake(0, 0, scaledRect.size.width + 4 * PADDING,
								 scaledRect.size.height + previewLabel.frame.size.height + 5 * PADDING);
	[self setFrame:newFrame];
	[self updateBackground];

	// update the label
	[previewLabel setText:pageLabel];
	[previewLabel setFrame:CGRectMake(0, scaledRect.size.height + 2.5 * PADDING, 
									  self.frame.size.width, previewLabel.frame.size.height)];
	}


- (void)setAnchor:(CGPoint)point
	{
	[self setFrame:CGRectMake(point.x - 0.5 * self.frame.size.width, 
							  point.y - self.frame.size.height - VERTICAL_SHIFT, 
							  self.frame.size.width, 
							  self.frame.size.height)];
	}


- (void)updateBackground
	{
	// draw a rounded rectangle and set it as the background image
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, self.frame.size.width, self.frame.size.height,
												 8, self.frame.size.width * 4, colorSpace, 
												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);

	CGRect smallerRect = CGRectMake(self.frame.origin.x + PADDING,
									self.frame.origin.y + PADDING, 
									self.frame.size.width - 2 * PADDING, 
									self.frame.size.height - 2 * PADDING);
	
    
        //CGContextSetRGBFillColor(context, 0.0, 0.68, 0.96, 1.0);
        
    CGContextSetRGBFillColor(context, 0.22, 0.22 ,0.22, 1.0);
	
        
    CGContextSetShadow(context, CGSizeMake(0,0), PADDING);
	CGContextAddRoundedRect(context, smallerRect, BACKGROUND_RADIUS);
	CGContextFillPath(context);
	CGContextSetShadowWithColor(context, CGSizeMake(0,0), 0, NULL);

	CGImageRef image = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	[backgroundImage setFrame:self.frame];
	[backgroundImage setImage:[UIImage imageWithCGImage:image]];
	CGImageRelease(image);
	}

@end
