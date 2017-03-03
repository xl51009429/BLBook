//
//  NSString+Util.m
//  BLBook
//
//  Created by bigliang on 2017/2/23.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import "NSString+Util.h"

@implementation NSString (Util)

- (BOOL)bl_isURL
{
    if ([self hasPrefix:@"http://"] || [self hasPrefix:@"https://"]) {
        return YES;
    }else{
        return NO;
    }
}

- (NSString *)deleteWhiteSpace
{
    NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *str = [self stringByTrimmingCharactersInSet:whiteSpace];
    return str;
}

@end
