//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "UserInformationHelper.h"
#import <EventKit/EventKit.h>
#import <AddressBook/AddressBook.h>

@implementation UserInformationHelper

#pragma mark - Unprotected Information

- (void)performAction
{
    // keine bekannt
}

#pragma mark - Protected Information

- (void)performActionWithCompletionHandler:(CompletionBlock)handler
{
    [self fetchCalendarLists:handler];
    [self fetchRemindersLists:handler];
    [self fetchContacts:handler];
}

/*
 Gets the user's calender entries (name, color, type) (Async method)
 */
- (void)fetchCalendarLists:(CompletionBlock)handler
{
    EKEventStore *store = [[EKEventStore alloc] init];
    
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        // handle access here
        if (granted) {
            NSArray *calendarObjects = [store calendarsForEntityType:EKEntityTypeEvent];
            NSMutableArray *calendars = [NSMutableArray arrayWithCapacity:calendarObjects.count];
            
            for (EKCalendar *cal in calendarObjects) {
                NSString *calType;
                switch (cal.type) {
                    case EKCalendarTypeBirthday:
                        calType = @"birthday";
                        break;
                    case EKCalendarTypeCalDAV:
                        calType = @"CalDAV";
                        break;
                    case EKCalendarTypeExchange:
                        calType = @"exchange";
                        break;
                    case EKCalendarTypeLocal:
                        calType = @"local";
                        break;
                    case EKCalendarTypeSubscription:
                        calType = @"subscription";
                        break;
                    default:
                        break;
                }
                NSString *calColor = [NSString stringWithFormat:@"#%02X%02X%02X", (int)((CGColorGetComponents(cal.CGColor))[0]*255.0), (int)((CGColorGetComponents(cal.CGColor))[1]*255.0), (int)((CGColorGetComponents(cal.CGColor))[2]*255.0)];
                
                // Combine to one string and generate hash
                NSString *calendarString = [NSString stringWithFormat:@"%@%@%@", cal.title, calType, calColor];
                
                [calendars addObject:[calendarString md5]];
            }
            [calendars sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1 compare:obj2];
            }];
            [[Fingerprint sharedFingerprint] setInformation:calendars forKey:kUSER_INFO_CALENDARS];
            handler(nil);
        } else {
            handler(error);
        }
    }];
}

/*
 Gets the user's reminder entries (name, color, type) (Async method)
 */
- (void)fetchRemindersLists:(CompletionBlock)handler
{
    EKEventStore *store = [[EKEventStore alloc] init];
    
    [store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        // handle access here
        if (granted) {
            NSArray *reminderObjects = [store calendarsForEntityType:EKEntityTypeReminder];
            NSMutableArray *reminders = [NSMutableArray arrayWithCapacity:reminderObjects.count];
            
            for (EKCalendar *reminder in reminderObjects) {
                NSString *reminderType;
                switch (reminder.type) {
                    case EKCalendarTypeCalDAV:
                        reminderType = @"CalDAV";
                        break;
                    case EKCalendarTypeExchange:
                        reminderType = @"exchange";
                        break;
                    case EKCalendarTypeLocal:
                        reminderType = @"local";
                        break;
                    case EKCalendarTypeSubscription:
                        reminderType = @"subscription";
                        break;
                    default:
                        break;
                }
                NSString *reminderColor = [NSString stringWithFormat:@"#%02X%02X%02X", (int)((CGColorGetComponents(reminder.CGColor))[0]*255.0), (int)((CGColorGetComponents(reminder.CGColor))[1]*255.0), (int)((CGColorGetComponents(reminder.CGColor))[2]*255.0)];
                
                // Combine to one string and generate hash
                NSString *reminderString = [NSString stringWithFormat:@"%@%@%@", reminder.title, reminderType, reminderColor];
                
                [reminders addObject:[reminderString md5]];
            }
            [reminders sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1 compare:obj2];
            }];
            [[Fingerprint sharedFingerprint] setInformation:reminders forKey:kUSER_INFO_REMINDERS];
            handler(nil);
        } else {
            handler(error);
        }
    }];
}

/*
 Gets the user's contacts (names, mails, phones, accounts) (Async method)
 */
- (void)fetchContacts:(CompletionBlock)handler
{
    CFErrorRef *error = nil;
    ABAddressBookRef addressbook = ABAddressBookCreateWithOptions(nil, error);
    
    ABAddressBookRequestAccessWithCompletion(addressbook, ^(bool granted, CFErrorRef error) {
        if (granted) {
            CFArrayRef abpeople = ABAddressBookCopyArrayOfAllPeople(addressbook);
            
            NSMutableArray *contacts = [NSMutableArray array];
            
            for (CFIndex i = 0; i < CFArrayGetCount(abpeople); i++) {
                ABRecordRef person = CFArrayGetValueAtIndex(abpeople, i);
                NSMutableDictionary *contact = [NSMutableDictionary dictionary];
                
                NSString *firstname = (__bridge_transfer NSString*)ABRecordCopyValue(person,
                                                                                kABPersonFirstNameProperty);
                if (firstname) [contact setObject:[firstname md5] forKey:@"firstname"];
                
                NSString *lastname = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                if (lastname) [contact setObject:[lastname md5] forKey:@"lastname"];
                
                ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
                ABMultiValueRef socials = ABRecordCopyValue(person, kABPersonSocialProfileProperty);
                
                NSArray *phones = (__bridge NSArray *)(ABMultiValueCopyArrayOfAllValues(phoneNumbers));
                NSArray *mails = (__bridge NSArray *)(ABMultiValueCopyArrayOfAllValues(emails));
                NSArray *accounts = (__bridge NSArray *)(ABMultiValueCopyArrayOfAllValues(socials));
                
                if (phones) {
                    NSMutableArray *hashedPhones = [NSMutableArray arrayWithCapacity:phones.count];
                    for (NSString *entry in phones) {
                        [hashedPhones addObject:[entry md5]];
                    }
                    [contact setObject:hashedPhones forKey:@"phones"];
                }
                if (mails) {
                    NSMutableArray *hashedMails = [NSMutableArray arrayWithCapacity:mails.count];
                    for (NSString *entry in mails) {
                        [hashedMails addObject:[entry md5]];
                    }
                    [contact setObject:hashedMails forKey:@"mails"];
                }
                
                NSMutableArray *accountsToSave;
                if (accounts.count > 0) {
                    accountsToSave = [NSMutableArray arrayWithCapacity:accounts.count];
                    
                    for (NSDictionary *account in accounts) {
                                                
                        NSString *service = [account valueForKey:@"service"];
                        NSString *username = [[account valueForKey:@"username"] md5];
                        
                        [accountsToSave addObject:[NSDictionary dictionaryWithObjectsAndKeys:service, @"service", username, @"username", nil]];
                    }
                    [contact setObject:accountsToSave forKey:@"accounts"];
                }
                [contacts addObject:contact];
            }
            
            // Sort
            [contacts sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"lastname" ascending:YES], [[NSSortDescriptor alloc] initWithKey:@"firstname" ascending:YES]]];
            
            [[Fingerprint sharedFingerprint] setInformation:contacts forKey:kUSER_INFO_CONTACTS];
            handler(nil);
        } else {
            handler((__bridge NSError *)(error));
        }
    });
}

@end
