
#import <UIKit/UIKit.h>

@protocol TOCpopupDelegate <NSObject>
@optional
	- (void)didSelectPage:(NSInteger)index;
@end


@interface TOCpopup : UIView <UITableViewDelegate, UITableViewDataSource, TOCpopupDelegate>
	{
	UIImageView* backgroundImage;
	NSMutableArray* bookmarks;
	UITableView* bookmarkTable;
	CGSize tableSize;
	CGPoint anchor;
	id <TOCpopupDelegate> delegate;
	}

@property (nonatomic,retain) NSMutableArray* bookmarks;
@property (nonatomic,assign) id <TOCpopupDelegate> delegate;

- (void)generateBackground;
- (void)setAnchor:(CGPoint)point;
- (void)addBookmark:(NSString*)title page:(NSInteger)page;
- (void)reframe:(UIInterfaceOrientation)orientation;
- (void)refreshPosition;
- (void)refreshPositionWithOrientation:(UIInterfaceOrientation)orientation;
- (void)updatePageSelection:(NSInteger)page;

@end


@interface Bookmark : NSObject
	{
	NSString* title;
	NSInteger page;
	CGSize size;
	}

@property(nonatomic,copy) NSString* title;
@property(nonatomic,assign) NSInteger page;
@property(nonatomic,assign) CGSize size;

- (id)initWithTitle:(NSString*)text page:(NSInteger)pg size:(CGSize)sz;

@end


@interface tableBackground : UIImageView
	{ }

- (id)initWithFrame:(CGRect)frame textWidth:(NSInteger)width;

@end

