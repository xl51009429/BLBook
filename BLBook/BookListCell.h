//
//  BookListCell.h
//  BLBook
//
//  Created by bigliang on 2017/2/24.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DeleteButtonClick)();

@interface BookListCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (nonatomic, copy) DeleteButtonClick clickBlock;


@end
