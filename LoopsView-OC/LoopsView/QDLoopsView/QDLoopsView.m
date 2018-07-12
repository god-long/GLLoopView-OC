//
//  QDLoopsView.m
//  Test
//
//  Created by 许龙 on 2018/5/8.
//  Copyright © 2018年 许龙. All rights reserved.
//

#import "QDLoopsView.h"
#import "QDLoopsViewPageControl.h"

@interface QDLoopsView () <UICollectionViewDelegate, UICollectionViewDataSource, QDLoopsViewTimerDeliverDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;/**< 布局 */

@property (nonatomic, strong) QDLoopsViewPageControl *pageControl;/**< 页面指示器 */

@property (nonatomic, copy  ) NSString *reuseIdentifier;/**< 重用标识符 */

@property (nonatomic, strong) NSTimer *timer;/**< 计时器 */

@property (nonatomic, assign, readonly) NSInteger numberOfItems;/**< 总共多少个Item */

@property (nonatomic, strong) QDLoopsViewTimerDeliver *timerDeliver;/**< 防timer循环引用self，引入的第三个类 */

@end

#define kQDLoopsView_ScrollTimeInterval 3.0 //默认的自动轮播时间间隔
#define kQDLoopsView_PageControlMarginOfLeftRight 15.0 //pageControl距离QDLoopsView左右边距的距离
#define kQDLoopsView_PageControlMarginOfBottom 8.0 //pageControl距离QDLoopsView底部边距的距离




@implementation QDLoopsView

#pragma mark - View Life
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //设置默认属性
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.enableAutoScroll = YES;
        self.timeInterval = kQDLoopsView_ScrollTimeInterval;
        self.pageControlLocation = QDLoopsViewPageControlLocation_Middle;
        [self setupViews];
    }
    return self;
}

- (void)dealloc {
    [self.timer invalidate];
}

#pragma mark - Get
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.directionalLockEnabled = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.bounces = NO;
        _collectionView.bouncesZoom = NO;
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.itemSize = CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        _flowLayout.minimumLineSpacing = 0.0f;
        _flowLayout.minimumInteritemSpacing = 0.0f;
        _flowLayout.scrollDirection = self.scrollDirection;
    }
    return _flowLayout;
}

- (QDLoopsViewPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[QDLoopsViewPageControl alloc] initWithFrame:CGRectMake(kQDLoopsView_PageControlMarginOfLeftRight, CGRectGetHeight(self.frame) - kQDLoopsView_PageControlMarginOfBottom, CGRectGetWidth(self.frame) - kQDLoopsView_PageControlMarginOfLeftRight * 2, 30)];
        _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_pageControl];
    }
    return _pageControl;
}

- (NSInteger)currentPage {
    CGFloat offsetX = self.collectionView.contentOffset.x;
    NSInteger index = floor(offsetX / CGRectGetWidth(self.frame));
    NSInteger currentPage = index - 1;
    if (index < 1) {
        currentPage = self.numberOfItems - 1;
    }else if (index > self.numberOfItems) {
        currentPage = 0;
    }else {
        currentPage = index - 1;
    }
    return currentPage;
}

- (NSInteger)numberOfItems {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfCellsInLoopsView:)]) {
        return [self.dataSource numberOfCellsInLoopsView:self];
    }
    return 0;
}

