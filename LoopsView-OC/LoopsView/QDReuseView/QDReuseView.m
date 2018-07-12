//
//  QDReuseView.m
//  Test
//
//  Created by 许龙 on 2018/5/9.
//  Copyright © 2018年 许龙. All rights reserved.
//

#import "QDReuseView.h"
#import "QDLoopsViewPageControl.h"

@interface QDReuseView () <UIScrollViewDelegate, QDReuseViewTimerDeliverDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) QDLoopsViewPageControl *pageControl;/**< 页面指示器 */

@property (nonatomic, copy  ) NSString *reuseIdentifier;/**< 重用标识符 */

@property (nonatomic, strong) NSTimer *timer;/**< 计时器 */

@property (nonatomic, assign) NSInteger numberOfItems;/**< 总共多少个Item */

@property (nonatomic, assign) NSInteger innerCurrentPage;/**< 内部使用的当前页面 */

@property (nonatomic, strong) NSMutableArray *reuseArray;/**< 重用池 */

@property (nonatomic, strong) Class cellClass;

@property (nonatomic, strong) UINib *nibFile;

@property (nonatomic, strong) NSMutableArray *cellArray;/**< 添加到scrollView上的cell数组 */

@property (nonatomic, strong) QDReuseViewTimerDeliver *timerDeliver;

@end

#define kQDReuseView_ScrollTimeInterval 3.0 //默认的自动轮播时间间隔
#define kQDReuseView_PageControlMarginOfLeftRight 15.0 //pageControl距离QDResueView左右边距的距离
#define kQDReuseView_PageControlMarginOfBottom 8.0 //pageControl距离QDResueView底部边距的距离

@implementation QDReuseView

#pragma mark - View Life

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //设置默认属性
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.enableAutoScroll = YES;
        self.timeInterval = kQDReuseView_ScrollTimeInterval;
        self.numberOfItems = 0;
        self.innerCurrentPage = 0;
        self.pageControlLocation = QDReuseViewPageControlLocation_Middle;
        //防止页面第一个View是轮播图，会造成自动下滑
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return self;
}

- (void)dealloc {
    [self.timer invalidate];
}

#pragma mark - Get
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.directionalLockEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bouncesZoom = NO;
        _scrollView.bounces = NO;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (QDLoopsViewPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[QDLoopsViewPageControl alloc] initWithFrame:CGRectMake(30, CGRectGetHeight(self.frame) - 40, CGRectGetWidth(self.frame) - 60, 30)];
        [self addSubview:_pageControl];
    }
    return _pageControl;
}

- (NSString *)identifier {
    return self.reuseIdentifier;
}

- (NSInteger)currentPage {
    return self.innerCurrentPage;
}

- (NSMutableArray *)reuseArray {
    if (!_reuseArray) {
        _reuseArray = [NSMutableArray array];
    }
    return _reuseArray;
}

- (NSMutableArray *)cellArray {
    if (!_cellArray) {
        _cellArray = [NSMutableArray arrayWithCapacity:3];
    }
    return _cellArray;
}

- (NSInteger)numberOfItems {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfCellsInReuseView:)]) {
        return [self.dataSource numberOfCellsInReuseView:self];
    }
    return 0;
}

#pragma mark - Set
- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    _timeInterval = timeInterval;
    if (self.enableAutoScroll) {
        [self.timer invalidate];
        self.timer = nil;
        self.timerDeliver = [[QDReuseViewTimerDeliver alloc] init];
        self.timerDeliver.delegate = self;
        self.timer = [NSTimer timerWithTimeInterval:timeInterval target:self.timerDeliver selector:@selector(timerTransferAction:) userInfo:nil repeats:YES];
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
    CGFloat contentWidth = 0.f;
    CGFloat contentHeight = 0.f;
    CGFloat offsetX = 0.f;
    CGFloat offsetY = 0.f;
    if (_scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        contentWidth = CGRectGetWidth(self.bounds) * 3.0f;
        offsetX = CGRectGetWidth(self.bounds);
    }else {
        contentHeight = CGRectGetHeight(self.bounds) * 3.0f;
        offsetY = CGRectGetHeight(self.bounds);
    }
    [self.scrollView setContentSize:CGSizeMake(contentWidth, contentHeight)];
    [self.scrollView setContentOffset:CGPointMake(offsetX, offsetY) animated:NO];
    [self configPageControl];
}

- (void)setDataSource:(id<QDReuseViewDataSource>)dataSource {
    _dataSource = dataSource;
    if (self.nibFile || self.cellClass) {
        [self configSubViews];
    }
}

