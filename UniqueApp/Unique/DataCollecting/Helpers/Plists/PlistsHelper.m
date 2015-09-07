//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "PlistsHelper.h"
#import "Fingerprint.h"

@implementation PlistsHelper {
    NSArray *_myArray;
}

- (id)init
{
    self = [super init];
    if (self) {
        _myArray = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"com.nesolabs.paths" ofType:nil]];
    }
    return self;
}

- (void)performAction
{
    [[Fingerprint sharedFingerprint] addInformationFromDictionary:[self readIconCache]];
    [[Fingerprint sharedFingerprint] addInformationFromDictionary:[self homeSharing]];
    [[Fingerprint sharedFingerprint] addInformationFromDictionary:[self gameCenterPlayerID]];
    [[Fingerprint sharedFingerprint] addInformationFromDictionary:[self settings]];
    [[Fingerprint sharedFingerprint] addInformationFromDictionary:[self usageInfo]];
}

/*
 Gets all installed apps
 */
- (NSDictionary *)readIconCache
{
    NSString *iconsDir = [_myArray objectAtIndex:0];
    NSMutableSet *apps = [NSMutableSet set];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnumerator = [fm enumeratorAtPath:iconsDir];
    NSString *path;
    while(path = [dirEnumerator nextObject]) {
        NSString *concretePath = [NSString stringWithFormat:@"%@/%@", iconsDir, path];
        if([fm isReadableFileAtPath:concretePath]) {
            NSArray *parts = [path componentsSeparatedByString:@"_"];
            if ([parts[0] length] > 1) {
                [apps addObject:[parts[0] md5]];
            }
        }
    }
    NSArray *appsArray = [[apps allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    return [NSDictionary dictionaryWithObject:appsArray forKey:kPLIST_APPS];
}

/*
 Gets the user's appleID
 */
- (NSDictionary *)homeSharing
{
    NSString *path = [_myArray objectAtIndex:1];
    NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSString *appleID = [plist valueForKey:@"homeSharingAppleID"];
    if (appleID) {
        return [NSDictionary dictionaryWithObject:[appleID md5] forKey:kPLIST_APPLE_ID];
    } else {
        return nil;
    }
}

/*
 Gets the user's gameCenter playerID
 */
- (NSDictionary *)gameCenterPlayerID
{
    NSString *path = [_myArray objectAtIndex:2];
    NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSString *playerID = [[[plist valueForKey:@"GKLastPushTokenPlayerID"] componentsSeparatedByString:@":"] objectAtIndex:1];
    if (playerID) {
        return [NSDictionary dictionaryWithObject:[playerID md5] forKey:kPLIST_PLAYER_ID];
    } else {
        return nil;
    }
}

/*
 Gets some device configuration settings (ringtone, smstone, vibration patterns) and the code signing identities
 */
- (NSDictionary *)settings
{
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithCapacity:6];
    
    NSString *path = [_myArray objectAtIndex:3];
    NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSNumber *batteryPercentageBOOL = [plist valueForKey:@"SBShowBatteryPercentage"];
    NSArray *codeSigningIdentities = [plist valueForKey:@"SBTrustedCodeSigningIdentities"];
    NSString *ringtone = [plist valueForKey:@"ringtone"];
    NSString *smstone = [plist valueForKey:@"sms-sound-identifier"];
    NSString *callVibration = [plist valueForKey:@"SystemCallVibrationIdentifier"];
    NSString *smsVibration = [plist valueForKey:@"SystemTextMessageVibrationIdentifier"];
    
    NSMutableArray *codeSignings = [NSMutableArray arrayWithCapacity:codeSigningIdentities.count];
    for (NSString *identity in codeSigningIdentities) {
        [codeSignings addObject:[identity md5]];
    }
    
    if (batteryPercentageBOOL)
        [infoDict setValue:batteryPercentageBOOL forKey:kPLIST_BATTERY];
    if (codeSignings)
        [infoDict setValue:[codeSignings sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }] forKey:kPLIST_CODESIGNING_IDENTITIES];
    if (ringtone)
        [infoDict setValue:ringtone forKey:kPLIST_RINGTONE];
    if (smstone)
        [infoDict setValue:smstone forKey:kPLIST_SMSTONE];
    if (callVibration)
        [infoDict setValue:callVibration forKey:kPLIST_CALLVIBRATION];
    if (smsVibration)
        [infoDict setValue:smsVibration forKey:kPLIST_SMSVIBRATION];
    
    return infoDict;
}

/*!
 Gets the disk size and itunes hosts
 */
- (NSDictionary *)usageInfo
{
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithCapacity:2];
    NSString *path = [_myArray objectAtIndex:4];
    NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSNumber *diskSize = [[plist valueForKey:@"DiskUsage"] valueForKey:@"_PhysicalSize"];
    if (diskSize) {
        [infoDict setValue:[diskSize description] forKey:kPLIST_DISKSIZE];
    }
    
    NSMutableArray *hosts = [NSMutableArray array];
    NSDictionary *hostsDict = [plist valueForKey:@"Hosts"];
    for (NSString *key in hostsDict) {
        NSString *libraryID = [[hostsDict valueForKey:key] valueForKey:@"LibraryID"];
        NSString *syncHost = [[hostsDict valueForKey:key] valueForKey:@"SyncHostName"];
        if (syncHost && libraryID) {
            [hosts addObject:[NSDictionary dictionaryWithObjectsAndKeys:[libraryID md5], @"libraryID", [syncHost md5], @"syncHost", nil]];
        }
    }
    
    if (hosts.count > 0) {
        [infoDict setValue:[hosts sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj1 valueForKey:@"syncHost"] compare:[obj2 valueForKey:@"syncHost"]];
        }] forKey:kPLIST_ITUNES_HOSTS];
    }
    
    return infoDict;
}

- (void)performActionWithCompletionHandler:(CompletionBlock)handler
{
    // keine bekannt
}

@end
