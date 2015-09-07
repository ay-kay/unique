//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "FingerprintCalculator.h"
#import "UIKitHelper.h"
#import "TwitterHelper.h"
#import "DeviceConfigurationHelper.h"
#import "UserInformationHelper.h"
#import "MediaHelper.h"
#import "PlistsHelper.h"

@implementation FingerprintCalculator {
    NSMutableDictionary *_data;
}

+ (id)sharedCalculator
{
    static dispatch_once_t once_token;
    static id sharedInstance;
    dispatch_once(&once_token, ^{
        sharedInstance = [[FingerprintCalculator alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _data = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)calculateFirstPart
{
    // clear old fingerprint-data
    [[Fingerprint sharedFingerprint] resetForNewFingerprint];
    
    TwitterHelper *socialHelper = [[TwitterHelper alloc] init];
    UIKitHelper *uikitHelper = [[UIKitHelper alloc] init];
    DeviceConfigurationHelper *deviceConfHelper = [[DeviceConfigurationHelper alloc] init];
    MediaHelper *mediaHelper = [[MediaHelper alloc] init];
    PlistsHelper *listsHelper = [[PlistsHelper alloc] init];
    
    /*
     "Free" Information
     */
    
    [socialHelper performAction];
    [uikitHelper performAction];
    [deviceConfHelper performAction];
    [mediaHelper performAction];
    [listsHelper performAction];
    
    [self saveFingerprint];
}

- (void)calculateSecondPartWithCompletionHandler:(Callback)callback
{
    TwitterHelper *socialHelper = [[TwitterHelper alloc] init];
    MediaHelper *mediaHelper = [[MediaHelper alloc] init];
    UserInformationHelper *userInformationHelper = [[UserInformationHelper alloc] init];
    
    /*
     Protected Information
     */
    
    // Einige der folgenden Abfragen sind asynchron. Zaehle die Ergebnisse und speichere dann.
    __block int count = 0;
    CompletionBlock block = ^(NSError *error) {
        if (error) {
            ErrLog(error);
        }
        @synchronized(self) {
            count++;
            if (count == 5) {
                [self saveFingerprint];
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback();
                });
            }
        }
    };
    [socialHelper performActionWithCompletionHandler:block];
    [mediaHelper performActionWithCompletionHandler:block];
    [userInformationHelper performActionWithCompletionHandler:block];
}

- (void)saveFingerprint
{
    // Save all information
    [[Fingerprint sharedFingerprint] save];
}

- (void)sendFingerprint:(id<WebServiceClientDelegate>) delegate
{
    // Send data
    [[WebServiceClient sharedClient] sendFingerprint:[Fingerprint sharedFingerprint] delegate:delegate];
}

@end
