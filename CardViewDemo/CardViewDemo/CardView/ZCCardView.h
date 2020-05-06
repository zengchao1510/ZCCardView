//
//  ZCCardView.h
//  CardAnimation
//
//  Created by zengchao on 2019/11/20.
//  Copyright © 2019 zengchao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCCardCell.h"

NS_ASSUME_NONNULL_BEGIN

@class ZCCardView;

typedef enum : NSUInteger {
    
    ZCCardViewStyleStart,
    ZCCardViewStyleEnd,
    ZCCardViewStyleCancel,
    // 被动关闭，当canSwitchCardView返回NO时
    ZCCardViewStyleCancelByPassive

} ZCCardViewStyle;

typedef enum : NSUInteger {
    ZCCardViewScrollDirectionNone,
    ZCCardViewScrollDirectionLeft,
    ZCCardViewScrollDirectionRight,

} ZCCardViewScrollDirection;

@protocol ZCCardViewDelegate <NSObject>

@required
- (NSInteger)numberOfRowsInCardView:(ZCCardView *)cardView;

- (nullable ZCCardCell *)cardView:(ZCCardView *)cardView
                        cellAtRow:(NSInteger)row;

@optional

- (void)numberOfRowsIsZeroInCardView:(ZCCardView *)cardView;

- (BOOL)canSwitchCardView:(ZCCardView *)cardView;

- (void)cardView:(ZCCardView *)cardView
 scrollDirection:(ZCCardViewScrollDirection)direction
  endSwitchStyle:(ZCCardViewStyle)style;

- (void)cardView:(ZCCardView *)cardView
scrollWithPercent:(CGFloat)percent;

- (CGSize)sizeInCardView:(ZCCardView *)cardView;

@end

@interface ZCCardView : UIView

@property (nonatomic, weak) id <ZCCardViewDelegate> delegate;

@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, assign, readonly) NSInteger currentRow;

- (nullable __kindof ZCCardCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
