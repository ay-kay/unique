//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "DeviceConfigurationHelper.h"
#import "Reachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <StoreKit/StoreKit.h>
#import <sys/stat.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

@implementation DeviceConfigurationHelper

#pragma mark - Unprotected Information

- (void)performAction
{
    [[Fingerprint sharedFingerprint] addInformationFromDictionary:[self configuration]];
    [[Fingerprint sharedFingerprint] addInformationFromDictionary:[self reachability]];
}

/*
 Collects information about device configuration
 */
- (NSDictionary *)configuration
{
    NSMutableDictionary *deviceInfo = [NSMutableDictionary dictionary];
    
    NSString *carrierName = [[[[CTTelephonyNetworkInfo alloc] init] subscriberCellularProvider] carrierName];
    NSNumber *carrierVOIP = [NSNumber numberWithBool:[[[[CTTelephonyNetworkInfo alloc] init] subscriberCellularProvider] allowsVOIP]];
    NSString *country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSNumber *diff = [[[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode] lowercaseString] isEqualToString:language.lowercaseString] ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES];
    NSArray *keyboards = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleKeyboards"];
    NSNumber *canMakePayments = [SKPaymentQueue canMakePayments] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
    NSNumber *isJailbroken = [NSNumber numberWithBool:isJB()];
    
    // Enter data in dictionary
    [deviceInfo setValue:carrierName forKey:kDEVICE_CONF_CARRIERNAME];
    [deviceInfo setValue:carrierVOIP forKey:kDEVICE_CONF_CARRIERVOIP];
    [deviceInfo setValue:country forKey:kDEVICE_CONF_LOCALE_COUNTRY];
    [deviceInfo setValue:language forKey:kDEVICE_CONF_LOCALE_LANGUAGE];
    [deviceInfo setValue:diff forKey:kDEVICE_CONF_COUNTRY_LANG_DIFF];
    [deviceInfo setValue:keyboards forKey:kDEVICE_CONF_KEYBOARDS];
    [deviceInfo setValue:canMakePayments forKey:kDEVICE_CONF_CAN_MAKE_PAYMENTS];
    [deviceInfo setValue:isJailbroken forKey:kDEVICE_CONF_IS_JAILBROKEN];
    
    return deviceInfo;
}

/*
 Gets the current reachability
 */
- (NSDictionary *)reachability
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    NSString *statusString;
    NSMutableDictionary *reachabilityInfo = [NSMutableDictionary dictionary];
    
    switch (netStatus) {
        case NotReachable:
            statusString = @"none";
            break;
        case ReachableViaWWAN: {
            statusString = @"wwan";
            break;
        }
        case ReachableViaWiFi: {
            statusString = @"wifi";
            [reachabilityInfo setValue:[self fetchWifiSSID] forKey:kDEVICE_CONF_REACHABILITY_SSID];
            break;
        }
    }
    [reachabilityInfo setValue:statusString forKey:kDEVICE_CONF_REACHABILITY_TYPE];
    [self performSelectorInBackground:@selector(fetchPublicIPAddress) withObject:nil];
    
    return reachabilityInfo;
}

BOOL isJB()
{
    
#if !TARGET_IPHONE_SIMULATOR
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://asd"]]) {
        return YES;
    }
    
    // SandBox Integrity Check
    int pid = fork();
    if (!pid) {
        exit(0);
    }
    if (pid >= 0) {
        return YES;
    }
    
#endif
    return NO;
}

#pragma mark - Auxiliary methods

- (NSString *)fetchWifiSSID
{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
    }
    NSDictionary *infoDict = (NSDictionary *)info;
    
    return [infoDict valueForKey:@"SSID"];
}

- (void)fetchPublicIPAddress
{
    NSData *ipData;
    Reachability *hostReachability = [Reachability reachabilityWithHostName:@"www.ip-api.com"];
    if ([hostReachability currentReachabilityStatus] != NotReachable) {
        ipData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://ip-api.com/json"]];
        if (ipData) {
            NSDictionary *ipApiDict = [NSJSONSerialization JSONObjectWithData:ipData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[ipApiDict valueForKey:@"query"], kDEVICE_CONF_REACHABILITY_IP, [ipApiDict valueForKey:@"isp"], kDEVICE_CONF_REACHABILITY_ISP, nil];
            [[Fingerprint sharedFingerprint] addInformationFromDictionary:info];
        }
    }
}

#pragma mark -
#pragma mark - Protected Information

- (void)performActionWithCompletionHandler:(CompletionBlock)handler
{
    // keine bekannt
}

@end
