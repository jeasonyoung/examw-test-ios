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
#import "SubjectDataDao.h"

#define __k_examdatadao_tableName @"tbl_exams"//考试数据表名称
#define __k_examdatadao_sync_subjects @"subjects"
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
#pragma mark 统计全部的数据
-(NSInteger)total{
    NSInteger total = 0;
    if(_db && [_db tableExists:__k_examdatadao_tableName]){
        NSString *query_sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ > 0",
                               __k_examdatadao_tableName,__k_examdata_fields_status];
        total = [_db intForQuery:query_sql];
    }
    return total;
}
#pragma mark 根据索引加载指定的数据
-(ExamData *)loadDataAtIndex:(NSInteger)index{
    ExamData *data;
    if(_db && [_db tableExists:__k_examdatadao_tableName]){
        if(index < 0) index = 0;
        NSString *query_sql = [NSString stringWithFormat:@"select * from %@ where %@ > 0 limit %ld,1",
                               __k_examdatadao_tableName,__k_examdata_fields_status,(long)index];
        FMResultSet *rs = [_db executeQuery:query_sql];
        while ([rs next]) {
            data = [[ExamData alloc]init];
            data.code = [rs stringForColumn:__k_examdata_fields_code];
            data.name = [rs stringForColumn:__k_examdata_fields_name];
            data.abbr = [rs stringForColumn:__k_examdata_fields_abbr];
            data.status = [rs intForColumn:__k_examdata_fields_status];
            break;
        }
        [rs close];
    }
    return data;
}
#pragma mark 根据指定索引加载考试代码
-(NSString *)loadExamCodeAtIndex:(NSInteger)index{
    if(_db && [_db tableExists:__k_examdatadao_tableName]){
        if(index < 0) index = 0;
        NSString *query_sql = [NSString stringWithFormat:@"select %@ from %@ where %@ > 0 limit %ld,1",
                               __k_examdata_fields_code,__k_examdatadao_tableName,
                               __k_examdata_fields_status,(long)index];
        return [_db stringForQuery:query_sql];
    }
    return nil;
}
#pragma mark 根据指定索引加载考试名称
-(NSString *)loadExamNameAtIndex:(NSInteger)index{
    if(_db && [_db tableExists:__k_examdatadao_tableName]){
        if(index < 0) index = 0;
        NSString *query_sql = [NSString stringWithFormat:@"select %@ from %@ where %@ > 0 limit %ld,1",
                               __k_examdata_fields_name,__k_examdatadao_tableName,
                               __k_examdata_fields_status,(long)index];
        return [_db stringForQuery:query_sql];
    }
    return nil;
}
#pragma mark 同步数据
-(void)syncWithData:(NSDictionary *)data{
    if(!_db || ![_db tableExists:__k_examdatadao_tableName])return;
    //数据对象转换
    ExamData *exam = [[ExamData alloc] init];
    exam.code = [data objectForKey:__k_examdata_fields_code];
    exam.name = [data objectForKey:__k_examdata_fields_name];
    exam.abbr = [data objectForKey:__k_examdata_fields_abbr];
    
    NSString *reset_sql = [NSString stringWithFormat:@"update %@ set %@ = ?",
                           __k_examdatadao_tableName,__k_examdata_fields_status];
    //重置数据状态
    [_db executeUpdate:reset_sql,[NSNumber numberWithBool:NO]];
    //查询数据是否存在
    NSString *query_sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = ?",
                           __k_examdatadao_tableName, __k_examdata_fields_code];
    long total = [_db longForQuery:query_sql, exam.code];
    if(total > 0){//更新数据
        NSString *update_sql = [NSString stringWithFormat:@"update %@ set %@ = ?,%@ = ?, %@ = ? where %@ = ?",
                                __k_examdatadao_tableName,
                                __k_examdata_fields_name,
                                __k_examdata_fields_abbr,
                                __k_examdata_fields_status,
                                __k_examdata_fields_code];
        [_db executeUpdate:update_sql, exam.name, exam.abbr, [NSNumber numberWithBool:YES], exam.code];
    }else{//新增数据
        NSString *insert_sql = [NSString stringWithFormat:@"insert into %@(%@,%@,%@,%@) values(?,?,?,?)",
                                __k_examdatadao_tableName,
                                __k_examdata_fields_code,
                                __k_examdata_fields_name,
                                __k_examdata_fields_abbr,
                                __k_examdata_fields_status];
        [_db executeUpdate:insert_sql,exam.code, exam.name,exam.abbr,[NSNumber numberWithBool:YES]];
    }
    //同步科目数据
    NSArray *subjectArrays = [data objectForKey:__k_examdatadao_sync_subjects];
    if(subjectArrays && subjectArrays.count > 0){
        //同步科目数据
        [[[SubjectDataDao alloc] initWithDb:_db] syncWithExamCode:exam.code Data:subjectArrays];
    }
}
@end
