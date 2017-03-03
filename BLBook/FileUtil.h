//
//  FileUtil.h
//  BLBook
//
//  Created by bigliang on 2017/2/21.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtil : NSObject


/**
 创建下载目录

 @return destination
 */
+ (NSString *)createDirectoryForDownloadItemByName:(NSString *)name;


/**
 把下载的临时文件移动到目标目录

 @param location location
 @param destination destination
 @return isSuccess
 */
+ (BOOL)moveTempFileFromPath:(NSString *)location toPath:(NSString *)destination;


/**
 解压文件到指定目录

 @param location location
 @param destination destination
 @return isSuccess
 */
+ (BOOL)unzipFileAtPath:(NSString *)location toPath:(NSString *)destination;


/**
 删除文件

 @param path path
 @return isSuccess
 */
+ (BOOL)removeItemAtPath:(NSString *)path;

@end
