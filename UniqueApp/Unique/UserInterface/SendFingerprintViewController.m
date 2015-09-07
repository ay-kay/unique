//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "SendFingerprintViewController.h"
#import "FingerprintCalculator.h"

@interface SendFingerprintViewController ()

@end

@implementation SendFingerprintViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[FingerprintCalculator sharedCalculator] sendFingerprint:segue.destinationViewController];
}

@end
