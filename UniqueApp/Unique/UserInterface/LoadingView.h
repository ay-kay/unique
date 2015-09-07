//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

- (id)initWithText:(NSString *)text;
- (void)hide;
- (void)updateText:(NSString*)text;

@end
