//
//  Copyright (c) 2015 Tobias Becker <tobias_becker@me.com>, Andreas Kurtz <mail@andreas-kurtz.de>, Hugo Gascon <hgascon@cs.uni-goettingen.de>. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView {
    UIActivityIndicatorView *_spinner;
    UILabel *_textLabel;
}

- (void)hide
{
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        [_spinner stopAnimating];
        [self removeFromSuperview];
    }];
}

- (void)updateText:(NSString *)text
{
    _textLabel.text = text;
}

- (id)initWithText:(NSString *)text
{
    self = [self initWithFrame:CGRectMake(96, 225 - 64, 129, 106)];
    if (self) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 65, 100, 21)];
        _textLabel.text = text;
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textLabel];
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.frame = CGRectMake(46, 20, 37, 37);
        [self addSubview:_spinner];
        [_spinner startAnimating];
        self.backgroundColor = [UIColor darkGrayColor];
        self.alpha = 0.9f;
        self.layer.cornerRadius = 10.0f;
        self.layer.masksToBounds = YES;
    }
    return self;
}

@end