#pragma mark - Set
- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    _timeInterval = timeInterval;
    if (self.enableAutoScroll) {
        [self.timer invalidate];
        self.timer = nil;
        _timerDeliver = [[QDLoopsViewTimerDeliver alloc] init];
        _timerDeliver.delegate = self;
        self.timer = [NSTimer timerWithTimeInterval:timeInterval target:_timerDeliver selector:@selector(timerTransferAction:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)setEnableAutoScroll:(BOOL)enableAutoScroll {
    _enableAutoScroll = enableAutoScroll;
    if (!self.timer.isValid) {
        return;
    }
    if (enableAutoScroll) {
        self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:self.timeInterval];
    }else {
        self.timer.fireDate = [NSDate distantFuture];
    }
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    _scrollDirection = scrollDirection;
    self.flowLayout.scrollDirection = scrollDirection;
    [self.collectionView setCollectionViewLayout:self.flowLayout animated:NO];
    CGFloat offsetX = 0.f;
    CGFloat offsetY = 0.f;
    if (_scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        offsetX = CGRectGetWidth(self.bounds);
    }else {
        offsetY = CGRectGetHeight(self.bounds);
    }
    [self.collectionView setContentOffset:CGPointMake(offsetX, offsetY) animated:NO];
    
    if (self.numberOfItems > 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
    [self configPageControl];
}

- (void)setPageControlLocation:(QDLoopsViewPageControlLocation)pageControlLocation {
    _pageControlLocation = pageControlLocation;
    [self configPageControl];
}

#pragma mark - Private Methods
#pragma mark 添加collectionView
- (void)setupViews {
    self.collectionView.collectionViewLayout = self.flowLayout;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"QDLoopsViewCollectionViewCell"];
    [self addSubview:self.collectionView];
    
    NSLayoutConstraint *loopsViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.f constant:0];
    
    NSLayoutConstraint *loopsViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.f constant:0];
    
    NSLayoutConstraint *loopsViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.f constant:0];

    NSLayoutConstraint *loopsViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.f constant:0];
    
    
    [self addConstraints:@[loopsViewTopConstraint, loopsViewLeftConstraint, loopsViewBottomConstraint, loopsViewRightConstraint]];
}

#pragma mark 设置pageControl
- (void)configPageControl {
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:self.numberOfItems];
        CGFloat pageControlX = [self getPageControlXWithPageControlWidth:pageControlSize.width];
        self.pageControl.frame = CGRectMake(pageControlX, CGRectGetHeight(self.frame) - pageControlSize.height - kQDLoopsView_PageControlMarginOfBottom, pageControlSize.width, pageControlSize.height);
        self.pageControl.numberOfPages = self.numberOfItems;
        self.pageControl.currentPage = self.currentPage;
        self.pageControl.hidesForSinglePage = YES;
        [self bringSubviewToFront:self.pageControl];
    }else {
        [self.pageControl removeFromSuperview];
        self.pageControl = nil;
    }
}

//获取pageControl的x值
- (CGFloat)getPageControlXWithPageControlWidth:(CGFloat)pageControlWidth {
    CGFloat pageControlX = 0;
    switch (self.pageControlLocation) {
        case QDLoopsViewPageControlLocation_Left:
            pageControlX = kQDLoopsView_PageControlMarginOfLeftRight;
            break;
        case QDLoopsViewPageControlLocation_Middle:
            pageControlX = (CGRectGetWidth(self.frame) - pageControlWidth) / 2;
            break;
        case QDLoopsViewPageControlLocation_Right:
            pageControlX = CGRectGetWidth(self.frame) - pageControlWidth - kQDLoopsView_PageControlMarginOfLeftRight;
            break;
        default:
            break;
    }
    return pageControlX;
}

#pragma mark 重设Views
- (void)resetViews {
    if (self.numberOfItems > 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
     [self.collectionView reloadData];
    
    [self configPageControl];
}

#pragma mark 时间触发的方法
- (void)timerAction {
    CGFloat offsetX, offsetY;
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        offsetX = self.collectionView.contentOffset.x +  CGRectGetWidth(self.bounds);
        offsetY = 0.f;
    }else {
        offsetX = 0.f;
        offsetY = self.collectionView.contentOffset.y + CGRectGetHeight(self.bounds);
    }
    [self.collectionView setContentOffset:CGPointMake(offsetX, offsetY) animated:YES];
}

#pragma mark 显示第一页
- (void)showFirstPage {
    if (self.numberOfItems > 0) {
        UICollectionViewScrollPosition position = UICollectionViewScrollPositionLeft;
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            position = UICollectionViewScrollPositionTop;
        }
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:position animated:NO];
    }
}

#pragma mark - Overwrite
- (void)layoutSubviews {
    [super layoutSubviews];
    self.flowLayout = nil;
    [self.collectionView setCollectionViewLayout:self.flowLayout animated:NO];
    [self.collectionView reloadData];
    [self showFirstPage];
    [self configPageControl];
}

