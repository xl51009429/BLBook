//
//  Chapter.h
//  BLBook
//
//  Created by bigliang on 2017/2/22.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLDBModel.h"

@interface Chapter : BLDBModel

@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)NSString *content;
@property (nonatomic, strong)NSNumber *bookID;

- (instancetype)initWithTitle:(NSString *)title content:(NSString *)content bookID:(NSNumber *)bookID;

@end
