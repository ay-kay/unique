//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kREGISTER_FOR_NOTIFICATIONS_KEY @"register"
#define kPUSH_USER_DENIED               @"userDeniedPush"

typedef enum ApplicationState : NSInteger {
    ApplicationStateStart = 0,
    ApplicationStateInformed,
    ApplicationStateCollected,
    ApplicationStateShowed,
    ApplicationStateSent
} ApplicationState;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) ApplicationState applicationState;

@end
