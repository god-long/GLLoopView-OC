//
//  VerticalVC.m
//  LoopsView
//
//  Created by 许龙 on 2018/7/12.
//  Copyright © 2018年 许龙. All rights reserved.
//

#import "VerticalVC.h"
#import "QDLoopsView.h"
#import "LoopsCollectionViewCell.h"
#import "QDReuseView.h"
#import "ReuseCollectionViewCell.h"

@interface VerticalVC () <QDLoopsViewDataSource, QDLoopsViewDelegate, QDReuseViewDelegate, QDReuseViewDataSource>

@property (nonatomic, strong) QDLoopsView *loopsView;

@property (nonatomic, strong) QDReuseView *reuseView;

@property (nonatomic, copy  ) NSArray *imageNameArray;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

static NSString *const loopsCellIdentifier = @"LoopsCollectionViewCell";
static NSString *const reuseCellIdentifier = @"ReuseCollectionViewCell";

@implementation VerticalVC

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"竖直轮播图";
    
    self.imageNameArray = @[@"onePiece0", @"onePiece1", @"onePiece2", @"onePiece3", @"onePiece4", @"onePiece5", @"onePiece6",];
    
    [self.dataArray addObjectsFromArray:self.imageNameArray];
    
    
    self.loopsView = [[QDLoopsView alloc] initWithFrame:CGRectMake(0, 160, CGRectGetWidth(self.view.frame), 200)];
    self.loopsView.dataSource = self;
    self.loopsView.delegate = self;
    self.loopsView.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.loopsView.enableAutoScroll = YES;
    [self.loopsView registerNib:[UINib nibWithNibName:NSStringFromClass([LoopsCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:loopsCellIdentifier];
    self.loopsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.loopsView];
    
    NSLayoutConstraint *loopsViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.loopsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:160];
    
    NSLayoutConstraint *loopsViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.loopsView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.f constant:30];
    
    NSLayoutConstraint *loopsViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.loopsView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.f constant:-30];
    
    NSLayoutConstraint *loopsViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.loopsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.f constant:50];
    
    [self.view addConstraints:@[loopsViewTopConstraint, loopsViewLeftConstraint, loopsViewRightConstraint, loopsViewHeightConstraint]];
    
    
    self.reuseView = [[QDReuseView alloc] initWithFrame:CGRectMake(30, 370, CGRectGetWidth(self.view.frame) - 60, 200)];
    self.reuseView.dataSource = self;
    self.reuseView.delegate = self;
    self.reuseView.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.reuseView.enableAutoScroll = YES;
    [self.reuseView registerNib:[UINib nibWithNibName:NSStringFromClass([ReuseCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:reuseCellIdentifier];
    [self.view addSubview:self.reuseView];
    
    
    UIBarButtonItem *randomItem = [[UIBarButtonItem alloc] initWithTitle:@"random" style:UIBarButtonItemStylePlain target:self action:@selector(randomAction)];
    
    self.navigationItem.rightBarButtonItem = randomItem;
}


- (void)randomAction {
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:self.imageNameArray];
    NSInteger random = arc4random() % self.imageNameArray.count + 1;
    [self.dataArray removeObjectsInRange:NSMakeRange(0, random)];
    NSLog(@"数据源 %lu",(unsigned long)self.dataArray.count);
    [self.loopsView reloadData];
    [self.reuseView reloadData];
}

#pragma mark - QDLoopsViewDataSource & QDLoopsViewDelegate
- (NSInteger)numberOfCellsInLoopsView:(QDLoopsView *)loopsView {
    return self.dataArray.count;
}

- (UICollectionViewCell *)loopsView:(QDLoopsView *)loopsView cellForItemAtPage:(NSInteger)page {
    LoopsCollectionViewCell *cell = [loopsView dequeueReusableCellWithReuseIdentifier:loopsCellIdentifier cellForItemAtPage:page];
    cell.imageView.image = [UIImage imageNamed:self.dataArray[page]];
    cell.numberLabel.text = [NSString stringWithFormat:@"%ld",(long)page];
    return cell;
}

- (void)loopsView:(QDLoopsView *)loopsView didSelectItemAtPage:(NSInteger)page {
    NSLog(@"点击循环轮播图 %ld",(long)page);
}

#pragma mark - QDReuseViewDataSource & QDReuseViewDelegate

- (NSInteger)numberOfCellsInReuseView:(QDReuseView *)reuseView {
    return self.dataArray.count;
}

- (UICollectionViewCell *)reuseView:(QDReuseView *)reuseView cellForItemAtPage:(NSInteger)page pageType:(QDReuseViewPageType)pageType {
    ReuseCollectionViewCell *cell = [reuseView dequeueReusableCellWithReuseIdentifier:reuseCellIdentifier pageType:pageType];
    cell.imageView.image = [UIImage imageNamed:[self.dataArray objectAtIndex:page]];
    cell.numberLabel.text = [NSString stringWithFormat:@"%ld",(long)page];
    return cell;
}

- (void)reuseView:(QDReuseView *)reuseView didSelectItemAtPage:(NSInteger)page {
    NSLog(@"点击重用轮播图 %ld",(long)page);
}


@end
