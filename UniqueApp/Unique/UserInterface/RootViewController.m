//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "RootViewController.h"
#import "Fingerprint.h"
#import "AppDelegate.h"

#define kUSER_ASKED_TO_SEND     @"showAlert"
#define kALERTVIEW_TAG_NOTIF    312

@interface RootViewController ()

@property (weak, nonatomic) IBOutlet UIButton *calculateFingerprintButton;
@property (weak, nonatomic) IBOutlet UIButton *showFingerprintButton;
@property (weak, nonatomic) IBOutlet UIButton *sendFingerprintButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteFingerprintButton;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation RootViewController {
    BOOL _showAlert;
    BOOL _alreadyAskedToSend;
}

- (IBAction)deleteFingerprint {
    BOOL success = [[Fingerprint sharedFingerprint] clearData];
    
    NSString *title;
    NSString *message;
    if (success) {
        title = NSLocalizedString(@"Erfolg!", @"Erfolg!");
        message = NSLocalizedString(@"Ihr Fingerabdruck wurde erfolgreich gelöscht.", @"Ihr Fingerabdruck wurde erfolgreich gelöscht.");
    } else {
        title = NSLocalizedString(@"Fehler!", @"Fehler!");
        message = NSLocalizedString(@"Beim Löschen Ihres Fingerabdrucks ist ein Fehler aufgetreten.", @"Beim Löschen Ihres Fingerabdrucks ist ein Fehler aufgetreten.");
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setApplicationState:ApplicationStateInformed];
    
    [self configureView];
}

- (IBAction)sendFingerprint
{
    [self performSegueWithIdentifier:@"sendFingerprint" sender:nil];
}

- (void)calculateNewFingerprint
{
    [self performSegueWithIdentifier:@"calculateFingerprint" sender:nil];
}

- (void)recompareFingerprint
{
    [self performSegueWithIdentifier:@"sendFingerprint" sender:nil];
}

- (IBAction)openLink
{
    NSURL *url = [NSURL URLWithString:@"https://www1.cs.fau.de"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)askUserToSendData
{
    if (_showAlert && !_alreadyAskedToSend) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Daten senden?", @"Daten senden?") message:NSLocalizedString(@"Die Daten für Ihren Fingerabdruck wurden erhoben. Möchten Sie diese an uns senden? Sie können dann die Eindeutigkeit Ihres Fingerabdrucks sehen.", @"Die Daten für Ihren Fingerabdruck wurden erhoben. Möchten Sie diese an uns senden? Sie können dann die Eindeutigkeit Ihres Fingerabdrucks sehen.") delegate:self cancelButtonTitle:NSLocalizedString(@"Später", @"Später") otherButtonTitles:NSLocalizedString(@"Ja", @"Ja"), nil];
        [alertView show];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUSER_ASKED_TO_SEND];
    }
}

#pragma mark - UIAlertView Delegate

// This method works for both alertViews
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kALERTVIEW_TAG_NOTIF) {
        // Notification-AlertView
        if (buttonIndex == 1) {
            
            // pop to rootview
            [self.navigationController popToRootViewControllerAnimated:YES];

            // clear Data
            [[Fingerprint sharedFingerprint] clearData];
            
            // reset User Interface to ApplicationStateInformed
            // then performSegue to calculate new fingerprint
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] setApplicationState:ApplicationStateInformed];
            [self configureView];
            [self performSegueWithIdentifier:@"calculateFingerprint" sender:nil];
        }
    } else {
        switch (buttonIndex) {
            case 0:
                // Cancel Button
                // Set _showAlert to YES, so alertview (Daten Senden) will not show
                _showAlert = NO;
                break;
            case 1:
                _showAlert = NO;
                [self recompareFingerprint];
                break;
            case 2:
                [self calculateNewFingerprint];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - View Stuff

- (void)configureView
{
    BOOL hasData = [[Fingerprint sharedFingerprint] hasData];
    self.showFingerprintButton.enabled = self.sendFingerprintButton.enabled = self.deleteFingerprintButton.enabled = hasData;
    self.imageView.image = [self imageForCurrentState];
}

- (UIImage *)imageForCurrentState
{
    NSInteger state = [(AppDelegate *)[[UIApplication sharedApplication] delegate] applicationState];
    NSString *imageName;
    switch (state) {
        case ApplicationStateStart:
            imageName = @"pathStart";
            break;
        case ApplicationStateInformed:
            imageName = @"pathStep2";
            break;
        case ApplicationStateCollected:
            imageName = @"pathStep3";
            break;
        case ApplicationStateShowed:
            imageName = @"pathStep4";
            break;
        case ApplicationStateSent:
            imageName = @"pathComplete";
            break;
            
        default:
            break;
    }
    return [UIImage imageNamed:imageName];
}

- (void)updateUI
{
    // App was started due to incoming notification or notification was received while running
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUSER_ASKED_TO_SEND];
    _alreadyAskedToSend = NO;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Hallo!", @"Hallo!") message:NSLocalizedString(@"Seitdem Sie Ihren Fingerabdruck erstellt haben ist nun einige Zeit vergangen. Wir würden uns freuen, wenn Sie Ihren Fingerabdruck neu generieren und ihn uns anschließend zur Verfügung stellen könnten. Dazu werden wir nun die bisher erhobenen Daten verwerfen", @"Seitdem Sie Ihren Fingerabdruck erstellt haben ist nun einige Zeit vergangen. Wir würden uns freuen, wenn Sie Ihren Fingerabdruck neu generieren und ihn uns anschließend zur Verfügung stellen könnten. Dazu werden wir nun die bisher erhobenen Daten verwerfen") delegate:self cancelButtonTitle:NSLocalizedString(@"Abbrechen", @"Abbrechen") otherButtonTitles:@"OK", nil];
    alertView.tag = kALERTVIEW_TAG_NOTIF;
    [alertView show];
}

#pragma mark - View Controller Boilerplate

- (void)viewDidAppear:(BOOL)animated
{
    [self configureView];
    _showAlert = YES;
    _alreadyAskedToSend = [[NSUserDefaults standardUserDefaults] boolForKey:kUSER_ASKED_TO_SEND];
    if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] applicationState] == ApplicationStateShowed) {
        [self performSelector:@selector(askUserToSendData) withObject:nil afterDelay:3.0f];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self configureView];
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    _showAlert = NO;
}

@end
