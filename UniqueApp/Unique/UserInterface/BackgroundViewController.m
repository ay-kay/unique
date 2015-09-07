//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "BackgroundViewController.h"

@interface BackgroundViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation BackgroundViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    UIEdgeInsets textContainerInsets = self.textView.textContainerInset;
    textContainerInsets.bottom = 10;
    textContainerInsets.left = 10;
    textContainerInsets.right = 10;
    textContainerInsets.top = 74;   // space from top to bottom of navigationbar is '64'
    self.textView.textContainerInset = textContainerInsets;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.textView flashScrollIndicators];
}

@end
