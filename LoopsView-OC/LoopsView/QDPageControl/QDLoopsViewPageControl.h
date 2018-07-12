//
//  QDLoopsViewPageControl.h
//  Test
//
//  Created by 许龙 on 2018/7/6.
//  Copyright © 2018年 许龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QDLoopsViewPageControl : UIView

@property (nonatomic, assign) NSInteger numberOfPages; /**< 总数量 */

@property (nonatomic, assign) NSInteger currentPage; /**< 当前页面 */

@property (nonatomic, assign) BOOL hidesForSinglePage;/**< 当只有一个页面时，是否隐藏 默认：YES */

@property (nonatomic, strong) UIColor *selectColor;/**< 选中的颜色 默认：white 不透明 */

@property (nonatomic, strong) UIColor *normalColor;/**< 正常的颜色 默认：white %30透明 */


/**
 更新pageControl

 @param currentPage 当前页面下标
 @param toPage 要到的页面下标
 @param progress 进度【0 ~ 1】
 */
- (void)updatePageControlWithCurrentPage:(NSInteger)currentPage
                                  toPage:(NSInteger)toPage
                                progress:(CGFloat)progress;


/**
 返回显示pageCount点最小的size

 @param pageCount 要显示的页面数量
 @return 最小的CGSize
 */
- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;

@end


