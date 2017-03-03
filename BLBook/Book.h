//
//  Book.h
//  BLBook
//
//  Created by bigliang on 2017/2/23.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import "BLDBModel.h"

@interface Book : BLDBModel

@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *url;

- (instancetype)initWithName:(NSString *)name url:(NSString *)url;

@end
