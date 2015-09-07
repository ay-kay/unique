//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "TwitterHelper.h"
#import "Fingerprint.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@implementation TwitterHelper

#pragma mark - Unprotected Information

- (void)performAction
{
    // Get Data
    #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    BOOL canSendTweet = [TWTweetComposeViewController canSendTweet];
    #pragma GCC diagnostic warning "-Wdeprecated-declarations"
    
    // Insert into fingerprint
    [[Fingerprint sharedFingerprint] setInformation:[NSNumber numberWithBool:canSendTweet] forKey:kTWITTER_CANSEND];
}

#pragma mark - Protected Information

- (void)performActionWithCompletionHandler:(CompletionBlock)handler
{
    if ([[[[Fingerprint sharedFingerprint] fingerprintInformation] valueForKey:kTWITTER_CANSEND] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        [self getInfo:handler];
    } else {
        NSError *error = [NSError errorWithDomain:@"MyErrorDomain" code:404 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"Kein Twitter eingerichtet", @"Kein Twitter eingerichtet")}];
        handler(error);
    }
}

/*
 Gets the user's twitter account (Async method)
 */
- (void)getInfo:(CompletionBlock)handler
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:twitterType];
            if (accounts.count > 0) {
                NSMutableArray *twAccArray = [NSMutableArray arrayWithCapacity:accounts.count];
                // mind. ein Twitter-Account registriert
                for (ACAccount *twitterAcc in accounts) {
                    // Use md5 of username!
                    [twAccArray addObject:[twitterAcc.username md5]];
                }
                [twAccArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    return [obj1 compare:obj2];
                }];
                [[Fingerprint sharedFingerprint] addInformationFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:twAccArray, kTWITTER_ACCOUNTS, nil]];
                handler(nil);
            } else {
                // Kein Twitter eingerichtet
                NSError *error = [NSError errorWithDomain:@"MyErrorDomain" code:404 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"Kein Twitter eingerichtet", @"Kein Twitter eingerichtet")}];
                handler(error);
            }
        } else {
            handler(error);
        }
    }];
}

@end
