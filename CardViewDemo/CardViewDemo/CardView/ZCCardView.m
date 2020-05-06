//
//  ZCCardView.m
//  CardAnimation
//
//  Created by zengchao on 2019/11/20.
//  Copyright © 2019 zengchao. All rights reserved.
//

#import "ZCCardView.h"
#import "ZCCardCell.h"
#import "UIView+ZCView.h"

@interface ZCCardView() {
    
    NSMutableDictionary *_cachedCells;
    NSMutableSet *_reusableCells;
    
    BOOL _isEndScrolling;
    BOOL _isEndAnimation;
    
    struct {
        unsigned numberOfRowsInCardView : 1;
        unsigned sizeForRowInCardView : 1;
        unsigned endSwitchStyle: 1;
        unsigned numberOfRowsIsZero: 1;
        unsigned scrollWithPercent: 1;
    } _delegateHas;
}

@property (nonatomic, assign) NSInteger startRow;
@property (nonatomic, assign) NSInteger endRow;
@property (nonatomic, assign) NSInteger currentRow;
@property (nonatomic, assign) NSInteger maxVisibleRows;
@property (nonatomic, strong) UIPanGestureRecognizer *panGes;

@end

@implementation ZCCardView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.maxVisibleRows = 4;
        _reusableCells = [NSMutableSet set];
        _cachedCells = [NSMutableDictionary dictionary];
        [self panGes];
        [self reloadData];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.maxVisibleRows = 4;
        _reusableCells = [NSMutableSet set];
        _cachedCells = [NSMutableDictionary dictionary];
        [self panGes];
        [self reloadData];
    }
    return self;
}

