//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "ShowResultViewController.h"
#import "KeychainItemWrapper.h"
#import "ShowDetailsViewController.h"
#import "LoadingView.h"
#import "AppDelegate.h"

#define kRESULT_FINGERPRINT_UNIQUE  @"unique"
#define kRESULT_FINGERPRINT_ID      @"id"
#define kRESULT_ERROR_HAPPENED      @"requestFailed"
#define kRESULT_ERROR_DESCRIPTION   @"errorDescription"
#define kRESULT_TOTAL_FINGERPRINTS  @"fingerprintCount"
#define kRESULT_PROPERTY_MATCHES    @"propertyMatches"
#define kRESULT_EQUAL_FINGERPRINTS  @"equalFingerprints"

@interface ShowResultViewController ()

@property (weak, nonatomic) IBOutlet UIButton *detailsButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ShowResultViewController {
    NSArray *_matches;
    LoadingView *_loadingView;
    NSNumber *_fpCount;
}

- (void)viewDidLoad
{
    _loadingView = [[LoadingView alloc] initWithText:NSLocalizedString(@"Laden...", @"Laden...")];
    [self.view addSubview:_loadingView];
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    BOOL userAgreed = [[NSUserDefaults standardUserDefaults] boolForKey:kREGISTER_FOR_NOTIFICATIONS_KEY];
    BOOL userDenied = [[NSUserDefaults standardUserDefaults] boolForKey:kPUSH_USER_DENIED];
    
    if (userAgreed || userDenied) {
        UIBarButtonItem *backToStartButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Startseite", @"Startseite") style:UIBarButtonItemStyleBordered target:self action:@selector(backToStart)];
        self.navigationItem.rightBarButtonItem = backToStartButton;
    }
}

- (void)backToStart
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)sendingFingerprintFinishedWithResult:(NSDictionary *)result
{
    // Deaktiviere NetworkActivityIndicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // Setze loadingView auf hidden
    [_loadingView hide];
    
    // Werte Ergebnis aus
    _matches = [result valueForKey:kRESULT_PROPERTY_MATCHES];
    _fpCount = [result valueForKey:kRESULT_TOTAL_FINGERPRINTS];
    if ([[result valueForKey:kRESULT_ERROR_HAPPENED] isEqual: @YES]) {
        [self fillTextViewForErrorResult:result];
    } else {
        // Speichere cookie in keychain
        KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"FingerprintCookie" accessGroup:nil];
        
        NSString *oldCookie = [keychainWrapper objectForKey:(__bridge id)(kSecValueData)];
        if (!oldCookie || oldCookie.length < 1) {
            [keychainWrapper setObject:[result valueForKey:kRESULT_FINGERPRINT_ID] forKey:(__bridge id)(kSecValueData)];
        }
        
        // Zeige Ergebnisse an
        [self fillTextViewForResult:result];
    }
}

- (void)fillTextViewForErrorResult:(NSDictionary *)result
{
    NSString *errorDescription = [result valueForKey:kRESULT_ERROR_DESCRIPTION];
    NSString *string = [NSString stringWithFormat:NSLocalizedString(@"Fehler!\nBeim Senden des Fingerabdrucks ist ein Fehler aufgetreten. Bitte versuchen Sie es zu einem späteren Zeitpunkt noch einmal.\n\nFehlermeldung:\n%@", @"Fehler!\nBeim Senden des Fingerabdrucks ist ein Fehler aufgetreten. Bitte versuchen Sie es zu einem späteren Zeitpunkt noch einmal.\n\nFehlermeldung:\n%@"), errorDescription];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]}];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17.0f] range:[string rangeOfString:NSLocalizedString(@"Fehler!", @"Fehler!")]];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17.0f] range:[string rangeOfString:NSLocalizedString(@"Fehlermeldung:", @"Fehlermeldung:")]];
    self.textView.attributedText = attributedString;
}

- (void)fillTextViewForResult:(NSDictionary *)result
{
    BOOL unique = [[result valueForKey:kRESULT_FINGERPRINT_UNIQUE] isEqual:@YES];
    NSMutableAttributedString *attributedString;
    NSString *fingerprintCount = [_fpCount description];
    if (unique) {
        NSString *string;
        if ([_fpCount isEqualToNumber:[NSNumber numberWithInt:1]]) {
            string = NSLocalizedString(@"Bisher wurde nur 1 Fingerabdruck eingesendet.\n\nDa Ihr Fingerabdruck der erste ist, ist er eindeutig.", @"Bisher wurde nur 1 Fingerabdruck eingesendet.\n\nDa Ihr Fingerabdruck der erste ist, ist er eindeutig.");
        } else {
            string = [NSString stringWithFormat:NSLocalizedString(@"Bisher wurden %@ Fingerabdrücke an uns übermittelt.\n\nUnter diesen Fingerabdrücken ist ihr Fingerabdruck eindeutig.\n\nFür detaillierte Informationen darüber, welche Ihrer Fingerabdruck-Merkmale mit denen anderer Nutzer übereinstimmen, nutzen Sie bitte den nachfolgenden Button.", @"Bisher wurden %@ Fingerabdrücke an uns übermittelt.\n\nUnter diesen Fingerabdrücken ist ihr Fingerabdruck eindeutig.\n\nFür detaillierte Informationen darüber, welche Ihrer Fingerabdruck-Merkmale mit denen anderer Nutzer übereinstimmen, nutzen Sie bitte den nachfolgenden Button."), fingerprintCount];
            self.detailsButton.hidden = NO;
        }
        attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]}];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:[string rangeOfString:NSLocalizedString(@"eindeutig", @"eindeutig")]];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:[string rangeOfString:NSLocalizedString(@"nur 1", @"nur 1")]];
    } else {
        NSString *matchingFingerprints = [[result valueForKey:kRESULT_EQUAL_FINGERPRINTS] description];
        NSString *string = [NSString stringWithFormat: NSLocalizedString(@"Bisher wurden %@ Fingerabdrücke an uns übermittelt.\n\nIhr Fingerabdruck ist identisch zu %@ anderen Fingerabdrücken.\n\nFür detaillierte Informationen darüber, welche Ihrer Fingerabdruck-Merkmale mit denen anderer Nutzer übereinstimmen, nutzen Sie bitte den nachfolgenden Button.", @"Bisher wurden %@ Fingerabdrücke an uns übermittelt.\n\nIhr Fingerabdruck ist identisch zu %@ anderen Fingerabdrücken.\n\nFür detaillierte Informationen darüber, welche Ihrer Fingerabdruck-Merkmale mit denen anderer Nutzer übereinstimmen, nutzen Sie bitte den nachfolgenden Button."), fingerprintCount, matchingFingerprints];
        attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]}];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:NSMakeRange([string rangeOfString:NSLocalizedString(@"identisch zu", @"identisch zu")].location, [string rangeOfString:NSLocalizedString(@"identisch zu", @"identisch zu")].length + matchingFingerprints.length + 1)];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:NSMakeRange([string rangeOfString:NSLocalizedString(@"wurden", @"wurden (achtung: passend zu 'Bisher wurden ...')")].location + NSLocalizedString(@"wurden", @"wurden (achtung: passend zu 'Bisher wurden ...')").length, matchingFingerprints.length)];
        self.detailsButton.hidden = NO;
    }
    self.textView.attributedText = attributedString;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDetails"]) {
        ShowDetailsViewController *detailsViewController = segue.destinationViewController;
        detailsViewController.matches = _matches;
        detailsViewController.fpCount = _fpCount;
    }
}

@end
