//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WebServiceClientDelegate;
@class Fingerprint;

@interface WebServiceClient : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate>

+ (id)sharedClient;
- (void)sendFingerprint:(Fingerprint *)fingerprintData delegate:(id<WebServiceClientDelegate>)delegate;
- (void)sendPushNotificationToken:(NSData *)token;

@end

@protocol WebServiceClientDelegate <NSObject>

@required
- (void)sendingFingerprintFinishedWithResult:(NSDictionary *)result;

@end