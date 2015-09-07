//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "ShowInfoDetailsViewController.h"

typedef enum DetailsType : NSInteger {
    StringType       = 0,
    DictionaryType  = 1
} DetailsType;

@implementation ShowInfoDetailsViewController {
    DetailsType _type;
    NSDictionary *_descriptions;
}

- (IBAction)backToStart:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _descriptions = @{
                          @"firstname"  : NSLocalizedString(@"Vorname", @"Vorname"),
                          @"lastname"   : NSLocalizedString(@"Nachname", @"Nachname"),
                          @"phones"     : NSLocalizedString(@"Telefonnummern", @"Telefonnummern"),
                          @"mails"      : NSLocalizedString(@"Email-Adressen", @"Email-Adressen"),
                          @"accounts"   : NSLocalizedString(@"Accounts", @"Accounts"),
                          @"album"      : NSLocalizedString(@"Album", @"Album"),
                          @"artist"     : NSLocalizedString(@"Interpret", @"Interpret"),
                          @"title"      : NSLocalizedString(@"Titel", @"Titel"),
                          @"libraryID"  : NSLocalizedString(@"ID Ihrer iTunes-Library", @"ID Ihrer iTunes-Library"),
                          @"syncHost"   : NSLocalizedString(@"Computername", @"Computername")
                          };
    }
    return self;
}

- (void)setDetails:(id)details
{
    _details = details;
    if ([[_details objectAtIndex:0] isKindOfClass:[NSString class]]) {
        _type = StringType;
    } else {
        _type = DictionaryType;
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount;
    switch (_type) {
        case StringType:
            sectionCount = 1;
            break;
        case DictionaryType:
            sectionCount = self.details.count;
            break;
        default:
            break;
    }
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    switch (_type) {
        case StringType:
            rowCount = self.details.count;
            break;
        case DictionaryType:
            rowCount = [[self.details objectAtIndex:section] count];
            break;
        default:
            break;
    }
    return rowCount;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (_type == StringType) {
        cell.textLabel.text = [self.details objectAtIndex:indexPath.row];
    } else {
        NSString *key = [[[self.details objectAtIndex:indexPath.section] allKeys] objectAtIndex:indexPath.row];
        id value = [[self.details objectAtIndex:indexPath.section] valueForKey:key];
        
        if ([value isKindOfClass:[NSArray class]]) {
            value = NSLocalizedString(@"Mehrere Einträge...", @"Mehrere Einträge...");
        }
        cell.textLabel.text = [_descriptions valueForKey:key];
        cell.detailTextLabel.text = value;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    
    switch (_type) {
        case StringType:
            CellIdentifier = @"basicCell";
            break;
        case DictionaryType:
            CellIdentifier = @"subtitleCell";
            break;
        default:
            break;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_type == DictionaryType) {
        return [NSString stringWithFormat:@"%ld", section + 1];
    }
    return nil;
}

@end
