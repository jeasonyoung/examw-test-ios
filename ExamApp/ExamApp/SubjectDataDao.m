//
//  SubjectDataDao.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "SubjectDataDao.h"
#import <FMDB/FMDB.h>
#import "SubjectData.h"

#define __k_subjectdatadao_tableName @"tbl_subjects"//表名称
//科目数据操作类成员变量。
@interface SubjectDataDao(){
    FMDatabase *_db;
}
@end
//科目数据操作类实现。
@implementation SubjectDataDao
#pragma mark 初始化
-(instancetype)initWithDb:(FMDatabase *)db{
    if(self = [super init]){
        _db =  db;
    }
    return self;
}
#pragma mark 加载数据
-(NSArray *)loadAllWithExamCode:(NSString *)code{
    if(!_db || ![_db tableExists:__k_subjectdatadao_tableName]) return nil;
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ > 0 and %@ = ?",
                     __k_subjectdatadao_tableName,__k_subjectdata_fields_status,__k_subjectdata_fields_exam_code];
    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *rs = [_db executeQuery:sql, code];
    while ([rs next]) {
        SubjectData *data = [[SubjectData alloc] init];
        data.code = [rs stringForColumn:__k_subjectdata_fields_code];
        data.name = [rs stringForColumn:__k_subjectdata_fields_name];
        data.examCode = [rs stringForColumn:__k_subjectdata_fields_exam_code];
        data.status = [rs intForColumn:__k_subjectdata_fields_status];
        [array addObject:data];
    }
    [rs close];
    return [array mutableCopy];
}
#pragma mark 同步数据
-(void)syncWithExamCode:(NSString *)examCode Data:(NSArray *)data{
    if(!examCode || (!data) || data.count == 0)return;
    if(!_db || ![_db tableExists:__k_subjectdatadao_tableName]) return;
    //重置原始数据
    NSString *reset_sql = [NSString stringWithFormat:@"update %@ set %@ = ?",
                           __k_subjectdatadao_tableName,__k_subjectdata_fields_status];
    [_db executeUpdate:reset_sql,[NSNumber numberWithBool:NO]];
    //同步科目
    for (NSDictionary *dict in data) {
        if(!dict || dict.count == 0) continue;
        SubjectData *subject = [[SubjectData alloc] init];
        subject.code = [dict objectForKey:__k_subjectdata_fields_code];
        subject.name = [dict objectForKey:__k_subjectdata_fields_name];
        subject.examCode = examCode;
        //同步具体科目
        [self syncWithSubject:subject];
    }
}
//同步科目
-(void)syncWithSubject:(SubjectData *)subject{
    if(!subject)return;
    //查询数据是否存在
    NSString *query_sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = ?",
                           __k_subjectdatadao_tableName,__k_subjectdata_fields_code];
    long total = [_db longForQuery:query_sql,subject.code];
    if(total > 0){//更新数据
        NSString *update_sql = [NSString stringWithFormat:@"update %@ set %@ = ?,%@ = ?,%@ = ? where %@ = ?",
                                __k_subjectdatadao_tableName,
                                __k_subjectdata_fields_name,
                                __k_subjectdata_fields_exam_code,
                                __k_subjectdata_fields_status,
                                __k_subjectdata_fields_code];
        [_db executeUpdate:update_sql,subject.name,subject.examCode,[NSNumber numberWithBool:YES],subject.code];
    }else{//新增数据
        NSString *insert_sql = [NSString stringWithFormat:@"insert into %@(%@,%@,%@,%@) values(?,?,?,?)",
                                __k_subjectdatadao_tableName,
                                __k_subjectdata_fields_code,
                                __k_subjectdata_fields_name,
                                __k_subjectdata_fields_exam_code,
                                __k_subjectdata_fields_status];
        [_db executeUpdate:insert_sql,subject.code,subject.name,subject.examCode,[NSNumber numberWithBool:YES]];
    }
}
@end