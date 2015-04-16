//
//  LearnRecordService.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "LearnRecordService.h"
#import <FMDB/FMDB.h>

#import "UserAccountData.h"

#import "PaperRecord.h"
#import "PaperRecordDao.h"

#import "PaperItemRecordDao.h"

#import "PaperData.h"
#import "PaperDataDao.h"

#import "PaperReview.h"

#define __kLearnRecordService_rowsOfPage 10//每页数据
//学习记录服务成员变量
@interface LearnRecordService (){
    FMDatabaseQueue *_dbQueue;
}
@end
//学习记录服务实现
@implementation LearnRecordService
#pragma mark 重构初始化
-(instancetype)init{
    if(self = [super init]){
        _rowsOfPage = __kLearnRecordService_rowsOfPage;
        
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
#pragma mark 按页加载数据
-(NSArray *)loadRecordsWithPageIndex:(NSUInteger)pageIndex{
    if(!_dbQueue)return nil;
    __block NSArray *arrays;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        PaperRecordDao *dao = [[PaperRecordDao alloc]initWithDb:db];
        arrays = [dao loadRecordsWithPageIndex:pageIndex RowsOfPage:_rowsOfPage];
    }];
    return arrays;
}
#pragma mark 根据试卷记录ID删除数据
-(void)deleteWithPaperRecordCode:(NSString *)paperRecordCode{
    if(!_dbQueue || !paperRecordCode || paperRecordCode.length == 0)return;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        //1.先删除试卷记录下的试题
        PaperItemRecordDao *itemRecordDao = [[PaperItemRecordDao alloc]initWithDb:db];
        [itemRecordDao deleteRecordWithPaperRecordCode:paperRecordCode];
        //2.再删除试卷记录
        PaperRecordDao *paperRecordDao = [[PaperRecordDao alloc]initWithDb:db];
        [paperRecordDao deleteRecordWithCode:paperRecordCode];
    }];
}


//#pragma mark 加载试卷记录全部的数据统计
//-(NSInteger)loadAllTotal{
//    if(!_dbQueue) return 0;
//    __block NSInteger total = 0;
//    [_dbQueue inDatabase:^(FMDatabase *db) {
//        PaperRecordDao *dao = [[PaperRecordDao alloc]initWithDb:db];
//        total = [dao total];
//    }];
//    return total;
//}
//#pragma mark 加载试卷记录数据
//-(void)loadRecordAtRow:(NSInteger)row Data:(void (^)(NSString *, NSString *, PaperRecord *))block{
//    if(!_dbQueue || !block)return;
//    [_dbQueue inDatabase:^(FMDatabase *db) {
//        PaperRecordDao *paperRecordDao = [[PaperRecordDao alloc]initWithDb:db];
//        PaperRecord *record = [paperRecordDao loadDataAtRow:row];
//        if(record && record.paperCode && record.paperCode.length > 0){
//            PaperDataDao *paperDao = [[PaperDataDao alloc]initWithDb:db];
//            PaperData *paper = [paperDao loadPaperWithCode:record.paperCode];
//            if(paper){
//                NSString *paperTypeName = [PaperReview paperTypeName:(PaperType)paper.type];
//                block(paperTypeName, paper.title, record);
//            }
//        }
//    }];
//}
//#pragma mark 根据试卷ID加载试卷数据
//-(PaperReview *)loadPaperReviewWithPaperCode:(NSString *)paperCode{
//    if(!_dbQueue || !paperCode || paperCode.length == 0) return nil;
//    __block PaperReview *paperReview;
//    [_dbQueue inDatabase:^(FMDatabase *db) {
//        PaperDataDao *dao = [[PaperDataDao alloc]initWithDb:db];
//        paperReview = [dao loadPaperContentWithCode:paperCode];
//    }];
//    return paperReview;
//}
@end
