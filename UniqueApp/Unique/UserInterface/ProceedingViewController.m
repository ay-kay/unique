//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "ProceedingViewController.h"
#import "AppDelegate.h"

@interface ProceedingViewController ()

@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ProceedingViewController

- (IBAction)backToStart:(id)sender
{
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setApplicationState:ApplicationStateInformed];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    UIEdgeInsets textContainerInsets = self.textView.textContainerInset;
    textContainerInsets.bottom = 10;
    textContainerInsets.left = 10;
    textContainerInsets.right = 10;
    textContainerInsets.top = 10;
    self.textView.textContainerInset = textContainerInsets;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.textView flashScrollIndicators];
}

@end