- (void)reloadData {
    
    [[_cachedCells allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_reusableCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_reusableCells removeAllObjects];
    [_cachedCells removeAllObjects];
    
    self.startRow = 0;
    self.endRow = self.maxVisibleRows;
    
    [self _layoutCardView];
}

- (void)_layoutCardView {
    
    // 从缓存列表中读取，可用列表中的数据只包含不在屏幕中显示的cell
    NSMutableDictionary *availableCells = [_cachedCells mutableCopy];
    
    const NSInteger numberOfRows = [self numberOfRows];
    if (self.endRow >= numberOfRows) {
        
        self.endRow = numberOfRows;
    } else {
        
        self.endRow = self.startRow + self.maxVisibleRows;
    }
    
    if (self.startRow >= self.endRow) {
        
        self.startRow = self.endRow;
    }
    
    // 缓存列表中只缓存当前显示在屏幕上的cell
    [_cachedCells removeAllObjects];
    
    for (NSInteger row = self.startRow; row < self.endRow; row++) {
    
        ZCCardCell *cell = [availableCells objectForKey:@(row)] ?: [self.delegate cardView:self cellAtRow:row];
        
        if (cell) {
            
            // 重新设置缓存
            [_cachedCells setObject:cell forKey:@(row)];
            // 将添加在屏幕上的cell从可用列表中移除
            [availableCells removeObjectForKey:@(row)];
            
            cell.row = row;
            cell.backgroundColor = self.backgroundColor;
            
            if (self.backgroundView) {
                
                [self insertSubview:cell aboveSubview: self.backgroundView];
            } else {
                
                [self insertSubview:cell atIndex:0];
            }
            
            cell.transform = CGAffineTransformIdentity;
            if (_delegateHas.sizeForRowInCardView) {
                
                CGSize size = [self.delegate sizeInCardView:self];
                cell.frame = CGRectMake(0, 0, size.width, size.height);
                
            } else {
                
                cell.frame = CGRectMake(self.edgeInsets.left, self.edgeInsets.top, self.frame.size.width - self.edgeInsets.left - self.edgeInsets.right, self.frame.size.height - self.edgeInsets.top - self.edgeInsets.bottom);
            }
            
            if (row == self.startRow) {
                
                cell.transform = CGAffineTransformMakeScale(1, 1);
            } else {
                
                cell.transform = CGAffineTransformMakeScale(0.9, 0.9);
            }
        }
    }
    
    // 添加可复用cell
    for (ZCCardCell *cell in [availableCells allValues]) {
        
        if (cell.reuseIdentifier) {
            
            [_reusableCells addObject:cell];
        } else {
            
            [cell removeFromSuperview];
        }
    }
    
    // 将不在视图上显示的可复用的cell从视图上移除, 并且不添加正在显示的cell到复用池中
    for (ZCCardCell *cell in _reusableCells) {
        
        [cell removeFromSuperview];
    }
}

- (NSInteger)numberOfRows {
    
    if (_delegateHas.numberOfRowsInCardView) {
        
        return [self.delegate numberOfRowsInCardView:self];
    } else {
        
        return 0;
    }
}

- (nullable __kindof ZCCardCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    
    for (ZCCardCell *cell in _reusableCells) {
        
        if ([cell.reuseIdentifier isEqualToString:identifier]) {

            ZCCardCell *strongCell = cell;
            // 添加到视图上的cell将从复用池中移除
            [_reusableCells removeObject:cell];
            
            [strongCell prepareForReuse];
            
            return strongCell;
        }
    }
    return nil;
}

#pragma mark - setter

- (void)setDelegate:(id<ZCCardViewDelegate>)delegate {
    
    _delegate = delegate;
    
    _delegateHas.sizeForRowInCardView = [self.delegate respondsToSelector:@selector(sizeInCardView:)];
    _delegateHas.numberOfRowsInCardView = [self.delegate respondsToSelector:@selector(numberOfRowsInCardView:)];
    _delegateHas.numberOfRowsIsZero = [self.delegate respondsToSelector:@selector(numberOfRowsIsZeroInCardView:)];
    _delegateHas.endSwitchStyle = [self.delegate respondsToSelector:@selector(cardView:scrollDirection:endSwitchStyle:)];
    _delegateHas.scrollWithPercent = [self.delegate respondsToSelector:@selector(cardView:scrollWithPercent:)];
}

- (void)setStartRow:(NSInteger)startRow {
    
    _startRow = startRow;
    
    self.currentRow = startRow;
}

- (void)setBackgroundView:(UIView *)backgroundView {
    
    _backgroundView = backgroundView;
    [self insertSubview:backgroundView atIndex:0];
}

#pragma mark - getter

- (UIPanGestureRecognizer *)panGes {
    
    if (!_panGes) {
        
        _panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
        [self addGestureRecognizer:_panGes];
    }
    return _panGes;
}

#pragma mark - action

- (void)panHandle:(UIPanGestureRecognizer *)ges {
    
    if (_isEndScrolling && !_isEndAnimation) {
        
        return;
    }
    
    if (_cachedCells.count == 0) {
        
        return;
    }
    
    CGPoint point     = [ges translationInView:ges.view];
    CGFloat viewWidth = ges.view.frame.size.width;
    CGFloat progress  = point.x / viewWidth;
    UIGestureRecognizerState state = ges.state;
    
    if (_delegateHas.scrollWithPercent) {
        
        [self.delegate cardView:self scrollWithPercent:progress];
    }
    
    ZCCardCell *cell = [_cachedCells objectForKey:@(self.startRow)];
    [cell setAnchorPoint: CGPointMake(0.5, 1)];
    
    ZCCardCell *lastCell = [_cachedCells objectForKey:@(self.startRow + 1)];
    if (lastCell) {
        
        lastCell.transform = CGAffineTransformMakeScale(0.9 + 0.1 * fabs(progress), 0.9 + 0.1 * fabs(progress));
    }
    
    static CGPoint startCenter;
    
    switch (state) {
            
        case UIGestureRecognizerStateBegan: {
            
            _isEndScrolling = NO;
            startCenter = cell.center;
            if (self->_delegateHas.endSwitchStyle) {
                
                ZCCardViewScrollDirection direction = ZCCardViewScrollDirectionNone;
                if (progress > 0) {
                    
                    direction = ZCCardViewScrollDirectionRight;
                } else if (progress < 0) {
                    
                    direction = ZCCardViewScrollDirectionLeft;
                }
                [self.delegate cardView:self scrollDirection:direction endSwitchStyle:ZCCardViewStyleStart];
            }
            
        } break;
            
        case UIGestureRecognizerStateChanged: {
            
            CGAffineTransform transform = CGAffineTransformMakeRotation(progress * M_PI / 4);
            CGAffineTransformScale(transform, 1, 1);
            cell.transform = transform;
            cell.center = CGPointMake(startCenter.x + point.x / 2.0, startCenter.y);
        
        } break;
            
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled: {
            
            self->_isEndScrolling = YES;
            self->_isEndAnimation = NO;
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                CGAffineTransform transform = CGAffineTransformMakeRotation(0);
                CGAffineTransformScale(transform, 1, 1);
                cell.transform = transform;
                cell.center = startCenter;
                
                CGAffineTransform transformScale = CGAffineTransformMakeScale(0.9, 0.9);
                lastCell.transform = transformScale;
                
            } completion:^(BOOL finished) {
               
                CGAffineTransform transform = CGAffineTransformMakeRotation(0);
                CGAffineTransformScale(transform, 1, 1);
                cell.transform = transform;
                [cell setAnchorPoint:CGPointMake(0.5, 0.5)];
                
                [self _layoutCardView];
                
                self->_isEndAnimation = YES;
            }];
            
            if (self->_delegateHas.endSwitchStyle) {
                
                ZCCardViewScrollDirection direction = ZCCardViewScrollDirectionNone;
                if (progress > 0) {
                    
                    direction = ZCCardViewScrollDirectionRight;
                } else if (progress < 0) {
                    
                    direction = ZCCardViewScrollDirectionLeft;
                }
                [self.delegate cardView:self scrollDirection: direction endSwitchStyle: ZCCardViewStyleCancel];
            }
            
        } break;
            
        case UIGestureRecognizerStateEnded: {
            
            self->_isEndScrolling = YES;
            self->_isEndAnimation = NO;
            
            if ([self.delegate respondsToSelector:@selector(canSwitchCardView:)]) {
                
                if (![self.delegate canSwitchCardView:self]) {
                    
                    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:1.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        
                        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
                        CGAffineTransformScale(transform, 1, 1);
                        cell.transform = transform;
                        cell.center = startCenter;
                        
                        CGAffineTransform transformScale = CGAffineTransformMakeScale(0.9, 0.9);
                        lastCell.transform = transformScale;
                        
                    } completion:^(BOOL finished) {
                        
                        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
                        CGAffineTransformScale(transform, 1, 1);
                        cell.transform = transform;
                        [cell setAnchorPoint:CGPointMake(0.5, 0.5)];
                        [self _layoutCardView];
                        self->_isEndAnimation = YES;
                    }];
                    
                    if (self->_delegateHas.endSwitchStyle) {
                        
                        ZCCardViewScrollDirection direction = ZCCardViewScrollDirectionNone;
                        if (progress > 0) {
                            
                            direction = ZCCardViewScrollDirectionRight;
                        } else if (progress < 0) {
                            
                            direction = ZCCardViewScrollDirectionLeft;
                        }
                        [self.delegate cardView:self scrollDirection:direction endSwitchStyle:ZCCardViewStyleCancel];
                    }
                    return;
                }
            }
            
            if (fabs(progress) >= .5) {
                
                CGFloat width = progress > 0 ? cell.bounds.size.height : -cell.bounds.size.height;
                CGFloat angle = progress > 0 ? M_PI / 4 : -M_PI / 4;
                
                [UIView animateWithDuration:0.25 animations:^{
                   
                    CGAffineTransform transformScale = CGAffineTransformMakeScale(1, 1);
                    lastCell.transform = transformScale;
                }];
                
                [UIView animateWithDuration:0.5 animations:^{
                    
                    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
                    CGAffineTransformScale(transform, 1, 1);
                    cell.transform = transform;
                    cell.center = CGPointMake(startCenter.x + width, startCenter.y);
                    
                } completion:^(BOOL finished) {
                    
                    CGAffineTransform transform = CGAffineTransformMakeRotation(0);
                    CGAffineTransformScale(transform, 1, 1);
                    cell.transform = transform;
                    [cell setAnchorPoint:CGPointMake(0.5, 0.5)];
                    
                    self.startRow += 1;
                    self.endRow += 1;

                    [self _layoutCardView];
                    
                    self->_isEndAnimation = YES;
                    
                    if (self.startRow == self.endRow && self->_delegateHas.numberOfRowsIsZero) {
                        
                        [self.delegate numberOfRowsIsZeroInCardView: self];
                    }
                }];
                
                if (self->_delegateHas.endSwitchStyle) {
                    
                    ZCCardViewScrollDirection direction = ZCCardViewScrollDirectionNone;
                    if (progress > 0) {
                        
                        direction = ZCCardViewScrollDirectionRight;
                    } else if (progress < 0) {
                        
                        direction = ZCCardViewScrollDirectionLeft;
                    }
                    [self.delegate cardView:self scrollDirection: direction endSwitchStyle:ZCCardViewStyleEnd];
                }
                
            } else {
                
                [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:1.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    
                    CGAffineTransform transform = CGAffineTransformMakeRotation(0);
                    CGAffineTransformScale(transform, 1, 1);
                    cell.transform = transform;
                    cell.center = startCenter;
                    
                    CGAffineTransform transformScale = CGAffineTransformMakeScale(0.9, 0.9);
                    lastCell.transform = transformScale;
                    
                } completion:^(BOOL finished) {
                    
                    CGAffineTransform transform = CGAffineTransformMakeRotation(0);
                    CGAffineTransformScale(transform, 1, 1);
                    cell.transform = transform;
                    [cell setAnchorPoint:CGPointMake(0.5, 0.5)];
                    [self _layoutCardView];
                    
                    self->_isEndAnimation = YES;
                }];
                
                if (self->_delegateHas.endSwitchStyle) {
                    
                    ZCCardViewScrollDirection direction = ZCCardViewScrollDirectionNone;
                    if (progress > 0) {
                        
                        direction = ZCCardViewScrollDirectionRight;
                    } else if (progress < 0) {
                        
                        direction = ZCCardViewScrollDirectionLeft;
                    }
                    [self.delegate cardView:self scrollDirection: direction endSwitchStyle:ZCCardViewStyleCancel];
                }
            }
            
        } break;
            
        default:
            break;
    }
}


@end
