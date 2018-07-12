//
//  QDReuseView.h
//  Test
//
//  Created by 许龙 on 2018/5/9.
//  Copyright © 2018年 许龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QDReuseView;


typedef NS_ENUM(NSInteger, QDReuseViewPageControlLocation) {
    QDReuseViewPageControlLocation_Left = 0, /**< 左边 */
    QDReuseViewPageControlLocation_Middle, /**< 中间 默认 */
    QDReuseViewPageControlLocation_Right, /**< 右边 */
};


typedef NS_ENUM(NSInteger, QDReuseViewPageType) {
    QDReuseViewPageType_LastPage,
    QDReuseViewPageType_CurrentPage,
    QDReuseViewPageType_NextPage
};

#pragma mark - QDReuseViewDataSource
@protocol QDReuseViewDataSource <NSObject>

@required
/**
 总共有多少个轮播Cell

 @param reuseView QDReuseView 轮播图
 @return 轮播Cell的数量
 */
- (NSInteger)numberOfCellsInReuseView:(QDReuseView *)reuseView;

/**
 获取轮播Cell

 @param reuseView QDReuseView 轮播图
 @param page 第几个轮播Cell
 @param pageType QDReuseViewPageType 因为每次只展示3个Cell【上一个、当前、下一个】
 @return 要展示的Cell
 */
- (__kindof UICollectionViewCell *)reuseView:(QDReuseView *)reuseView cellForItemAtPage:(NSInteger)page pageType:(QDReuseViewPageType)pageType;

@end


#pragma mark - QDReuseViewDelegate
@protocol QDReuseViewDelegate <NSObject>

/**
 点击轮播Cell

 @param reuseView QDReuseView 轮播图
 @param page 点击的页面下标
 */
- (void)reuseView:(QDReuseView *)reuseView didSelectItemAtPage:(NSInteger)page;

@end


#pragma mark - QDReuseView
/**
 循环轮播图：
 实现原理：在UIScrollView上添加3个子View，通过滑动后，改变UIScrollView的contentOffset来实现无限滚动的效果
 使用：首先注册Cell,`- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(nonnull NSString *)identifier` 或者 `- (void)registerNib:(nullable UINib *)nib forCellWithReuseIdentifier:(nonnull NSString *)identifier`方法。
 还要实现QDReuseViewDataSource的方法，在 `- (__kindof UICollectionViewCell *)reuseView:(QDReuseView *)reuseView cellForItemAtPage:(NSInteger)page pageType:(QDReuseViewPageType)pageType` 方法中调用 `- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier pageType:(QDReuseViewPageType)pageType` 方法，获取注册的Cell。
 */
@interface QDReuseView : UIView

@property (nonatomic, weak  ) id<QDReuseViewDataSource> dataSource;

@property (nonatomic, weak  ) id<QDReuseViewDelegate> delegate;

@property (nonatomic, copy,   readonly) NSString *identifier;/**< 重用标识符 */

@property (nonatomic, assign, readonly) NSInteger currentPage;/**< 当前显示的第几页 */

@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;/**< 设置滑动方向 默认：UICollectionViewScrollDirectionHorizontal */

@property (nonatomic, assign) BOOL enableAutoScroll;/**<  是否自动滑动 默认：YES */

@property (nonatomic, assign) NSTimeInterval timeInterval;/**< 滑动时间间隔 默认：3s */

@property (nonatomic, assign) QDReuseViewPageControlLocation pageControlLocation;/**< pageControl显示位置 */


- (void)reloadData;

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(nonnull NSString *)identifier;

- (void)registerNib:(nullable UINib *)nib forCellWithReuseIdentifier:(nonnull NSString *)identifier;

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier pageType:(QDReuseViewPageType)pageType;

@end



#pragma mark - QDReuseViewTimerDeliver

//下面是为了防止NSTimer和轮播图循环引用，导致无法释放，声明的中间Timer传送者

@protocol QDReuseViewTimerDeliverDelegate <NSObject>

- (void)timerActionDeliver:(id)sender;

@end


@interface QDReuseViewTimerDeliver: NSObject

@property (nonatomic, weak  ) id <QDReuseViewTimerDeliverDelegate> delegate;

- (void)timerTransferAction:(id)sender;

@end

