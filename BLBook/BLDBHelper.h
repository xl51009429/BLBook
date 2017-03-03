//
//  BLDBHelper.h
//  SogaBook
//
//  Created by 解梁 on 16/9/27.
//  Copyright © 2016年 5i5j. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

@interface BLDBHelper : NSObject

@property (nonatomic, strong)FMDatabaseQueue *dbQueue;

/**
 得到BLDBHelper单例
 */
+ (instancetype)shareInstance;

@end
