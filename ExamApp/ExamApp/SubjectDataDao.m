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
@end