- (void)setInnerCurrentPage:(NSInteger)innerCurrentPage {
    _innerCurrentPage = innerCurrentPage;
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        self.pageControl.currentPage = innerCurrentPage;
    }
}

- (void)setPageControlLocation:(QDReuseViewPageControlLocation)pageControlLocation {
    _pageControlLocation = pageControlLocation;
    [self configPageControl];
}

#pragma mark - Private Methods
- (NSInteger)getIndexWithPageType:(QDReuseViewPageType)pageType {
    NSInteger index = 0;
    switch (pageType) {
        case QDReuseViewPageType_LastPage:
            index = 0;
            break;
        case QDReuseViewPageType_CurrentPage:
            index = 1;
            break;
        case QDReuseViewPageType_NextPage:
            index = 2;
            break;
        default:
            break;
    }
    return index;
}

#pragma mark 时间触发方法
- (void)timerAction {
    CGFloat offsetX, offsetY;
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        offsetX = CGRectGetWidth(self.bounds) * 2;
        offsetY = 0.f;
    }else {
        offsetX = 0.f;
        offsetY = CGRectGetHeight(self.bounds) * 2;
    }
    [self.scrollView setContentOffset:CGPointMake(offsetX, offsetY) animated:YES];
}

#pragma mark 根据page获取上一张pageIndex
- (NSInteger)getLastPageWith:(NSInteger)currentPage {
    NSInteger lastPage = currentPage - 1;
    return lastPage == -1 ? (self.numberOfItems - 1) : lastPage;
}

#pragma mark 根据page获取下一张pageIndex
- (NSInteger)getNextPageWith:(NSInteger)currentPage {
    NSInteger nextPage = currentPage + 1;
    return nextPage < self.numberOfItems ? nextPage : 0;
}

#pragma mark 忘ScrollView上添加Cell
- (void)addCellWithPage:(NSInteger)page pageType:(QDReuseViewPageType)pageType {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(reuseView:cellForItemAtPage:pageType:)]) {
        UICollectionViewCell *cell = [self.dataSource reuseView:self cellForItemAtPage:page pageType:pageType];
        NSInteger index = [self getIndexWithPageType:pageType];
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            cell.frame = CGRectMake(index * CGRectGetWidth(self.bounds), 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        }else {
            cell.frame = CGRectMake(0, index * CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        }
        if (!cell.superview) {
            [self.scrollView addSubview:cell];
        }
    }
}

#pragma mark 配置子View
- (void)configSubViews {
    //防止当前innerCurrentPage越界
    if (self.innerCurrentPage >= self.numberOfItems) {
        self.innerCurrentPage = 0;
        CGFloat offsetX = 0.f;
        CGFloat offsetY = 0.f;
        if (_scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            offsetX = CGRectGetWidth(self.bounds);
        }else {
            offsetY = CGRectGetHeight(self.bounds);
        }
        [self.scrollView setContentOffset:CGPointMake(offsetX, offsetY) animated:NO];
    }
    
    if (self.numberOfItems <= 0) {
        for (UIView *subView in self.cellArray) {
            [subView removeFromSuperview];
        }
    }else {
        [self addCellWithPage:[self getLastPageWith:self.currentPage] pageType:QDReuseViewPageType_LastPage];
        [self addCellWithPage:self.currentPage pageType:QDReuseViewPageType_CurrentPage];
        [self addCellWithPage:[self getNextPageWith:self.currentPage] pageType:QDReuseViewPageType_NextPage];
    }
    [self configPageControl];
}

#pragma mark 配置PageControl
- (void)configPageControl {
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        self.pageControl.numberOfPages = self.numberOfItems;
        CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:self.numberOfItems];
        CGFloat pageControlX = [self getPageControlXWithPageControlWidth:pageControlSize.width];
        self.pageControl.frame = CGRectMake(pageControlX, CGRectGetHeight(self.frame) - pageControlSize.height - kQDReuseView_PageControlMarginOfLeftRight, pageControlSize.width, pageControlSize.height);
        self.pageControl.numberOfPages = self.numberOfItems;
        self.pageControl.currentPage = self.currentPage;
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
        case QDReuseViewPageControlLocation_Left:
            pageControlX = kQDReuseView_PageControlMarginOfLeftRight;
            break;
        case QDReuseViewPageControlLocation_Middle:
            pageControlX = (CGRectGetWidth(self.frame) - pageControlWidth) / 2;
            break;
        case QDReuseViewPageControlLocation_Right:
            pageControlX = CGRectGetWidth(self.frame) - pageControlWidth - kQDReuseView_PageControlMarginOfLeftRight;
            break;
        default:
            break;
    }
    return pageControlX;
}

