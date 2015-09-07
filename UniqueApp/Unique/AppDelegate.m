//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "AppDelegate.h"
#import "Fingerprint.h"
#import "WebServiceClient.h"
#import "RootViewController.h"

#import <AudioToolbox/AudioServices.h>

#define kAPPLICATION_STATE      @"applicationState"

@implementation AppDelegate

- (void)updateUIForNotification:(NSDictionary *)notification
{
    UINavigationController *navigationController = (UINavigationController*)_window.rootViewController;
    RootViewController *rootViewController =
    (RootViewController *)[navigationController.viewControllers  objectAtIndex:0];
    [rootViewController updateUI];
}

- (void)setApplicationState:(ApplicationState)newState
{
    [[NSUserDefaults standardUserDefaults] setInteger:newState forKey:kAPPLICATION_STATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (ApplicationState)applicationState
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kAPPLICATION_STATE];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Check NSUserDefaults
    BOOL registerForNotifications = [[NSUserDefaults standardUserDefaults] boolForKey:kREGISTER_FOR_NOTIFICATIONS_KEY];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    // Register for Push Notifications
    if (registerForNotifications) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    if (launchOptions)
	{
		NSDictionary *dictionary = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary)
		{
            [self updateUIForNotification:dictionary];
		}
	}
    return YES;
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	if (userInfo) {
        [self updateUIForNotification:userInfo];
    }
    
    if (application.applicationState == UIApplicationStateActive) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSound(1002);
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	// Send device Token to Server
    [[WebServiceClient sharedClient] sendPushNotificationToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    // Registering failed
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[Fingerprint sharedFingerprint] loadData];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
