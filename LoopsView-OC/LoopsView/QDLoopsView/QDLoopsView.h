//
//  QDLoopsView.h
//  Test
//
//  Created by 许龙 on 2018/5/8.
//  Copyright © 2018年 许龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QDLoopsView;


typedef NS_ENUM(NSInteger, QDLoopsViewPageControlLocation) {
    QDLoopsViewPageControlLocation_Left = 0, /**< 左边 */
    QDLoopsViewPageControlLocation_Middle, /**< 中间 默认 */
    QDLoopsViewPageControlLocation_Right, /**< 右边 */
};


#pragma mark - QDLoopsViewDataSource
@protocol QDLoopsViewDataSource <NSObject>

@required
/**
 获取轮播图的数量

 @param loopsView QDLoopsView
 @return 轮播图要显示的总数量
 */
- (NSInteger)numberOfCellsInLoopsView:(QDLoopsView *)loopsView;

/**
 轮播图获取复用Cell，便于使用者赋值，必须是已经注册了cellClass或者cellNib之后，
 然后用loopsView调用 `-(__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier cellForItemAtPage:(NSInteger)page` 方法获取Cell，之后可对cell做赋值操作

 @param loopsView QDLoopsView
 @param page 第几页（数据源的第几个）
 @return UICollectionViewCell
 */
- (__kindof UICollectionViewCell *)loopsView:(QDLoopsView *)loopsView cellForItemAtPage:(NSInteger)page;

@end


#pragma mark - QDLoopsViewDelegate
@protocol QDLoopsViewDelegate <NSObject>

/**
 点击QDLoopsView上cell的代理方法

 @param loopsView QDLoopsView
 @param page 数据源中的第几个
 */
- (void)loopsView:(QDLoopsView *)loopsView didSelectItemAtPage:(NSInteger)page;

@end


#pragma mark - QDLoopsView
@interface QDLoopsView : UIView

@property (nonatomic, weak  ) id<QDLoopsViewDataSource> dataSource;

@property (nonatomic, weak  ) id<QDLoopsViewDelegate> delegate;

@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;/**< 设置滑动方向 默认：UICollectionViewScrollDirectionHorizontal */

@property (nonatomic, assign) BOOL enableAutoScroll;/**<  是否自动滑动 默认：YES */

@property (nonatomic, assign) NSTimeInterval timeInterval;/**< 滑动时间间隔 默认：3s */

@property (nonatomic, assign) NSInteger currentPage;/**< 当前显示第几个页面 */

@property (nonatomic, assign) QDLoopsViewPageControlLocation pageControlLocation;/**< pageControl的显示位置 */


/**
 重新加载数据
 */
- (void)reloadData;

/**
 注册要显示的cellClass，并指定要重用的identifier

 @param cellClass  你的cell Class
 @param identifier 你的cell重用标识
 */
- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(nonnull NSString *)identifier;

/**
 注册要显示的nib文件，并指定要重用的identifier

 @param nib 你的cell创建的nib
 @param identifier 你的cell重用标识
 */
- (void)registerNib:(nullable UINib *)nib forCellWithReuseIdentifier:(nonnull NSString *)identifier;

/**
 获取cell或者重用cell的方法，在DataSource方法`- (__kindof UICollectionViewCell *)loopsView:(QDLoopsView *)loopsView cellForItemAtPage:(NSInteger)page`中使用

 @param identifier 重用标志
 @param page 第几个页面
 @return UICollectionViewCell 你之前注册的cell
 */
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier cellForItemAtPage:(NSInteger)page;


@end


#pragma mark - QDLoopsViewTimerDeliver
@protocol QDLoopsViewTimerDeliverDelegate <NSObject>

- (void)timerActionDeliver:(id)sender;

@end

/**
 为了防止NSTimer造成的循环引用问题而建
 */
@interface QDLoopsViewTimerDeliver: NSObject

@property (nonatomic, weak  ) id <QDLoopsViewTimerDeliverDelegate> delegate;

- (void)timerTransferAction:(id)sender;

@end
