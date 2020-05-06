//
//  ViewController.m
//  CardViewDemo
//
//  Created by zengchao on 2020/5/6.
//  Copyright © 2020 zengchao. All rights reserved.
//

#import "ViewController.h"
#import "ZCCardView.h"
#import "ZCDemoCardCell.h"

@interface ViewController ()<ZCCardViewDelegate>

@property (nonatomic, strong) ZCCardView *cardView;

@property (nonatomic, strong) NSArray    *dataList;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self buildUI];
    [self bindData];
}

- (ZCCardView *)cardView {
    
    if (!_cardView) {
        
        _cardView = [[ZCCardView alloc] initWithFrame:self.view.bounds];
        _cardView.delegate = self;
        _cardView.edgeInsets = UIEdgeInsetsMake(20, 20, 70, 20);
        [self.view addSubview:_cardView];
    }
    return _cardView;
}

- (void)bindData {
    
    self.dataList = @[@"",@"",@"",@"",@"",@"",@"",@"",@""];
    [self.cardView reloadData];
}

- (void)buildUI {
    
    [self cardView];
}

- (NSInteger)numberOfRowsInCardView:(nonnull ZCCardView *)cardView {
    
    return self.dataList.count;
}

- (BOOL)canSwitchCardView:(nonnull ZCCardView *)cardView {
    
    return YES;
}

- (nullable ZCCardCell *)cardView:(nonnull ZCCardView *)cardView cellAtRow:(NSInteger)row {
    
    ZCDemoCardCell *cell = [cardView dequeueReusableCellWithIdentifier:@"cardID"];
    
    if (!cell) {
        
        cell = [[ZCDemoCardCell alloc] initWithReuseIdentifier:@"cardID"];
        cell.backgroundColor = [UIColor grayColor];
    }
    
    return cell;
}

- (void)cardView:(nonnull ZCCardView *)cardView
 scrollDirection:(ZCCardViewScrollDirection)direction
  endSwitchStyle:(ZCCardViewStyle)style {
    
}

- (void)cardView:(nonnull ZCCardView *)cardView scrollWithPercent:(CGFloat)percent {
    
    NSLog(@"%f", percent);
}

- (void)numberOfRowsIsZeroInCardView:(ZCCardView *)cardView {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.cardView reloadData];
    });
    NSLog(@"没东西了");
}



@end
