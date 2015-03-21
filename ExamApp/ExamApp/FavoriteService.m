//
//  FavoriteService.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/20.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "FavoriteService.h"
#import <FMDB/FMDB.h>

#import "UserAccountData.h"

#import "ExamData.h"
#import "ExamDataDao.h"

#import "SubjectData.h"
#import "SubjectDataDao.h"

#import "PaperItemFavorite.h"
#import "PaperItemFavoriteDao.h"

//收藏服务成员变量
@interface FavoriteService(){
    FMDatabaseQueue *_dbQueue;
}
@end
//收藏服务实现
@implementation FavoriteService
#pragma mark 重构初始化
- (instancetype)init
{
    if (self = [super init]) {
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
#pragma mark 加载全部的考试数据统计
-(NSInteger)loadAllExamTotal{
    if(!_dbQueue) return 0;
    __block NSInteger total = 0;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        ExamDataDao *dao = [[ExamDataDao alloc]initWithDb:db];
        total = [dao total];
    }];
    return total;
}
#pragma mark 加载考试索引下的科目数据统计
-(NSInteger)loadSubjectTotalWithExamIndex:(NSInteger)index{
    if(!_dbQueue) return 0;
    __block NSInteger total = 0;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        ExamDataDao *examDao = [[ExamDataDao alloc]initWithDb:db];
        NSString *examCode = [examDao loadExamCodeAtIndex:index];
        if(examCode && examCode.length > 0){
            SubjectDataDao *subjectDao = [[SubjectDataDao alloc]initWithDb:db];
            total = [subjectDao totalWithExamCode:examCode];
        }
    }];
    return total;
}
#pragma mark 加载指定索引下的考试名称
-(NSString *)loadExamTitleWithIndex:(NSInteger)index{
    if(!_dbQueue) return nil;
    __block NSString *examName;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        ExamDataDao *dao = [[ExamDataDao alloc]initWithDb:db];
        examName = [dao loadExamNameAtIndex:index];
    }];
    return examName;
}
#pragma mark 加载指定索引下的科目数据
-(void)loadWithExamWithIndex:(NSInteger)index andSubjectRow:(NSInteger)row Block:(void (^)(SubjectData *, NSInteger))block{
    if(!_dbQueue || !block)return;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        ExamDataDao *examDao = [[ExamDataDao alloc]initWithDb:db];
        NSString *examCode = [examDao loadExamCodeAtIndex:index];
        if(examCode && examCode.length > 0){
            SubjectDataDao *subjectDao = [[SubjectDataDao alloc]initWithDb:db];
            SubjectData *subject = [subjectDao loadDataWithExamCode:examCode AtRow:row];
            if(subject && subject.code){
                PaperItemFavoriteDao *favoriteDao = [[PaperItemFavoriteDao alloc]initWithDb:db];
                NSInteger favorites = [favoriteDao totalWithSubjectCode:subject.code];
                block(subject,favorites);
            }
        }
    }];
}
#pragma mark 内存回收
-(void)dealloc{
    if(_dbQueue){
        [_dbQueue close];
    }
}
@end
