//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "MediaHelper.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation MediaHelper

#pragma mark - Unprotected Information

- (void)performAction;
{
    [[Fingerprint sharedFingerprint] addInformationFromDictionary:[self top50Songs]];
}

- (NSDictionary *)top50Songs
{
    // Get all songs and sort by playCount
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    NSArray *titles = [query items];
    
    if (titles.count < 50) {
        return nil;
    }
    
    NSArray *topTitles = [titles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSNumber *count1 = [obj1 valueForProperty:MPMediaItemPropertyPlayCount];
        NSNumber *count2 = [obj2 valueForProperty:MPMediaItemPropertyPlayCount];
        
        return [count1 integerValue] < [count2 integerValue];
    }];
    
    // Get the top 50 songs
    NSMutableArray *top50 = [NSMutableArray arrayWithCapacity:50];
    NSDictionary *title;
    
    for (int i = 0; i < 50; i++) {
        MPMediaItem *item = [topTitles objectAtIndex:i];
        title = [NSDictionary dictionaryWithObjectsAndKeys:[[item valueForProperty:MPMediaItemPropertyTitle] md5], @"title", [[item valueForProperty:MPMediaItemPropertyArtist] md5], @"artist", [[item valueForProperty:MPMediaItemPropertyAlbumTitle] md5], @"album" , nil];
        [top50 addObject:title];
    }
    
    [top50 sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 valueForKey:@"title"] compare:[obj2 valueForKey:@"title"]];
    }];
    
    return [NSDictionary dictionaryWithObject:top50 forKey:kMEDIA_TOP_50_SONGS];
}

#pragma mark - Protected Information

- (void)performActionWithCompletionHandler:(CompletionBlock)handler
{
    [self cameraRollAlbumNames:handler];
}

- (void)cameraRollAlbumNames:(CompletionBlock)handler
{
    NSMutableArray *groups = [NSMutableArray array];
    
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group == nil) {
            [groups sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1 compare:obj2];
            }];
            [[Fingerprint sharedFingerprint] setInformation:groups forKey:kMEDIA_ASSETS];
            handler(nil);
        } else {
            [groups addObject:[[group valueForProperty:ALAssetsGroupPropertyName] md5]];
        }
    } failureBlock:^(NSError *error) {
        handler(error);
        return;
    }];
}

@end
