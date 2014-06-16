
#import "TappableScrollView.h"

@implementation TappableScrollView

- (id)initWithFrame:(CGRect)frame 
	{
        return [super initWithFrame:frame];
    }


//IOS5 FIX
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
 if (!self.dragging){
        [self.nextResponder touchesBegan:touches withEvent:event]; 
    }else{
		[super touchesEnded:touches withEvent:event];
	}
    
}
/**********/
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event 
	{
//	[[UIApplication sharedApplication] log:@"scroll touchEnded"];
	// If not dragging, send event to next responder
        if (!self.dragging){
        
        //[(UIResponder*)self.delegate touchesEnded:touches withEvent:event];
        [self.nextResponder touchesEnded:touches withEvent:event]; 
            }else{
		[super touchesEnded:touches withEvent:event];
	}
  
}


/*
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
	{
	[[UIApplication sharedApplication] log:@"scroll hitTest"];
	[super hitTest:point withEvent:event];
	}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
	{
	[[UIApplication sharedApplication] log:@"scroll touchesMoved"];
	[super touchesMoved:touches withEvent:event];
	}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
	{
	[[UIApplication sharedApplication] log:@"scroll touchesBegan"];
	[super touchesBegan:touches withEvent:event];
	}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
	{
	[[UIApplication sharedApplication] log:@"scroll touchesCancelled"];
	[super touchesCancelled:touches withEvent:event];
	}

- (void)setTransform:(CGAffineTransform)newValue
	{
	NSLog(@"scroll UIView setTransform");
	[super setTransform:newValue];
	//	[self setNeedsDisplay];
	}
*/
/*
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
	{
	[[UIApplication sharedApplication] log:[NSString stringWithFormat:@"scrollPoint: %f %f", point.x, point.y]];
	return [super hitTest:point withEvent:event];
	}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
	{
	UITouch* touch = [touches anyObject];
	CGPoint newP = [touch locationInView:self];
	[[UIApplication sharedApplication] log:[NSString stringWithFormat:@"movePoint: %f %f", newP.x, newP.y]];
	[super touchesMoved:touches withEvent:event];
	}
*/
@end
