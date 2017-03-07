//
//  BLBookParser.h
//  BLBook
//
//  Created by bigliang on 2017/2/22.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBLLineHeight 2

@interface BLBookParser : NSObject



/**
 解析图书，解析完成是否删除

 @param path path
 */
+ (void)parserBookAtPath:(nonnull NSString *)path deleteWhenSuccess:(BOOL)flag bookId:(int)bookId;


/**
 文字分页

 @param attStr 富文本
 @return 页数组
 */
+ (nonnull NSArray *)breakUpToPageFromContent:(nonnull NSAttributedString *)attStr;

+ (void)setLineNums;

@end