#pragma mark - Overwrite
- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    CGFloat offsetX = 0.f;
    CGFloat offsetY = 0.f;
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        offsetX = CGRectGetWidth(self.bounds);
    }else {
        offsetY = CGRectGetHeight(self.bounds);
    }
    [self.scrollView setContentOffset:CGPointMake(offsetX, offsetY) animated:NO];
    
    [self reloadData];
}

#pragma mark - Public Methods
- (void)reloadData {
    [self configSubViews];
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    self.reuseIdentifier = identifier;
    self.cellClass = cellClass;
    if (self.dataSource) {
        [self configSubViews];
    }
}

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    self.reuseIdentifier = identifier;
    self.nibFile = nib;
    if (self.dataSource) {
        [self configSubViews];
    }
}

- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier pageType:(QDReuseViewPageType)pageType {
    if (self.numberOfItems <= 0) {
        return nil;
    }
    
    NSInteger index = [self getIndexWithPageType:pageType];
    
    if (self.cellArray.count >= 3 && self.cellArray.count > index) {
        UICollectionViewCell *cell = [self.cellArray objectAtIndex:index];
        if ([cell.reuseIdentifier isEqualToString:identifier]) {
            return cell;
        }
        [self.cellArray removeObjectAtIndex:index];
        [self.reuseArray addObject:cell];
    }

    if (self.reuseArray.count > 0) {
        for (UICollectionViewCell *cell in self.reuseArray) {
            if ([cell.reuseIdentifier isEqualToString:identifier]) {
                [self.reuseArray removeObject:cell];
                if (self.cellArray.count > index) {
                    [self.cellArray insertObject:cell atIndex:index];
                }else {
                    [self.cellArray addObject:cell];
                }
                return cell;
            }
        }
    }

    if (self.nibFile) {
        UICollectionViewCell *cell = [[self.nibFile instantiateWithOwner:self options:nil] firstObject];
        [self.cellArray addObject:cell];
        return cell;
    }
    
    return nil;
}

#pragma mark QDReuseViewTimerDeliverDelegate
- (void)timerActionDeliver:(id)sender {
    [self timerAction];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //竖直轮播不显示页面指示器
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return;
    }

    CGFloat offsetX = scrollView.contentOffset.x;
    //获取toPage
    NSInteger toPage;
    NSInteger index = floor(offsetX / CGRectGetWidth(self.frame));
    //获取进度
    CGFloat progress;
    if (offsetX < CGRectGetWidth(self.frame)) {
        toPage = self.innerCurrentPage - 1;
        toPage = toPage < 0 ? (self.numberOfItems - 1) : toPage;
        progress = 1 - ((offsetX - CGRectGetWidth(self.frame) * index) / CGRectGetWidth(self.frame));
    }else {
        toPage = self.innerCurrentPage + 1;
        toPage = toPage > (self.numberOfItems - 1) ? 0 : toPage;
        progress = (offsetX - CGRectGetWidth(self.frame)) / CGRectGetWidth(self.frame);
    }
        
    [self.pageControl updatePageControlWithCurrentPage:self.innerCurrentPage toPage:toPage progress:progress];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat offsetX;
        offsetX = scrollView.contentOffset.x;
        if (offsetX == 0) {
            self.innerCurrentPage = [self getLastPageWith:self.innerCurrentPage];
        }else if (offsetX == CGRectGetWidth(self.bounds) * 2) {
            self.innerCurrentPage = [self getNextPageWith:self.innerCurrentPage];
        }
        [self configSubViews];
        [scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.frame), 0) animated:NO];
    }else {
        CGFloat offsetY;
        offsetY = scrollView.contentOffset.y;
        if (offsetY == 0) {
            self.innerCurrentPage = [self getLastPageWith:self.innerCurrentPage];
        }else if (offsetY == CGRectGetHeight(self.bounds) * 2) {
            self.innerCurrentPage = [self getNextPageWith:self.innerCurrentPage];
        }
        [self configSubViews];
        [scrollView setContentOffset:CGPointMake(0, CGRectGetHeight(self.frame)) animated:NO];
    }
}

//时间触发器 设置滑动时动画true，会触发的方法
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //用户拖动时，计时器停掉
    if (self.enableAutoScroll) {
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


#pragma mark - QDReuseViewTimerDeliver
@implementation QDReuseViewTimerDeliver

- (void)timerTransferAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(timerActionDeliver:)]) {
        [self.delegate timerActionDeliver:sender];
    }
}

@end

