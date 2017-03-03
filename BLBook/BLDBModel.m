//
//  BLDataBase.m
//  SogaBook
//
//  Created by 解梁 on 16/9/27.
//  Copyright © 2016年 5i5j. All rights reserved.
//

#import "BLDBModel.h"
#import "BLDBHelper.h"
#import <objc/runtime.h>

@interface BLDBModel ()

@end

@implementation BLDBModel

static NSString *PrimaryKeyName = @"blID";

+ (void)initialize
{
    if (self != [BLDBModel self]) {
        //initialize 仅在类调用第一个方法之前执行一次.
        [self createTable];
    }
}

- (instancetype)init
{
    if (self = [super init]) {
        NSDictionary *dic = [self.class getPropertyNameAndType];
        self.nameArray = dic[@"names"];
        self.typeArray = dic[@"types"];
    }
    return self;
}

- (BOOL)insertObject
{
    BLDBHelper *blDB = [BLDBHelper shareInstance];
    NSDictionary *dic = [self getNameAndValueString];
    NSString *sql = [NSString stringWithFormat:@"insert into %@(%@) values(%@)",NSStringFromClass(self.class),dic[@"nameStr"],dic[@"valueStr"]];
    __block BOOL isSuccess = YES;
    [blDB.dbQueue inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdate:sql withArgumentsInArray:dic[@"valueArray"]];
        self.blID = isSuccess?[NSNumber numberWithLongLong:db.lastInsertRowId].intValue:0;
    }];
    return isSuccess;
}

+ (BOOL)insertObjects:(NSArray *)objects
{
    BLDBHelper *blDB = [BLDBHelper shareInstance];
    __block BOOL isSuccess = YES;
    [blDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (BLDBModel *model in objects) {
            NSDictionary *dic = [model getNameAndValueString];
            NSString *sql = [NSString stringWithFormat:@"insert into %@(%@) values(%@)",NSStringFromClass(self.class),dic[@"nameStr"],dic[@"valueStr"]];
            isSuccess = [db executeUpdate:sql withArgumentsInArray:dic[@"valueArray"]];
            if (isSuccess) {
                model.blID = [NSNumber numberWithLongLong:db.lastInsertRowId].intValue;
            }else{
                *rollback = YES;
                return ;
            }
        }
    }];
    return isSuccess;
}

+ (NSArray *)selectAll
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@",NSStringFromClass(self)];
    return [self selectTableBySql:sql withArgumentsInArray:nil];
}

+ (NSArray*)selectTableWhereKey:(NSString *)key equalTo:(id)value
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=?",NSStringFromClass(self),key];
    return [self selectTableBySql:sql withArgumentsInArray:@[value]];
}

+ (NSArray *)selectTableWithRequirement:(NSString *)requirement
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ %@",NSStringFromClass(self),requirement] ;
    return [self selectTableBySql:sql withArgumentsInArray:nil];
}

+ (BOOL)clearTable
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@",NSStringFromClass(self)];
    return [self updateTableBySql:sql];
}

- (BOOL)deleteObject
{
    BLDBHelper *blDB = [BLDBHelper shareInstance];
    __block BOOL isSuccess = YES;
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@=?",NSStringFromClass(self.class),PrimaryKeyName];
    [blDB.dbQueue inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdate:sql,@(self.blID)];
    }];
    return isSuccess;
}

+ (BOOL)deleteObjects:(NSArray *)objects
{
    BLDBHelper *blDB = [BLDBHelper shareInstance];
    __block BOOL isSuccess = YES;
    [blDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (BLDBModel *model in objects) {
            NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@=?",NSStringFromClass(self),PrimaryKeyName];
            isSuccess = [db executeUpdate:sql,@(model.blID)];
            if (!isSuccess) {
                *rollback = YES;
                NSLog(@"删除失败");
                return ;
            }
        }
    }];
    return isSuccess;
}

