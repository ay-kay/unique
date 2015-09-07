//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "StartCollectingViewController.h"
#import "LoadingView.h"
#import "FingerprintCalculator.h"
#import "AppDelegate.h"

#define kWAITING_TIME   5

@implementation StartCollectingViewController {
    LoadingView *_loadingView;
    NSUInteger _remainingTime;
}

- (IBAction)startCollecting:(id)sender
{
    // Zeige LoadingView
    _loadingView = [[LoadingView alloc] initWithText:NSLocalizedString(@"Sammeln", @"Sammeln")];
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    [self.view addSubview:_loadingView];
    
    _remainingTime = kWAITING_TIME;
    
    [NSTimer scheduledTimerWithTimeInterval:.3
                                     target:self
                                   selector:@selector(updateLoadingView:)
                                   userInfo:nil
                                    repeats:YES];
    
    // Starte Datenerhebung
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[FingerprintCalculator sharedCalculator] calculateFirstPart];
    });
}

- (void)updateLoadingView:(NSTimer *)timer
{
    _remainingTime--;
    NSMutableString *dots = [[NSMutableString alloc] initWithString:@""];
    for (int i = 0; i < kWAITING_TIME - _remainingTime; i++) {
        [dots appendString:@"."];
    }
    [_loadingView updateText:[NSString stringWithFormat:NSLocalizedString(@"Sammeln%@", @"Sammeln%@"), dots]];
    [_loadingView setNeedsDisplay];
    
    if (_remainingTime < 1) {
        [_loadingView hide];
        [timer invalidate];
        [self proceed];
    }
}

- (void)proceed
{
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setApplicationState:ApplicationStateCollected];
    [self performSegueWithIdentifier:@"collectSecondPart" sender:nil];
}

#pragma mark - View Controller Boilerplate

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.userInteractionEnabled = YES;
}

@end
