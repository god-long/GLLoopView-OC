# GLLoopView-OC
loopView Object-C, support custom Views, vertical and horizontal.

### 描述：

使用OC写的无限循环轮播图，可自定义时间间隔，**自定义显示View**。自带pageControl，可设置位置。

本仓库中，使用了2种方式各写了一个轮播图控件，一个是利用UICollectionView实现的，一个是利用UIScrollView实现的。看大家喜好使用。

### 功能：

* 支持横向、竖向
* 轮播图点击代理
* 自定义View内容


### 运行展示图：

![](https://github.com/god-long/GLLoopView-OC/raw/master/loopsView-OC.gif)


### 使用：

直接拖代码

#### QDLoopsView:

```
    self.loopsView = [[QDLoopsView alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.frame), 200)];
    self.loopsView.dataSource = self;
    self.loopsView.delegate = self;
    self.loopsView.enableAutoScroll = YES;
    self.loopsView.translatesAutoresizingMaskIntoConstraints = NO;
    self.loopsView.pageControlLocation = QDLoopsViewPageControlLocation_Middle;
    [self.loopsView registerNib:[UINib nibWithNibName:NSStringFromClass([LoopsCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:loopsCellIdentifier];
    [self.view addSubview:self.loopsView];
    
    NSLayoutConstraint *loopsViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.loopsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:110];
    
    NSLayoutConstraint *loopsViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.loopsView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.f constant:0];
    
    NSLayoutConstraint *loopsViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.loopsView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.f constant:0];
    
    NSLayoutConstraint *loopsViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.loopsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.f constant:200];
    
    [self.view addConstraints:@[loopsViewTopConstraint, loopsViewLeftConstraint, loopsViewRightConstraint, loopsViewHeightConstraint]];

```

```
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

```

#### QDReuseView:

```
 self.reuseView = [[QDReuseView alloc] initWithFrame:CGRectMake(0, 330, [UIScreen mainScreen].bounds.size.width, 200)];
    self.reuseView.dataSource = self;
    self.reuseView.delegate = self;
    self.reuseView.enableAutoScroll = YES;
    self.reuseView.pageControlLocation = QDLoopsViewPageControlLocation_Middle;
    [self.reuseView registerNib:[UINib nibWithNibName:NSStringFromClass([ReuseCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:reuseCellIdentifier];
    [self.view addSubview:self.reuseView];
    
```

```
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

```


#### 如有意见，欢迎issue

