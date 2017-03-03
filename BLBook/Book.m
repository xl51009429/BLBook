//
//  Book.m
//  BLBook
//
//  Created by bigliang on 2017/2/23.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import "Book.h"

@implementation Book

- (instancetype)initWithName:(NSString *)name url:(NSString *)url
{
    if (self = [super init]) {
        self.name = name;
        self.url  = url;
    }
    return self;
}

@end
