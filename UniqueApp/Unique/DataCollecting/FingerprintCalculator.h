//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebServiceClient.h"

typedef void (^Callback)();

@interface FingerprintCalculator : NSObject

+ (id)sharedCalculator;
- (void)calculateFirstPart;
- (void)calculateSecondPartWithCompletionHandler:(Callback)callback;
- (void)sendFingerprint:(id<WebServiceClientDelegate>) delegate;

@end