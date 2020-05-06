//
//  ZCDemoCardCell.m
//  LiaoBa-Man
//
//  Created by zengchao on 2020/4/21.
//  Copyright © 2020 zengchao. All rights reserved.
//

#import "ZCDemoCardCell.h"

@interface ZCDemoCardCell ()

@property (nonatomic, strong) UIView *contentView;

@end

@implementation ZCDemoCardCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self contentView];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];

    self.contentView.frame = self.bounds;
}

- (UIView *)contentView {
    
    if (!_contentView) {
        
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor orangeColor];
        [self addSubview: _contentView];
    }
    return _contentView;
}


@end
