//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "Fingerprint.h"

@implementation Fingerprint

+ (id)sharedFingerprint
{
    static dispatch_once_t once_token;
    static id sharedInstance;
    dispatch_once(&once_token, ^{
        sharedInstance = [[Fingerprint alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _fingerprintInformation = [NSMutableDictionary dictionary];
        self.orderFirst = @[
                        kDEVICE_CONF_IS_JAILBROKEN,
                        kUIKIT_UIDEVICE_MODEL,
                        kUIKIT_UIDEVICE_IOS,
                        kUIKIT_UIDEVICE_NAME,
                        kUIKIT_UIDEVICE_IDVENDOR,
                        kDEVICE_CONF_CARRIERNAME,
                        kDEVICE_CONF_CARRIERVOIP,
                        kDEVICE_CONF_LOCALE_COUNTRY,
                        kDEVICE_CONF_LOCALE_LANGUAGE,
                        kDEVICE_CONF_COUNTRY_LANG_DIFF,
                        kDEVICE_CONF_KEYBOARDS,
                        kDEVICE_CONF_CAN_MAKE_PAYMENTS,
                        kDEVICE_CONF_REACHABILITY_TYPE,
                        kDEVICE_CONF_REACHABILITY_SSID,
                        kDEVICE_CONF_REACHABILITY_IP,
                        kDEVICE_CONF_REACHABILITY_ISP,
                        kUIKIT_ACCESSIBILITY_VOICEOVER,
                        kUIKIT_ACCESSIBILITY_CLOSEDCAPTIONING,
                        kUIKIT_ACCESSIBILITY_GUIDEDACCESS,
                        kUIKIT_ACCESSIBILITY_INVERTEDCOLORS,
                        kUIKIT_ACCESSIBILITY_MONOAUDIO,
                        kTWITTER_CANSEND,
                        kUIKIT_UIAPPLICATION_INSTALLED_APPS,
                        kMEDIA_TOP_50_SONGS
                        ];
        self.orderSecond = @[
                         kMEDIA_ASSETS,
                         kUSER_INFO_CALENDARS,
                         kUSER_INFO_REMINDERS,
                         kUSER_INFO_CONTACTS,
                         kTWITTER_ACCOUNTS
                         ];
        self.orderThird = @[
                        kPLIST_APPLE_ID,
                        kPLIST_PLAYER_ID,
                        kPLIST_DISKSIZE,
                        kPLIST_BATTERY,
                        kPLIST_RINGTONE,
                        kPLIST_SMSTONE,
                        kPLIST_CALLVIBRATION,
                        kPLIST_SMSVIBRATION,
                        kPLIST_ITUNES_HOSTS,
                        kPLIST_CODESIGNING_IDENTITIES,
                        kPLIST_APPS
                        ];
        self.descriptions = @{
                              kTWITTER_CANSEND: NSLocalizedString(@"Twitter eingerichtet", @"Twitter eingerichtet"),
                              kTWITTER_ACCOUNTS: NSLocalizedString(@"Twitter-Account", @"Twitter-Account"),
                              kUIKIT_ACCESSIBILITY_VOICEOVER: NSLocalizedString(@"VoiceOver an", @"VoiceOver an"),
                              kUIKIT_ACCESSIBILITY_CLOSEDCAPTIONING: NSLocalizedString(@"Zoom ein", @"Zoom ein"),
                              kUIKIT_ACCESSIBILITY_GUIDEDACCESS: NSLocalizedString(@"Geführter Zugriff ein", @"Geführter Zugriff ein"),
                              kUIKIT_ACCESSIBILITY_INVERTEDCOLORS: NSLocalizedString(@"Farben umkehren ein", @"Farben umkehren ein"),
                              kUIKIT_ACCESSIBILITY_MONOAUDIO: NSLocalizedString(@"Mono-Audio ein", @"Mono-Audio ein"),
                              kUIKIT_UIAPPLICATION_INSTALLED_APPS: NSLocalizedString(@"Apps (Auswahl)", @"Apps (Auswahl)"),
                              kUIKIT_UIDEVICE_IDVENDOR: NSLocalizedString(@"identifierForVendor", @"identifierForVendor"),
                              kUIKIT_UIDEVICE_MODEL: NSLocalizedString(@"Gerätemodell", @"Gerätemodell"),
                              kUIKIT_UIDEVICE_NAME: NSLocalizedString(@"Gerätename", @"Gerätename"),
                              kUIKIT_UIDEVICE_IOS: NSLocalizedString(@"Systemversion", @"Systemversion"),
                              kDEVICE_CONF_CARRIERNAME: NSLocalizedString(@"Mobilfunkanbieter", @"Mobilfunkanbieter"),
                              kDEVICE_CONF_CARRIERVOIP: NSLocalizedString(@"Anbieter erlaubt VOIP", @"Anbieter erlaubt VOIP"),
                              kDEVICE_CONF_LOCALE_COUNTRY: NSLocalizedString(@"Eingestelltes Land", @"Eingestelltes Land"),
                              kDEVICE_CONF_LOCALE_LANGUAGE: NSLocalizedString(@"Eingestellte Sprache", @"Eingestellte Sprache"),
                              kDEVICE_CONF_COUNTRY_LANG_DIFF: NSLocalizedString(@"Land ≠ Sprache", @"Land ≠ Sprache"),
                              kDEVICE_CONF_KEYBOARDS: NSLocalizedString(@"Installierte Tastaturen", @"Installierte Tastaturen"),
                              kDEVICE_CONF_CAN_MAKE_PAYMENTS: NSLocalizedString(@"In-App-Kauf erlaubt", @"In-App-Kauf erlaubt"),
                              kDEVICE_CONF_IS_JAILBROKEN: NSLocalizedString(@"Jailbreak installiert", @"Jailbreak installiert"),
                              kDEVICE_CONF_REACHABILITY_TYPE: NSLocalizedString(@"Internetverbindung", @"Internetverbindung"),
                              kDEVICE_CONF_REACHABILITY_SSID: NSLocalizedString(@"WLAN-Name", @"WLAN-Name"),
                              kDEVICE_CONF_REACHABILITY_IP: NSLocalizedString(@"Öffentliche IP", @"Öffentliche IP"),
                              kDEVICE_CONF_REACHABILITY_ISP: NSLocalizedString(@"Internetanbieter", @"Internetanbieter"),
                              kMEDIA_TOP_50_SONGS: NSLocalizedString(@"Top 50 Songs", @"Top 50 Songs"),
                              kMEDIA_ASSETS: NSLocalizedString(@"Fotoalben (Namen)", @"Fotoalben (Namen)"),
                              kUSER_INFO_CALENDARS: NSLocalizedString(@"Kalender (Namen)", @"Kalender (Namen)"),
                              kUSER_INFO_REMINDERS: NSLocalizedString(@"Erinnerungen (Namen)", @"Erinnerungen (Namen)"),
                              kUSER_INFO_CONTACTS: NSLocalizedString(@"Kontakte", @"Kontakte"),
                              kPLIST_APPS: NSLocalizedString(@"Alle installierten Apps", @"Alle installierten Apps"),
                              kPLIST_APPLE_ID: NSLocalizedString(@"Ihre Apple-ID", @"Ihre Apple-ID"),
                              kPLIST_PLAYER_ID: NSLocalizedString(@"Game-Center Player-ID", @"Game-Center Player-ID"),
                              kPLIST_DISKSIZE: NSLocalizedString(@"Speichergröße", @"Speichergröße"),
                              kPLIST_ITUNES_HOSTS: NSLocalizedString(@"ID Ihres iTunes", @"ID Ihres iTunes"),
                              kPLIST_BATTERY: NSLocalizedString(@"Batterie in Prozent anzeigen", @"Batterie in Prozent anzeigen"),
                              kPLIST_CODESIGNING_IDENTITIES: NSLocalizedString(@"Code-Signing IDs", @"Code-Signing IDs"),
                              kPLIST_RINGTONE: NSLocalizedString(@"Klingelton", @"Klingelton"),
                              kPLIST_SMSTONE: NSLocalizedString(@"SMS-Ton", @"SMS-Ton"),
                              kPLIST_CALLVIBRATION: NSLocalizedString(@"Vibrationsmuster Anruf", @"Vibrationsmuster Anruf"),
                              kPLIST_SMSVIBRATION: NSLocalizedString(@"Vibrationsmuster SMS", @"Vibrationsmuster SMS")
                              };
        self.isSent = NO;
    }
    return self;
}

- (void)setInformation:(id)value forKey:(NSString *)key
{
    [self.fingerprintInformation setValue:value forKey:key];
}

- (void)addInformationFromDictionary:(NSDictionary *)dict
{
    [self.fingerprintInformation addEntriesFromDictionary:dict];
}

- (void)save
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.fingerprintInformation options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error) {
        ErrLog(error);
    }
    
    [jsonData writeToFile:[self jsonPath] atomically:YES];
}

- (void)setIsSent:(BOOL)isSent
{
    _isSent = isSent;
    
    if (_isSent) {
        [self save];
    }    
}

- (BOOL)hasData
{
    return self.fingerprintInformation.count > 0;
}

- (void)resetForNewFingerprint
{
    // Sichere bisherigen Fingerabdruck
    if ([self hasData]) {
        [self.fingerprintInformation removeAllObjects];
    }
}

- (BOOL)clearData
{
    if (_fingerprintInformation.count > 0) {
        // Leere fingerprintInformation dictionary
        [self.fingerprintInformation removeAllObjects];
        
        // Lösche fingerprint.json aus Filesystem
        NSError *error;
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *path = [self jsonPath];
        BOOL isDir;
        if ([fm fileExistsAtPath:path isDirectory:&isDir]) {
            [[NSFileManager defaultManager] removeItemAtPath:[self jsonPath] error:&error];
            if (error) {
                ErrLog(error);
                return NO;
            }
        }
    }
    self.isSent = NO;
    
    return YES;
}

- (void)loadData
{
    // Lade aktuellen Fingerprint
    NSString *path = [self jsonPath];
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
        NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
        NSError *error;
        self.fingerprintInformation = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            ErrLog(error);
        }
    }
    else {
        if (!self.fingerprintInformation) {
            self.fingerprintInformation = [NSMutableDictionary dictionary];
        }
    }
}

- (NSString *)jsonPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:@"fingerprint.json"];
    return path;
}

@end
