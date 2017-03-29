//
//  BLBookParser.m
//  BLBook
//
//  Created by bigliang on 2017/2/22.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import "BLBookParser.h"
#import "Chapter.h"
#import "FileUtil.h"
#import <CoreText/CoreText.h>

static NSInteger lineNumsOfPage = 0;

@implementation BLBookParser

+ (void)parserBookAtPath:(nonnull NSString *)path deleteWhenSuccess:(BOOL)flag bookId:(int)bookId;
{
    NSString *content = [self getBookContentOfPath:path];
    
    if (content) {
        [self parserChapterOfContent:content bookId:bookId];
    }else{
        BLLogError(@"read file content failed");
    }
    if (flag) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [FileUtil removeItemAtPath:path];
        });
    }
}

//获取图书文件内容的字符串
+ (NSString *)getBookContentOfPath:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        return nil;
    }
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!content) {
        content = [NSString stringWithContentsOfFile:path encoding:0x80000632 error:nil];
    }
    if (!content) {
        content = [NSString stringWithContentsOfFile:path encoding:0x80000631 error:nil];
    }
    return content;
}

+ (void)parserChapterOfContent:(NSString *)content bookId:(int)bookId
{
    NSString *partten = @"正?文? *第[0-9一二三四五六七八九十百千]*[章回] .*";
    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:partten options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        BLLogError(@"regularExpression error:%@",error);
    }
    NSArray *results = [expression matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length)];
    __block NSRange lastRange = NSMakeRange(0, 0);
    BLLogInfo(@"chapter num = %lu",(unsigned long)results.count);
    [results enumerateObjectsUsingBlock:^(NSTextCheckingResult *  _Nonnull textCheckingResult, NSUInteger index, BOOL * _Nonnull stop) {
        Chapter *chaper;
        if (index == 0) {
            NSString *chapterContent = [content substringToIndex:[textCheckingResult range].location];
            chaper = [[Chapter alloc]initWithTitle:@"开始" content:chapterContent bookID:@(bookId)];
            
        }else{
            NSString *chapterContent = [content substringWithRange:NSMakeRange(lastRange.location+lastRange.length, [textCheckingResult range].location - lastRange.location - lastRange.length)];
            NSString *title = [content substringWithRange:lastRange];
            chaper = [[Chapter alloc]initWithTitle:title content:chapterContent bookID:@(bookId)];
        }
        if (chaper.content.length >= 10) {
            [chaper insertObject];
        }
        
        if (index == results.count - 1) {
            NSString *lastTitle = [content substringWithRange:[textCheckingResult range]];
            NSString *lastChapterContent = [content substringFromIndex:[textCheckingResult range].location+[textCheckingResult range].length + 1];
            Chapter *lastChapter = [[Chapter alloc]initWithTitle:lastTitle content:lastChapterContent bookID:@(bookId)];
            [lastChapter insertObject];
        }
        lastRange = [textCheckingResult range];
    }];
}

+ (nonnull NSArray *)breakUpToPageFromContent:(nonnull NSAttributedString *)attStr
{
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,kScreenWidth - kPadding * 2,100000));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSArray *returnArray = [self operateLines:lines attStr:attStr];
    //core text对象需要手动释放
    CFRelease(frameSetter);
    CFRelease(path);
    CFRelease(frame);
    return returnArray;
}

+ (NSArray *)operateLines:(NSArray *)lines attStr:(NSAttributedString *)attStr
{
    __block NSRange lastRange = NSMakeRange(0, 0);
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    [lines enumerateObjectsUsingBlock:^(id  _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > 1 && (idx + 1) % [self lineNums] == 0) {
            CTLineRef lineRef = (__bridge CTLineRef )line;
            CFRange lineRange = CTLineGetStringRange(lineRef);
            NSRange range = NSMakeRange(lastRange.location + lastRange.length, lineRange.location + lineRange.length - lastRange.location - lastRange.length);
            NSAttributedString *lineString = [attStr attributedSubstringFromRange:range];
            [returnArray addObject:lineString];
            lastRange = range;
            //CFRelease(lineRef);
        }
    }];
    
    //最后一页文字拼接
    if (lastRange.location + lastRange.length < attStr.length) {
        NSRange range = NSMakeRange(lastRange.location + lastRange.length,attStr.length - lastRange.location - lastRange.length);
        NSAttributedString *lineString = [attStr attributedSubstringFromRange:range];
        [returnArray addObject:lineString];
    }
    
    return returnArray;
}

+ (NSInteger)lineNums
{
    return lineNumsOfPage;
}

+ (void)setLineNums
{
    UILabel *label = [[UILabel alloc]init];
    label.text = @"我";
    NSInteger fontSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"FontSize"];
    if (fontSize == 0) {
        label.font = [UIFont systemFontOfSize:kFontSizeNormal];
    }else{
        label.font = [UIFont systemFontOfSize:fontSize];
    }
    lineNumsOfPage = (kScreenHeight - kPadding * 2) / (kBLLineHeight + label.intrinsicContentSize.height);
    //NSLog(@"%ld",lineNumsOfPage);
}

@end
