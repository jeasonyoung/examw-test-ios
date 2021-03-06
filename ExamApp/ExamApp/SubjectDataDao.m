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

#import "SubjectCell.h"

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
#pragma mark 分页加载科目收藏数据
-(NSArray *)loadSubjectFavoritesWithExamCode:(NSString *)examCode PageIndex:(NSUInteger)pageIndex RowsOfPage:(NSUInteger)rowsOfPage{
    if(!_db || ![_db tableExists:__k_subjectdatadao_tableName])return nil;
    if(pageIndex < 1)pageIndex = 1;
    if(rowsOfPage <= 0)rowsOfPage = 10;
    
    NSMutableString *query_sql = [NSMutableString stringWithString:@"select a.code,a.name,count(b.id) as total "];
    [query_sql appendString:@" from tbl_subjects a "];
    [query_sql appendString:@" left outer join tbl_favorites b on b.subjectCode = a.code"];
    [query_sql appendString:@" where a.examCode = ? "];
    [query_sql appendString:@" group by a.code,a.name"];
    [query_sql appendFormat:@" order by a.code limit %d,%d ", (int)((pageIndex - 1) * rowsOfPage), (int)rowsOfPage];
    
    NSMutableArray *arrays = [NSMutableArray array];
    FMResultSet *rs = [_db executeQuery:query_sql,examCode];
    while ([rs next]) {
        SubjectCell *data = [[SubjectCell alloc]init];
        data.code = [rs stringForColumn:@"code"];
        data.name = [rs stringForColumn:@"name"];
        data.total = [NSNumber numberWithInt:[rs intForColumn:@"total"]];
        [arrays addObject:data];
    }
    [rs close];
    return arrays;
}
#pragma mark 分页加载科目错题数据
-(NSArray *)loadSubjectWrongsWithExamCode:(NSString *)examCode PageIndex:(NSUInteger)pageIndex RowsOfPage:(NSUInteger)rowsOfPage{
    if(!_db || ![_db tableExists:__k_subjectdatadao_tableName])return nil;
    if(pageIndex < 1)pageIndex = 1;
    if(rowsOfPage <= 0)rowsOfPage = 10;
    
    NSMutableString *query_sql = [NSMutableString stringWithString:@"select a.code,a.name,count(d.id) as total "];
    [query_sql appendString:@" from tbl_subjects a "];
    
    [query_sql appendString:@" left outer join tbl_papers b on b.subjectCode = a.code "];
    [query_sql appendString:@" left outer join tbl_paperRecords c on c.paperId = b.id "];
    [query_sql appendFormat:@" left outer join tbl_itemRecords d on d.paperRecordId = c.id and d.status = %d",[NSNumber numberWithBool:NO].intValue];
    
    [query_sql appendString:@" where a.examCode = ? and a.status = ?  "];
    [query_sql appendString:@" group by a.code,a.name"];
    [query_sql appendFormat:@" order by a.code limit %d,%d ", (int)((pageIndex - 1) * rowsOfPage), (int)rowsOfPage];
    
    NSMutableArray *arrays = [NSMutableArray array];
    FMResultSet *rs = [_db executeQuery:query_sql,examCode,[NSNumber numberWithBool:YES]];
    while ([rs next]) {
        SubjectCell *data = [[SubjectCell alloc]init];
        data.code = [rs stringForColumn:@"code"];
        data.name = [rs stringForColumn:@"name"];
        data.total = [NSNumber numberWithInt:[rs intForColumn:@"total"]];
        [arrays addObject:data];
    }
    [rs close];
    return arrays;
}
#pragma mark 分页加载科目试卷数据
-(NSArray *)loadSubjectPapgesWithExamCode:(NSString *)examCode PageIndex:(NSUInteger)pageIndex RowsOfPage:(NSUInteger)rowsOfPage{
    if(!_db || ![_db tableExists:__k_subjectdatadao_tableName])return nil;
    if(pageIndex < 1)pageIndex = 1;
    if(rowsOfPage <= 0)rowsOfPage = 10;
    
    NSMutableString *query_sql = [NSMutableString stringWithString:@"select a.code,a.name,count(b.id) as total "];
    [query_sql appendString:@" from tbl_subjects a "];
    [query_sql appendString:@" left outer join tbl_papers b on b.subjectCode = a.code"];
    [query_sql appendString:@" where a.examCode = ? "];
    [query_sql appendString:@" group by a.code,a.name"];
    [query_sql appendFormat:@" order by a.code limit %d,%d ", (int)((pageIndex - 1) * rowsOfPage), (int)rowsOfPage];
    
    NSMutableArray *arrays = [NSMutableArray array];
    FMResultSet *rs = [_db executeQuery:query_sql,examCode];
    while ([rs next]) {
        SubjectCell *data = [[SubjectCell alloc]init];
        data.code = [rs stringForColumn:@"code"];
        data.name = [rs stringForColumn:@"name"];
        data.total = [NSNumber numberWithInt:[rs intForColumn:@"total"]];
        [arrays addObject:data];
    }
    [rs close];
    return arrays;

}
//#pragma mark 统计考试下的科目
//-(NSInteger)totalWithExamCode:(NSString *)examCode{
//    NSInteger total = 0;
//    if(examCode && examCode.length > 0 && _db && [_db tableExists:__k_subjectdatadao_tableName]){
//        NSString *query_sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ > 0 and %@ = ?",
//                               __k_subjectdatadao_tableName,
//                               __k_subjectdata_fields_status,
//                               __k_subjectdata_fields_examCode];
//        total = [_db intForQuery:query_sql,examCode];
//    }
//    return total;
//}
//#pragma mark 根据科目ID获取科目名称
//-(NSString *)loadSubjectNameWithSubjectCode:(NSString *)subjectCode{
//    if(_db && subjectCode && subjectCode.length > 0){
//        NSString *query_sql = [NSString stringWithFormat:@"select %@ from %@ where %@ = ?",
//                               __k_subjectdata_fields_name,
//                               __k_subjectdatadao_tableName,
//                               __k_subjectdata_fields_code];
//        return [_db stringForQuery:query_sql,subjectCode];
//    }
//    return nil;
//}
//#pragma mark 加载考试下的科目索引下的科目
//-(SubjectData *)loadDataWithExamCode:(NSString *)examCode AtRow:(NSInteger)row{
//    SubjectData *data;
//    if(examCode && examCode.length > 0 && _db && [_db tableExists:__k_subjectdatadao_tableName]){
//        if(row < 0) row = 0;
//        NSString *query_sql = [NSString stringWithFormat:@"select * from %@ where %@ > 0 and %@ = ? limit %ld,1",
//                               __k_subjectdatadao_tableName,__k_subjectdata_fields_status,
//                               __k_subjectdata_fields_examCode,(long)row];
//        FMResultSet *rs = [_db executeQuery:query_sql,examCode];
//        while ([rs next]) {
//            data = [[SubjectData alloc]init];
//            data.code = [rs stringForColumn:__k_subjectdata_fields_code];
//            data.name = [rs stringForColumn:__k_subjectdata_fields_name];
//            data.examCode = [rs stringForColumn:__k_subjectdata_fields_examCode];
//            data.status = [rs intForColumn:__k_subjectdata_fields_status];
//            break;
//        }
//        [rs close];
//    }
//    return data;
//}
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
    if(!subject || !subject.code)return;
    //查询数据是否存在
    NSString *query_sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = ?",
                           __k_subjectdatadao_tableName,__k_subjectdata_fields_code];
    long total = [_db longForQuery:query_sql,subject.code];
    if(total > 0){//更新数据
        NSString *update_sql = [NSString stringWithFormat:@"update %@ set %@ = ?,%@ = ?,%@ = ? where %@ = ?",
                                __k_subjectdatadao_tableName,
                                __k_subjectdata_fields_name,
                                __k_subjectdata_fields_examCode,
                                __k_subjectdata_fields_status,
                                __k_subjectdata_fields_code];
        [_db executeUpdate:update_sql,subject.name,subject.examCode,[NSNumber numberWithBool:YES],subject.code];
    }else{//新增数据
        NSString *insert_sql = [NSString stringWithFormat:@"insert into %@(%@,%@,%@,%@) values(?,?,?,?)",
                                __k_subjectdatadao_tableName,
                                __k_subjectdata_fields_code,
                                __k_subjectdata_fields_name,
                                __k_subjectdata_fields_examCode,
                                __k_subjectdata_fields_status];
        [_db executeUpdate:insert_sql,subject.code,subject.name,subject.examCode,[NSNumber numberWithBool:YES]];
    }
}
@end