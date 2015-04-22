//
//  ImitateSubjectService.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import "ImitateSubjectService.h"
#import <FMDB/FMDB.h>
#import "UserAccountData.h"
//#import "ExamData.h"
#import "ExamDataDao.h"
//#import "SubjectData.h"
#import "SubjectDataDao.h"

#define _kImitateSubjectService_rowsOfPage 10//每页数据
//模拟考场科目科目服务类成员变量
@interface ImitateSubjectService(){
    FMDatabaseQueue *_dbQueue;
}
@end
//模拟考场科目科目服务类实现
@implementation ImitateSubjectService
#pragma mark 重载构造函数。
-(instancetype)init{
    if(self = [super init]){
        _rowsOfPage = _kImitateSubjectService_rowsOfPage;
        
        NSError *err;
        NSString *dbPath = [[UserAccountData currentUser] loadDatabasePath:&err];
        if(!dbPath){
            NSLog(@"加载数据库文件路径时错误:%@",err);
        }else{
            _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        }
    }
    return self;
}
#pragma mark 加载考试Section数据
-(NSArray *)loadExams{
    if(!_dbQueue)return nil;
    __block NSArray *arrays;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        ExamDataDao *dao = [[ExamDataDao alloc]initWithDb:db];
        arrays = [dao loadExams];
    }];
    return arrays;
}
#pragma mark 加载科目Cell数据
-(NSArray *)loadSubjectsWithExamCode:(NSString *)examCode Index:(NSUInteger)index{
    if(!_dbQueue || !examCode || examCode.length == 0)return nil;
    if(index < 1)index = 1;
    __block NSArray *arrays;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        SubjectDataDao *dao = [[SubjectDataDao alloc]initWithDb:db];
        arrays = [dao loadSubjectPapgesWithExamCode:examCode PageIndex:index RowsOfPage:_rowsOfPage];
    }];
    return arrays;
}
//#pragma mark 加载全部的考试数据统计。
//-(NSInteger)loadAllExamTotal{
//    if(!_dbQueue) return 0;
//    __block NSInteger total = 0;
//    [_dbQueue inDatabase:^(FMDatabase *db) {
//        ExamDataDao *dao = [[ExamDataDao alloc]initWithDb:db];
//        total = [dao total];
//    }];
//    return total;
//}
//#pragma mark 加载考试索引下的科目数据统计。
//-(NSInteger)loadSubjectTotalWithExamIndex:(NSInteger)index{
//    if(!_dbQueue) return 0;
//    __block NSInteger total = 0;
//    [_dbQueue inDatabase:^(FMDatabase *db) {
//        ExamDataDao *examDao = [[ExamDataDao alloc]initWithDb:db];
//        NSString *examCode = [examDao loadExamCodeAtIndex:index];
//        if(examCode && examCode.length > 0){
//            SubjectDataDao *subjectDao = [[SubjectDataDao alloc]initWithDb:db];
//            total = [subjectDao totalWithExamCode:examCode];
//        }
//    }];
//    return total;
//}
//#pragma mark 加载指定索引的考试标题。
//-(NSString *)loadExamTitleWithIndex:(NSInteger)index{
//    if(!_dbQueue) return nil;
//    __block NSString *examName;
//    [_dbQueue inDatabase:^(FMDatabase *db) {
//        ExamDataDao *dao = [[ExamDataDao alloc]initWithDb:db];
//        examName = [dao loadExamNameAtIndex:index];
//    }];
//    return examName;
//}
//#pragma mark 根据制定索引加载科目数据。
//-(SubjectData *)loadSubjectWithExamIndex:(NSInteger)index andSubjectRow:(NSInteger)row{
//    if(!_dbQueue) return nil;
//    __block SubjectData *data;
//    [_dbQueue inDatabase:^(FMDatabase *db) {
//        ExamDataDao *examDao = [[ExamDataDao alloc]initWithDb:db];
//        NSString *examCode = [examDao loadExamCodeAtIndex:index];
//        if(examCode && examCode.length > 0){
//            SubjectDataDao *subjectDao = [[SubjectDataDao alloc]initWithDb:db];
//            data = [subjectDao loadDataWithExamCode:examCode AtRow:row];
//        }
//    }];
//    return data;
//}
#pragma mark 内存回收
-(void)dealloc{
    if(_dbQueue){
        [_dbQueue close];
    }
}
@end