- (BOOL)updateObject
{
    BLDBHelper *blDB = [BLDBHelper shareInstance];
    __block BOOL isSuccess = YES;
    NSDictionary *dic = [self getUpdateSqlParam];
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where %@=?",NSStringFromClass(self.class),dic[@"nameStr"],PrimaryKeyName];
    [blDB.dbQueue inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdate:sql withArgumentsInArray:dic[@"valueArray"]];
        if (!isSuccess) {
            NSLog(@"更新失败");
        }
    }];
    return YES;
}

+ (BOOL)updateObjects:(NSArray *)objects
{
    BLDBHelper *blDB = [BLDBHelper shareInstance];
    __block BOOL isSuccess = YES;
    [blDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (BLDBModel *model in objects) {
            NSDictionary *dic = [model getUpdateSqlParam];
            NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where %@=?",NSStringFromClass(self.class),dic[@"nameStr"],PrimaryKeyName];
            isSuccess = [db executeUpdate:sql withArgumentsInArray:dic[@"valueArray"]];
            if (!isSuccess) {
                NSLog(@"更新失败");
                *rollback = YES;
            }
        }
    }];
    return isSuccess;
}

#pragma mark - private

//获取所有属性名数组 和 属性类型数组
+ (NSDictionary *)getPropertyNameAndType
{
    NSMutableArray *names = [[NSMutableArray alloc]init];
    NSMutableArray *types = [[NSMutableArray alloc]init];
    
    //添加主键属性
    [names addObject:PrimaryKeyName];
    [types addObject:@"INTEGER primary key autoincrement"];
    
    unsigned int count;
    
    objc_property_t *propertys = class_copyPropertyList(self.class, &count);
    for (unsigned int i = 0; i < count; i++) {
        objc_property_t property = propertys[i];
        //添加属性名
        NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        [names addObject:name];
        //添加属性类型
        NSString *attribute = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        if ([attribute hasPrefix:@"T@"]) {
            [types addObject:@"TEXT"];
        } else if ([attribute hasPrefix:@"Ti"]||[attribute hasPrefix:@"TI"]||[attribute hasPrefix:@"Ts"]||[attribute hasPrefix:@"TS"]||[attribute hasPrefix:@"TB"]||[attribute hasPrefix:@"Tq"]||[attribute hasPrefix:@"TQ"]) {
            [types addObject:@"INTEGER"];
        } else {
            [types addObject:@"REAL"];
        }
    }
    free(propertys);
    return @{@"names":names,@"types":types};
}

//获取创建表时 sql语句的后半段字符串
+ (NSString *)getCreateTableSqlAttributeString
{
    NSDictionary *dic = [self.class getPropertyNameAndType];
    NSArray *nameArray = dic[@"names"];
    NSArray *typeArray = dic[@"types"];
    NSMutableString *str = [[NSMutableString alloc]init];
    for (int i = 0; i < nameArray.count; i++) {
        [str appendFormat:@"%@ %@",nameArray[i],typeArray[i]];
        if (i+1 < nameArray.count) {
            [str appendString:@","];
        }
    }
    return str;
}

//插入或更新时候的键名拼接的字符串，问号拼接的字符串和键对应值拼接的数组
- (NSDictionary *)getNameAndValueString
{
    NSMutableString *nameStr    = [[NSMutableString alloc]init];
    NSMutableString *valueStr   = [[NSMutableString alloc]init];
    NSMutableArray  *valueArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < self.nameArray.count; i++) {
        if ([self.nameArray[i] isEqualToString:PrimaryKeyName]) {
            continue;
        }
        [nameStr appendString:self.nameArray[i]];
        [valueStr appendString:@"?"];
        
        id value = [self valueForKey:self.nameArray[i]];
        if (!value) value = @"";
        [valueArray addObject:value];
        
        if (i+1 < self.nameArray.count) {
            [nameStr appendString:@","];
            [valueStr appendString:@","];
        }
    }
    return @{@"nameStr":nameStr,@"valueStr":valueStr,@"valueArray":valueArray};
}

