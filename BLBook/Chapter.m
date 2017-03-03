//
//  Chapter.m
//  BLBook
//
//  Created by bigliang on 2017/2/22.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import "Chapter.h"

@implementation Chapter

- (instancetype)initWithTitle:(NSString *)title content:(NSString *)content bookID:(NSNumber *)bookID
{
    if (self = [super init]) {
        self.title = title;
        self.content = content;
        self.bookID = bookID;
    }
    return self;
}

@end