#pragma mark - Public Methods
- (void)reloadData {
    [self.collectionView reloadData];
    if (self.numberOfItems > 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
    [self configPageControl];
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    self.reuseIdentifier = identifier;
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    self.reuseIdentifier = identifier;
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier cellForItemAtPage:(NSInteger)page {
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:page inSection:0]];
    return cell;
}

#pragma mark - Delegate
#pragma mark QDLoopsViewTimerDeliverDelegate
- (void)timerActionDeliver:(id)sender {
    [self timerAction];
}

#pragma mark UICollectionViewDataSource && UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger number = 1;
    number = self.numberOfItems <= 0 ? 0 : (self.numberOfItems + 2);
    return number;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(loopsView:cellForItemAtPage:)]) {
        NSInteger page = indexPath.item;
        if (page == 0) {
            page = self.numberOfItems - 1;
        }else if (page == self.numberOfItems + 1) {
            page = 0;
        }else {
            page = page - 1;
        }
        
        return [self.dataSource loopsView:self cellForItemAtPage:page];
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QDLoopsViewCollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(loopsView:didSelectItemAtPage:)]) {
        NSInteger page = indexPath.item;
        if (page == 0) {
            page = self.numberOfItems - 1;
        }else if (page == self.numberOfItems + 1) {
            page = 0;
        }else {
            page = page - 1;
        }
        [self.delegate loopsView:self didSelectItemAtPage:page];
    }
    [self.collectionView reloadData];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //竖直轮播不显示页面指示器
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return;
    }

    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger index = floor(offsetX / CGRectGetWidth(self.frame));
    //获取currentPage;
    NSInteger currentPage = self.currentPage;
    //获取toPage 因为currentPage计算出来始终是展示出来的左边的页面，所以toPage都是右边的页面
    NSInteger toPage = currentPage + 1;
    //右边如果超过最大页，就是第一页
    toPage = toPage > (self.numberOfItems - 1) ? 0 : toPage;
    //获取进度
    CGFloat progress;
    progress = (offsetX - CGRectGetWidth(self.frame) * index) / CGRectGetWidth(self.frame);

    [self.pageControl updatePageControlWithCurrentPage:currentPage toPage:toPage progress:progress];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat modifyX = 0.f;
        CGFloat offsetX = scrollView.contentOffset.x;
        if (offsetX >= (self.numberOfItems + 2 - 1) * CGRectGetWidth(self.frame)) {
            modifyX = CGRectGetWidth(self.frame);
            [scrollView setContentOffset:CGPointMake(modifyX, 0) animated:NO];
        }else if (offsetX <= 0) {
            modifyX = (self.numberOfItems + 2 - 2) * CGRectGetWidth(self.frame);
            [scrollView setContentOffset:CGPointMake(modifyX, 0) animated:NO];
        }
    }else {
        CGFloat modifyY = 0.f;
        CGFloat offsetY = scrollView.contentOffset.y;
        if (offsetY >= (self.numberOfItems + 2 - 1) * CGRectGetHeight(self.frame)) {
            modifyY = CGRectGetHeight(self.frame);
            [scrollView setContentOffset:CGPointMake(0, modifyY) animated:NO];
        }else if (offsetY <= 0) {
            modifyY = (self.numberOfItems + 2 - 2) * CGRectGetHeight(self.frame);
            [scrollView setContentOffset:CGPointMake(0, modifyY) animated:NO];
        }
    }
}

//时间触发器 设置滑动时动画true，会触发的方法
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //用户拖动时，计时器停掉
    if (self.enableAutoScroll && self.timer.isValid) {
        self.timer.fireDate = [NSDate distantFuture];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    //如果用户手动拖动到一个整数页，就不会触发减速的方法了，所以手动触发减速方法
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
    
    //用户拖动结束，打开计时器
    if (self.enableAutoScroll && self.timer.isValid) {
        self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:self.timeInterval];
    }
}


@end

@implementation QDLoopsViewTimerDeliver

- (void)timerTransferAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(timerActionDeliver:)]) {
        [self.delegate timerActionDeliver:sender];
    }
}

@end

