//
//  ZCCardCell.h
//  CardAnimation
//
//  Created by zengchao on 2019/11/20.
//  Copyright © 2019 zengchao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCCardCell : UIView

@property (nonatomic, copy, readonly) NSString *reuseIdentifier;

@property (nonatomic, assign) NSInteger row;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)prepareForReuse;


@end

NS_ASSUME_NONNULL_END
