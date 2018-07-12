//
//  ReuseCollectionViewCell.m
//  Test
//
//  Created by 许龙 on 2018/5/10.
//  Copyright © 2018年 许龙. All rights reserved.
//

#import "ReuseCollectionViewCell.h"

@implementation ReuseCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)clickcheck:(UIButton *)sender {
    NSLog(@"查看");
}

- (void)prepareForReuse {
    [super prepareForReuse];
    NSLog(@"ReuseCell准备被重用 %@",self.numberLabel.text);
}

@end
