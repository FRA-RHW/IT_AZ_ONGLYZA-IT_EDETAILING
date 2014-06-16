//
//  syncProgress.h
//  iressa
//
//  Created by Fabio Spacagna on 17/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface syncModalUI : UIViewController {
    IBOutlet UIProgressView* progress;
    IBOutlet UILabel* label;
    IBOutlet UIButton* btn;
    IBOutlet UIImageView* ico;
    IBOutlet UIActivityIndicatorView* spinner;
}

@property (nonatomic,retain)  IBOutlet UIProgressView* progress;
@property (nonatomic,retain)  IBOutlet UILabel* label;
@property (nonatomic,retain)  IBOutlet UIButton* btn;
@property (nonatomic,retain)  IBOutlet UIImageView* ico;
@property (nonatomic,retain)  IBOutlet UIActivityIndicatorView* spinner;


- (IBAction) dismissSynch:(id)sender;


@end
