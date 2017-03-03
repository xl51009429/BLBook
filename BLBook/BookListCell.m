//
//  BookListCell.m
//  BLBook
//
//  Created by bigliang on 2017/2/24.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import "BookListCell.h"

@implementation BookListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)deleteButtonClick:(UIButton *)sender {
    if (_clickBlock) {
        _clickBlock();
    }
}

@end
