//
//  ExamDataDao.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ExamDataDao.h"
#import "ExamData.h"
#import <FMDB/FMDB.h>
#define __k_examdatadao_tableName @"tbl_exams"//考试数据表名称
//考试数据数据库操作成员变量
@interface  ExamDataDao(){
    FMDatabase *_db;
}
@end
//考试数据数据库操作实现
@implementation ExamDataDao
#pragma mark 初始化
-(instancetype)initWithDb:(FMDatabase *)db{
    if(self = [super init]){
        _db = db;
    }
    return self;
}
#pragma mark 查询全部的有效数据
-(NSArray *)loadAll{
    if(!_db || ![_db tableExists:__k_examdatadao_tableName])return nil;
    NSMutableArray *array = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ > 0",
                     __k_examdatadao_tableName, __k_examdata_fields_status];
    FMResultSet *rs = [_db executeQuery:sql];
    while ([rs next]) {
        ExamData *data = [[ExamData alloc] init];
        data.code = [rs stringForColumn:__k_examdata_fields_code];
        data.name = [rs stringForColumn:__k_examdata_fields_name];
        data.abbr = [rs stringForColumn:__k_examdata_fields_abbr];
        data.status = [rs intForColumn:__k_examdata_fields_status];
        [array addObject:data];
    }
    [rs close];
    return [array mutableCopy];
}
@end
