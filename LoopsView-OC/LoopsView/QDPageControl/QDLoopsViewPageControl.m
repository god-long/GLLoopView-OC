//
//  QDLoopsViewPageControl.m
//  Test
//
//  Created by 许龙 on 2018/7/6.
//  Copyright © 2018年 许龙. All rights reserved.
//

#import "QDLoopsViewPageControl.h"

@interface QDLoopsViewPageControl ()

@property (nonatomic, strong) NSMutableArray *pageDotViewArray;/**< 点View数组 */

@end

#define kQDLoopsViewPageControl_SelectWidth 20 //选中点的宽度
#define kQDLoopsViewPageControl_NormalWAndH 8 //正常点的宽度和高度
#define kQDLoopsViewPageControl_Margin 10 //距离边缘的距离
#define kQDLoopsViewPageControl_DotsSpace 5 //点之间的距离
#define kQDLoopsViewPageControl_DefaultHeight 20 //pageControl的默认高度

@implementation QDLoopsViewPageControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //初始化 默认属性
        self.numberOfPages = 0;
        self.currentPage = 0;
        self.hidesForSinglePage = YES;
        self.selectColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];
        self.normalColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Set
- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    if (self.hidesForSinglePage && self.numberOfPages <= 1) {
        self.hidden = YES;
        return;
    }
    
    self.hidden = NO;
    if (self.pageDotViewArray.count != numberOfPages) {
        [self setupViews];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;

    [UIView animateWithDuration:0.0f animations:^{
        CGFloat dotViewX = kQDLoopsViewPageControl_Margin;
        for (NSInteger i = 0; i < self.pageDotViewArray.count; i++) {
            UIView *dotView = [self.pageDotViewArray objectAtIndex:i];
            if (i == self.currentPage) {
                dotView.backgroundColor = self.selectColor;
                dotView.frame = CGRectMake(dotViewX, kQDLoopsViewPageControl_Margin, kQDLoopsViewPageControl_SelectWidth, kQDLoopsViewPageControl_NormalWAndH);
                dotViewX = dotViewX + kQDLoopsViewPageControl_DotsSpace + kQDLoopsViewPageControl_SelectWidth;
            }else {
                dotView.backgroundColor = self.normalColor;
                dotView.frame = CGRectMake(dotViewX, kQDLoopsViewPageControl_Margin, kQDLoopsViewPageControl_NormalWAndH, kQDLoopsViewPageControl_NormalWAndH);
                dotViewX = dotViewX + kQDLoopsViewPageControl_DotsSpace + kQDLoopsViewPageControl_NormalWAndH;
            }
        }
    }];
}

- (void)setNormalColor:(UIColor *)normalColor {
    _normalColor = normalColor;
    
    for (NSInteger i = 0; i < self.pageDotViewArray.count; i++) {
        UIView *dotView = [self.pageDotViewArray objectAtIndex:i];
        if (i == self.currentPage) {
            dotView.backgroundColor = self.selectColor;
        }
        dotView.backgroundColor = self.normalColor;
    }
}

- (void)setSelectColor:(UIColor *)selectColor {
    _selectColor = selectColor;
    if (self.pageDotViewArray.count > self.currentPage) {
        UIView *dotView = [self.pageDotViewArray objectAtIndex:self.currentPage];
        dotView.backgroundColor = self.selectColor;
    }
}

#pragma mark - Get

- (NSMutableArray *)pageDotViewArray {
    if (!_pageDotViewArray) {
        _pageDotViewArray = [NSMutableArray array];
    }
    return _pageDotViewArray;
}

#pragma mark - Private Methods
// 只在设置numberOfPages的时候调用
- (void)setupViews {
    
    for (UIView *dotView in self.pageDotViewArray) {
        [dotView removeFromSuperview];
    }
    [self.pageDotViewArray removeAllObjects];
    
    for (NSInteger i = 0; i < self.numberOfPages; i++) {
        UIView *pageDotView = [[UIView alloc] initWithFrame:CGRectMake(kQDLoopsViewPageControl_Margin + i * (kQDLoopsViewPageControl_NormalWAndH + kQDLoopsViewPageControl_DotsSpace), kQDLoopsViewPageControl_Margin, kQDLoopsViewPageControl_NormalWAndH, kQDLoopsViewPageControl_NormalWAndH)];
        pageDotView.layer.cornerRadius = kQDLoopsViewPageControl_NormalWAndH / 2.0;
        pageDotView.layer.masksToBounds = YES;
        pageDotView.clipsToBounds = YES;
        pageDotView.backgroundColor = self.normalColor;
        [self addSubview:pageDotView];
        [self.pageDotViewArray addObject:pageDotView];
    }
}

#pragma mark - Public Methods
- (void)updatePageControlWithCurrentPage:(NSInteger)currentPage toPage:(NSInteger)toPage progress:(CGFloat)progress {
    
    CGFloat progressWidth = (kQDLoopsViewPageControl_SelectWidth - kQDLoopsViewPageControl_NormalWAndH) * progress;
    
    UIColor *currentColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1 - progress * 0.7];
    UIColor *toColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3 + progress * 0.7];
    
    CGFloat dotViewX = kQDLoopsViewPageControl_Margin;
    for (NSInteger i = 0; i < self.pageDotViewArray.count; i++) {
        UIView *dotView = [self.pageDotViewArray objectAtIndex:i];
        if (i == currentPage) {
            dotView.backgroundColor = currentColor;
            dotView.frame = CGRectMake(dotViewX, kQDLoopsViewPageControl_Margin, kQDLoopsViewPageControl_SelectWidth - progressWidth, kQDLoopsViewPageControl_NormalWAndH);
            dotViewX = dotViewX + kQDLoopsViewPageControl_DotsSpace + kQDLoopsViewPageControl_SelectWidth - progressWidth;
        }else if (i == toPage) {
            dotView.backgroundColor = toColor;
            dotView.frame = CGRectMake(dotViewX, kQDLoopsViewPageControl_Margin, kQDLoopsViewPageControl_NormalWAndH + progressWidth, kQDLoopsViewPageControl_NormalWAndH);
            dotViewX = dotViewX + kQDLoopsViewPageControl_DotsSpace + kQDLoopsViewPageControl_NormalWAndH + progressWidth;
        }else {
            dotView.backgroundColor = self.normalColor;
            dotView.frame = CGRectMake(dotViewX, kQDLoopsViewPageControl_Margin, kQDLoopsViewPageControl_NormalWAndH, kQDLoopsViewPageControl_NormalWAndH);
            dotViewX = dotViewX + kQDLoopsViewPageControl_DotsSpace + kQDLoopsViewPageControl_NormalWAndH;
        }
    }
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount {
    if (pageCount <= 0) {
        return CGSizeZero;
    }
    CGFloat width = kQDLoopsViewPageControl_Margin + (pageCount - 1) * (kQDLoopsViewPageControl_NormalWAndH + kQDLoopsViewPageControl_DotsSpace) + kQDLoopsViewPageControl_SelectWidth + kQDLoopsViewPageControl_Margin;
    return CGSizeMake(width, kQDLoopsViewPageControl_DefaultHeight);
}

@end
