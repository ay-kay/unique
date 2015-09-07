//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "UIKitHelper.h"
#import <sys/sysctl.h>

@implementation UIKitHelper

#pragma mark - Unprotected Information

- (void)performAction
{
    [[Fingerprint sharedFingerprint] addInformationFromDictionary:[self accessibility]];
    [[Fingerprint sharedFingerprint] addInformationFromDictionary:[self getDeviceInfo]];
    [[Fingerprint sharedFingerprint] addInformationFromDictionary:[self processSchemes]];
}

/*
 Collects information about accessibility settings
 */
- (NSDictionary *)accessibility
{
    NSMutableDictionary *accessibilityInfo = [NSMutableDictionary dictionary];
    NSNumber *voiceOver = [NSNumber numberWithBool:UIAccessibilityIsVoiceOverRunning()];
    NSNumber *closedCaptioning = [NSNumber numberWithBool:UIAccessibilityIsClosedCaptioningEnabled()];
    NSNumber *guidedAccess = [NSNumber numberWithBool:UIAccessibilityIsGuidedAccessEnabled()];
    NSNumber *invertedColors = [NSNumber numberWithBool:UIAccessibilityIsInvertColorsEnabled()];
    NSNumber *monoAudio = [NSNumber numberWithBool:UIAccessibilityIsMonoAudioEnabled()];
    [accessibilityInfo setValue:voiceOver forKey:kUIKIT_ACCESSIBILITY_VOICEOVER];
    [accessibilityInfo setValue:closedCaptioning forKey:kUIKIT_ACCESSIBILITY_CLOSEDCAPTIONING];
    [accessibilityInfo setValue:guidedAccess forKey:kUIKIT_ACCESSIBILITY_GUIDEDACCESS];
    [accessibilityInfo setValue:invertedColors forKey:kUIKIT_ACCESSIBILITY_INVERTEDCOLORS];
    [accessibilityInfo setValue:monoAudio forKey:kUIKIT_ACCESSIBILITY_MONOAUDIO];
    return accessibilityInfo;
}

/*
 Collects information about installed apps
 */
- (NSDictionary *)processSchemes
{
    NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"schemes" ofType:@"json"]];
    NSError *error;
    NSArray *schemes = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
    
    if (error) {
        ErrLog(error);
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    NSMutableArray *installedApps = [NSMutableArray array];
    
    for (NSString *scheme in schemes) {
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://asd", scheme]];
        
        if ([app canOpenURL:url]) {
            // Use md5 hash
            [installedApps addObject:[scheme md5]];
        }
    }
    
    NSDictionary *appsInfo = [NSDictionary dictionaryWithObject:installedApps forKey:kUIKIT_UIAPPLICATION_INSTALLED_APPS];
    
    return appsInfo;
}

/*
 Collects information about the device
 */
- (NSDictionary *)getDeviceInfo
{
    NSMutableDictionary *deviceInfo = [NSMutableDictionary dictionary];
    UIDevice *device = [UIDevice currentDevice];

    NSString *identifierForVendor = device.identifierForVendor.UUIDString;
    NSString *name = device.name;
    NSString *sysVersion = device.systemVersion;
    NSString *exactModel = [self platform];
    
    [deviceInfo setValue:identifierForVendor forKey:kUIKIT_UIDEVICE_IDVENDOR];
    [deviceInfo setValue:exactModel forKey:kUIKIT_UIDEVICE_MODEL];
    [deviceInfo setValue:name forKey:kUIKIT_UIDEVICE_NAME];
    [deviceInfo setValue:sysVersion forKey:kUIKIT_UIDEVICE_IOS];
    
    return deviceInfo;
}

#pragma mark - Helper Methods

- (NSString *)platform
{
    int mib[] = {CTL_HW, HW_MACHINE};
    size_t len = 0;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    char *machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}

#pragma mark -
#pragma mark - Protected Information

- (void)performActionWithCompletionHandler:(CompletionBlock)handler
{
    // keine bekannt
}

@end
