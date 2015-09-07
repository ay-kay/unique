//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "ShowAllInfoViewController.h"
#import "Fingerprint.h"
#import "ShowInfoDetailsViewController.h"
#import "AppDelegate.h"

#define kSECTION_FREE_DATA      0
#define KSECTION_PROTECTED_DATA 1
#define KSECTION_PLIST_DATA     2


@implementation ShowAllInfoViewController {
    NSDictionary *_information;
    NSDictionary *_descriptions;
    NSMutableArray *_firstSectionKeys;
    NSMutableArray *_secondSectionKeys;
    NSMutableArray *_thirdSectionKeys;
    NSArray *_details;
}

- (IBAction)barButtonItemPressed:(UIBarButtonItem *)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _information = [NSDictionary dictionaryWithDictionary:[[Fingerprint sharedFingerprint] fingerprintInformation]];
        _descriptions = [NSDictionary dictionaryWithDictionary:[[Fingerprint sharedFingerprint] descriptions]];
        NSArray *infoKeys = _information.allKeys;
        
        _firstSectionKeys = [NSMutableArray arrayWithArray:[[Fingerprint sharedFingerprint] orderFirst]];
        _secondSectionKeys = [NSMutableArray arrayWithArray:[[Fingerprint sharedFingerprint] orderSecond]];
        _thirdSectionKeys = [NSMutableArray arrayWithArray:[[Fingerprint sharedFingerprint] orderThird]];
        
        NSMutableArray *keysToRemove = [NSMutableArray array];
        
        for (NSString *key in _firstSectionKeys) {
            if (![infoKeys containsObject:key]) {
                [keysToRemove addObject:key];
            }
        }
        for (NSString *key in _secondSectionKeys) {
            if (![infoKeys containsObject:key]) {
                [keysToRemove addObject:key];
            }
        }
        for (NSString *key in _thirdSectionKeys) {
            if (![infoKeys containsObject:key]) {
                [keysToRemove addObject:key];
            }
        }
        
        [_firstSectionKeys removeObjectsInArray:keysToRemove];
        [_secondSectionKeys removeObjectsInArray:keysToRemove];
        [_thirdSectionKeys removeObjectsInArray:keysToRemove];
    }
    return self;
}

- (void)viewDidLoad
{
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setApplicationState:ApplicationStateShowed];
    if (self.navigationController.viewControllers.count == 2) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *text;
    NSString *detailText;
    switch (indexPath.section) {
        case kSECTION_FREE_DATA:
            text = [_firstSectionKeys objectAtIndex:indexPath.row];
            break;
        case KSECTION_PROTECTED_DATA:
            text = [_secondSectionKeys objectAtIndex:indexPath.row];
            break;
        case KSECTION_PLIST_DATA:
            text = [_thirdSectionKeys objectAtIndex:indexPath.row];
        default:
            break;
    }
    cell.textLabel.text = [_descriptions valueForKey:text];
    
    id object = [_information valueForKey:text];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if ([object isKindOfClass:[NSString class]]) {
        detailText = object;
    } else if ([object isKindOfClass:[NSNumber class]]) {
        detailText = (object == [NSNumber numberWithBool:YES]) ? NSLocalizedString(@"Ja", @"Ja") : NSLocalizedString(@"Nein", @"Nein");
    } else if ([object isKindOfClass:[NSArray class]]) {
        
        if ([object count] > 0) {
            detailText = NSLocalizedString(@"mehr...", @"mehr...");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            detailText = @"n/a";
        }
    }
    cell.detailTextLabel.text = detailText;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[tableView cellForRowAtIndexPath:indexPath] accessoryType] == UITableViewCellAccessoryDisclosureIndicator) {
        NSString *key;
        switch (indexPath.section) {
            case kSECTION_FREE_DATA:
                key = [_firstSectionKeys objectAtIndex:indexPath.row];
                break;
            case KSECTION_PROTECTED_DATA:
                key = [_secondSectionKeys objectAtIndex:indexPath.row];
                break;
            case KSECTION_PLIST_DATA:
                key = [_thirdSectionKeys objectAtIndex:indexPath.row];
            default:
                break;
        }
        _details = [_information valueForKey:key];
        [self performSegueWithIdentifier:@"showDetails" sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDetails"]) {
        ShowInfoDetailsViewController *detailsViewController = segue.destinationViewController;
        detailsViewController.details = _details;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"basicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    switch (section) {
        case kSECTION_FREE_DATA:
            rowCount = _firstSectionKeys.count;
            break;
        case KSECTION_PROTECTED_DATA:
            rowCount = _secondSectionKeys.count;
            break;
        case KSECTION_PLIST_DATA:
            rowCount = _thirdSectionKeys.count;
        default:
            break;
    }
    return rowCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    switch (section) {
        case kSECTION_FREE_DATA:
            title = NSLocalizedString(@"Frei zugängig", @"Frei zugängig");
            break;
        case KSECTION_PROTECTED_DATA:
            title = NSLocalizedString(@"Mit Erlaubnis", @"Mit Erlaubnis");
            break;
        case KSECTION_PLIST_DATA:
            title = NSLocalizedString(@"Aus Dateisystem", @"Aus Dateisystem");
        default:
            break;
    }
    return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == KSECTION_PROTECTED_DATA && _secondSectionKeys.count == 0) {
        return NSLocalizedString(@"Keine Erlaubnis erhalten", @"Keine Erlaubnis erhalten");
    }
    return nil;
}

@end
