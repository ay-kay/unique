//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "ContinueCollectingViewController.h"
#import "FingerprintCalculator.h"

@interface ContinueCollectingViewController ()

@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ContinueCollectingViewController

- (IBAction)getSecondPart {
    [[FingerprintCalculator sharedCalculator] calculateSecondPartWithCompletionHandler:^{
        [self performSegueWithIdentifier:@"showResults" sender:nil];
    }];
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
