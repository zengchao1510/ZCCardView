//
//  ZCCardCell.m
//  CardAnimation
//
//  Created by zengchao on 2019/11/20.
//  Copyright © 2019 zengchao. All rights reserved.
//

#import "ZCCardCell.h"

@interface ZCCardCell ()

@property (nonatomic, copy) NSString *reuseIdentifier;

@end

@implementation ZCCardCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super init];
    if (self) {
        
        self.reuseIdentifier = reuseIdentifier;
    }
    return self;
}

- (void)prepareForReuse {
    
    
}


@end