//获取更新语句的set字符串，以及需要传的值数组
- (NSDictionary *)getUpdateSqlParam
{
    NSMutableString *nameStr    = [[NSMutableString alloc]init];
    NSMutableArray  *valueArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < self.nameArray.count; i++) {
        if ([self.nameArray[i] isEqualToString:PrimaryKeyName]) {
            continue;
        }
        [nameStr appendFormat:@"%@=?",self.nameArray[i]];
        id value = [self valueForKey:self.nameArray[i]];
        if (!value) value = @"";
        [valueArray addObject:value];
        
        if (i+1 < self.nameArray.count) {
            [nameStr appendString:@","];
        }
    }
    [valueArray addObject:[self valueForKey:PrimaryKeyName]];
    return @{@"nameStr":nameStr,@"valueArray":valueArray};
}

//创建表
+ (BOOL)createTable
{
    BLDBHelper *blDB = [BLDBHelper shareInstance];
    __block BOOL isSuccess = YES;
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@(%@)",NSStringFromClass(self.class),[self getCreateTableSqlAttributeString]];
    [blDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //创建表
        if(![db executeUpdate:sql]){
            isSuccess = NO;
            *rollback = YES;
            return ;
        }
        
        //查看model是否添加了新的字段，如果有新的字段，在表中添加新的列
        //1. 查询出所有的列名
        NSMutableArray *columns = [[NSMutableArray alloc]init];
        FMResultSet *result = [db getTableSchema:NSStringFromClass(self)];
        while ([result next]) {
            [columns addObject:[result stringForColumn:@"name"]];
        }
        //2. 查询model所有的属性
        NSDictionary *dic       = [self getPropertyNameAndType];
        NSArray *propertys      = dic[@"names"];
        NSArray *types          = dic[@"types"];
        //3. 查询出model中有但是column没有的属性
        NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)",columns];
        NSArray *resultArray    = [propertys filteredArrayUsingPredicate:predicate];
        //4. 轮询添加列
        for (NSString *name in resultArray) {
            NSString *type = types[[propertys indexOfObject:name]];
            NSString *sql = [NSString stringWithFormat:@"alter table %@ add column %@ %@",NSStringFromClass(self),name,type];
            isSuccess = [db executeUpdate:sql];
            if (!isSuccess) {
                NSLog(@"插入列失败");
                *rollback = YES;
                return;
            }
        }
    }];
    return isSuccess;
}

//根据sql查询表
+ (NSArray *)selectTableBySql:(NSString *)sql withArgumentsInArray:(NSArray *)array
{
    BLDBHelper *blDB = [BLDBHelper shareInstance];
    NSMutableArray *modelArray = [[NSMutableArray alloc]init];
    [blDB.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sql withArgumentsInArray:array];
        if (!result) {
            NSLog(@"select error:%@",db.lastErrorMessage);
        }else{
            while([result next]) {
                [modelArray addObject:[self handleSelectResult:result]];
            }
        }
    }];
    return modelArray;
}

//对查询数据库返回的结果进行操作，返回对象
+ (BLDBModel *)handleSelectResult:(FMResultSet *)result
{
    BLDBModel *model = [[self alloc]init];
    for (int i = 0; i < model.nameArray.count; i++) {
        if ([model.typeArray[i] isEqualToString:@"TEXT"]) {
            [model setValue:[result objectForColumnName: model.nameArray[i]] forKey: model.nameArray[i]];
        }else if ([model.typeArray[i] isEqualToString:@"INTEGER"]){
            [model setValue:@([result longLongIntForColumn:model.nameArray[i]]) forKey: model.nameArray[i]];
        }else{
            [model setValue:@([result doubleForColumn:model.nameArray[i]]) forKey: model.nameArray[i]];
        }
    }
    return model;
}

//根据sql查询表
+ (BOOL)updateTableBySql:(NSString *)sql
{
    BLDBHelper *blDB = [BLDBHelper shareInstance];
    __block BOOL isSuccess = YES;
    [blDB.dbQueue inDatabase:^(FMDatabase *db) {
         isSuccess = [db executeUpdate:sql];
    }];
    return isSuccess;
}

@end
