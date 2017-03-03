//
//  PageViewCell.m
//  BLBook
//
//  Created by bigliang on 2017/2/24.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import "PageViewCell.h"

@implementation PageViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(kPadding);
        make.right.mas_equalTo(-kPadding);
    }];
    
    self.textLabel.textColor = [UIColor darkGrayColor];
}

@end
