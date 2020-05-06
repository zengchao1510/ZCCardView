//
//  UIView+ZCView.m
//  CardAnimation
//
//  Created by zengchao on 2019/3/22.
//  Copyright © 2019 zengchao. All rights reserved.
//

#import "UIView+ZCView.h"

@implementation UIView (ZCView)

- (void)setAnchorPoint:(CGPoint)anchorPoint {
    
    CGPoint oldOrigin = self.frame.origin;
    self.layer.anchorPoint = anchorPoint;
    CGPoint newOrigin = self.frame.origin;
    
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    self.center = CGPointMake (self.center.x - transition.x, self.center.y - transition.y);
}


@end
