//
//  FileUtil.m
//  BLBook
//
//  Created by bigliang on 2017/2/21.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import "FileUtil.h"
#import <SSZipArchive.h>

@interface FileUtil ()

@end

@implementation FileUtil

+ (NSString *)createDirectoryForDownloadItemByName:(NSString *)name
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *downlaodDir =  [[document stringByAppendingPathComponent:@"books"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/",name]];
    if (![manager fileExistsAtPath:downlaodDir]) {
        [manager createDirectoryAtPath:downlaodDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return downlaodDir;
}

+ (BOOL)moveTempFileFromPath:(NSString *)location toPath:(NSString *)destination
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:destination]) {
        [manager removeItemAtPath:destination error:nil];
    }
    BOOL isSuccess = [manager moveItemAtPath:location toPath:destination error:nil];
    return isSuccess;
}

+ (BOOL)unzipFileAtPath:(NSString *)location toPath:(NSString *)destination
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:destination]) {
        [manager removeItemAtPath:destination error:nil];
    }
    BOOL isSuccess = [SSZipArchive unzipFileAtPath:location toDestination:destination];
    return isSuccess;
}

+ (BOOL)removeItemAtPath:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    BOOL isSuccess = [manager removeItemAtPath:path error:&error];
    if (error) {
        NSLog(@"remove item error:%@",error);
    }
    return isSuccess;
}

@end
