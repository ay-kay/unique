//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fingerprint.h"

typedef void (^CompletionBlock)(NSError*);

@protocol Helper <NSObject>

@required

- (void)performAction;
- (void)performActionWithCompletionHandler:(CompletionBlock)handler;

@end

