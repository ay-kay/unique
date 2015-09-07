//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "ShowResendInformationViewController.h"
#import "AppDelegate.h"

@interface ShowResendInformationViewController ()

@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ShowResendInformationViewController

- (IBAction)agreedButtonPressed
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kREGISTER_FOR_NOTIFICATIONS_KEY];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)deniedButtonPressed
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPUSH_USER_DENIED];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)backToStart:(id)sender
{
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

@end
