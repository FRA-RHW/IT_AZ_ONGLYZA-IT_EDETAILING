#import "syncModalUI.h"

@implementation syncModalUI

@synthesize progress,btn,label,ico,spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncDone:) name:@"syncDone" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncFail:) name:@"syncFail" object:nil];
    
    btn.hidden = YES;
    [spinner startAnimating];
}

- (void) syncDone:(id) sender{
    if ( [[sender object] isEqual:@"SUCCESS"]){    
        label.text = @"Synchronization process done"; // NSLocalizedString(@"SYNC_DONE", nil);
        ico.image=[UIImage imageNamed:@"done.png"];        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dropDataBase" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"checkForUpdate" object:nil];
    }
    else {
        label.text = @"An error has occurred. Please try again later."; // NSLocalizedString(@"SYNC_ERROR", nil);
        ico.image=[UIImage imageNamed:@"err.png"];
        progress.hidden=YES;    
    }
    [spinner stopAnimating];
    btn.hidden = NO;
}

- (void) syncFail:(id) sender{
    label.text = NSLocalizedString(@"An error has occurred. Please try again later.", nil);
    ico.image=[UIImage imageNamed:@"err.png"];
    progress.hidden = YES;   
    btn.hidden = NO;
    [spinner stopAnimating];
}

- (IBAction) dismissSynch:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) return YES;
	return NO;
}

@end