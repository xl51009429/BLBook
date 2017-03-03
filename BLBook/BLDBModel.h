//
//  BLDataBase.h
//  SogaBook
//
//  Created by 解梁 on 16/9/27.
//  Copyright © 2016年 5i5j. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLDBModel : NSObject

@property (nonatomic, assign)int             blID;          //主键
@property (nonatomic, strong)NSMutableArray *nameArray;     //属性名数组
@property (nonatomic, strong)NSMutableArray *typeArray;     //属性类型数组

/**
 对象插入数据库

 @return isSuccess
 */
- (BOOL)insertObject;

/**
 多个对象插入数据库

 @param objects 待插入对象数组

 @return isSuccess
 */
+ (BOOL)insertObjects:(NSArray *)objects;

/**
 查找某个表的全部数据
 
 @return model数组
 */
+ (NSArray *)selectAll;

/**
 根据列名，值查询某个表的数据

 @param key   列名
 @param value 值

 @return model数组
 */
+ (NSArray *)selectTableWhereKey:(NSString *)key equalTo:(id)value;

/**
 根据条件查询某个表的数据

 @param requirement sql条件语句

 @return model数组
 */
+ (NSArray *)selectTableWithRequirement:(NSString *)requirement;

/**
 清空表
 */
+ (BOOL)clearTable;

/**
 删除对象

 @return isSuccess
 */
- (BOOL)deleteObject;


/**
 删除多个对象

 @param objects 对象数组

 @return isSuccess
 */
+ (BOOL)deleteObjects:(NSArray *)objects;


/**
 更新对象

 @return isSuccess
 */
- (BOOL)updateObject;


/**
 更新多个对象

 @param objects 对象数组

 @return isSuccess
 */
+ (BOOL)updateObjects:(NSArray *)objects;

@end
