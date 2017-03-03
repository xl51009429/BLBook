//
//  BLDBHelper.m
//  SogaBook
//
//  Created by 解梁 on 16/9/27.
//  Copyright © 2016年 5i5j. All rights reserved.
//

#import "BLDBHelper.h"

@interface BLDBHelper ()

@end

@implementation BLDBHelper

static BLDBHelper *shareInstance = nil;

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[super alloc]init];
    });
    return shareInstance;
}

- (NSString *)dbPath
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbDirPath = [docPath stringByAppendingPathComponent:@"BLDB"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL isExist = [fileManager fileExistsAtPath:dbDirPath isDirectory:&isDir];
    //BLDB不是文件夹或者不存在，则创建BLDB文件夹
    if (!isDir || !isExist) {
        [fileManager createDirectoryAtPath:dbDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [dbDirPath stringByAppendingPathComponent:@"bldb.db"];
}

#pragma mark - getter

- (FMDatabaseQueue *)dbQueue
{
    if (!_dbQueue) {
        _dbQueue = [[FMDatabaseQueue alloc]initWithPath:[self dbPath]];
    }
    return _dbQueue;
}


@end
