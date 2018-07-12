//
//  LoopsCollectionViewCell.m
//  Test
//
//  Created by 许龙 on 2018/5/8.
//  Copyright © 2018年 许龙. All rights reserved.
//

#import "LoopsCollectionViewCell.h"

@implementation LoopsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (IBAction)knowMore:(UIButton *)sender {
    NSLog(@"了解更多");
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

@end
