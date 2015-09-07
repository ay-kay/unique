//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Keys for the fingerprint dictionary. Make sure not to use any key more than once here
 */

#define kCOOKIE                                 @"cookie"

#define kTWITTER_CANSEND                        @"canSendTweet"
#define kTWITTER_ACCOUNTS                       @"twitter"

#define kUIKIT_ACCESSIBILITY_VOICEOVER          @"voiceOver"
#define kUIKIT_ACCESSIBILITY_CLOSEDCAPTIONING   @"closedCaptioning"
#define kUIKIT_ACCESSIBILITY_GUIDEDACCESS       @"guidedAccess"
#define kUIKIT_ACCESSIBILITY_INVERTEDCOLORS     @"invertedColors"
#define kUIKIT_ACCESSIBILITY_MONOAUDIO          @"monoAudio"

#define kUIKIT_UIAPPLICATION_INSTALLED_APPS     @"apps"

#define kUIKIT_UIDEVICE_IDVENDOR                @"identifierForVendor"
#define kUIKIT_UIDEVICE_MODEL                   @"model"
#define kUIKIT_UIDEVICE_NAME                    @"name"
#define kUIKIT_UIDEVICE_IOS                     @"iosVersion"

#define kDEVICE_CONF_CARRIERNAME                @"carrierName"
#define kDEVICE_CONF_CARRIERVOIP                @"voipAllowed"
#define kDEVICE_CONF_LOCALE_COUNTRY             @"country"
#define kDEVICE_CONF_LOCALE_LANGUAGE            @"language"
#define kDEVICE_CONF_COUNTRY_LANG_DIFF          @"diff"
#define kDEVICE_CONF_KEYBOARDS                  @"keyboards"
#define kDEVICE_CONF_CAN_MAKE_PAYMENTS          @"canMakePayments"
#define kDEVICE_CONF_IS_JAILBROKEN              @"jailbreak"
#define kDEVICE_CONF_REACHABILITY_TYPE          @"reachability"
#define kDEVICE_CONF_REACHABILITY_SSID          @"wifiSSID"
#define kDEVICE_CONF_REACHABILITY_ISP           @"isp"
#define kDEVICE_CONF_REACHABILITY_IP            @"publicIP"

#define kMEDIA_TOP_50_SONGS                     @"top50Songs"
#define kMEDIA_ASSETS                           @"assets"

#define kUSER_INFO_CALENDARS                    @"calendars"
#define kUSER_INFO_REMINDERS                    @"reminders"
#define kUSER_INFO_CONTACTS                     @"contacts"

#define kPLIST_APPS                             @"plist_apps"
#define kPLIST_APPLE_ID                         @"plist_appleID"
#define kPLIST_PLAYER_ID                        @"plist_playerID"
#define kPLIST_DISKSIZE                         @"plist_disksize"
#define kPLIST_ITUNES_HOSTS                     @"plist_itunesHosts"
#define kPLIST_BATTERY                          @"plist_battery"
#define kPLIST_CODESIGNING_IDENTITIES           @"plist_codeSigningIdentities"
#define kPLIST_RINGTONE                         @"plist_ringtone"
#define kPLIST_SMSTONE                          @"plist_smstone"
#define kPLIST_CALLVIBRATION                    @"plist_callVibration"
#define kPLIST_SMSVIBRATION                     @"plist_smsVibration"

// ----------------------------------------------------------------


@interface Fingerprint : NSObject

// Information about user and device
@property (nonatomic, strong) NSMutableDictionary *fingerprintInformation;

// Helper arrays that define the order that is used to show the collected information
@property (nonatomic, strong) NSArray *orderFirst;
@property (nonatomic, strong) NSArray *orderSecond;
@property (nonatomic, strong) NSArray *orderThird;
@property (nonatomic, strong) NSDictionary *descriptions;

@property (nonatomic) BOOL isSent;

+ (id)sharedFingerprint;
- (void)setInformation:(id)value forKey:(NSString *)key;
- (void)addInformationFromDictionary:(NSDictionary *)dict;
- (void)save;
- (BOOL)hasData;
- (BOOL)clearData;
- (void)resetForNewFingerprint;
- (void)loadData;

@end
