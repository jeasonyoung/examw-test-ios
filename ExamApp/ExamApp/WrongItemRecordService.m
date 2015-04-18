//
//  WrongItemRecordService.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "WrongItemRecordService.h"
#import <FMDB/FMDB.h>

#import "UserAccountData.h"

//#import "ExamData.h"
#import "ExamDataDao.h"
//#import "SubjectData.h"
#import "SubjectDataDao.h"
#import "PaperItemRecord.h"
#import "PaperItemRecordDao.h"

#define _kWrongItemRecordService_rowsOfPage 10//每页数据
//错题记录服务成员变量
@interface WrongItemRecordService(){
    FMDatabaseQueue *_dbQueue;
}
@end
//错题记录服务实现
@implementation WrongItemRecordService
#pragma mark 重构初始化
-(instancetype)init{
    if(self = [super init]){
        _rowsOfPage = _kWrongItemRecordService_rowsOfPage;
        
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
        arrays = [dao loadSubjectWrongsWithExamCode:examCode PageIndex:index RowsOfPage:_rowsOfPage];
    }];
    return arrays;
}
//#pragma mark 加载考试数据统计
//-(NSInteger)loadAllExamTotal{
//    if(!_dbQueue) return 0;
//    __block NSInteger total = 0;
//    [_dbQueue inDatabase:^(FMDatabase *db) {
//        ExamDataDao *dao = [[ExamDataDao alloc]initWithDb:db];
//        total = [dao total];
//    }];
//    return total;
//}
//#pragma mark 加载考试索引下的科目数据统计
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
//#pragma mark 加载指定索引下的考试标题
//-(NSString *)loadExamTitleWithSection:(NSInteger)section{
//    if(!_dbQueue) return nil;
//    if(section < 0) section = 0;
//    __block NSString *examTitle;
//    [_dbQueue inDatabase:^(FMDatabase *db) {
//        ExamDataDao *dao = [[ExamDataDao alloc]initWithDb:db];
//        examTitle = [dao loadExamNameAtIndex:section];
//    }];
//    return examTitle;
//}
//#pragma mark 加载科目数据
//-(void)loadSubjectWithExamAtSection:(NSInteger)section
//                             andRow:(NSInteger)row
//                               Data:(void (^)(SubjectData *, NSInteger))block{
//    if(!_dbQueue || !block)return;
//    [_dbQueue inDatabase:^(FMDatabase *db) {
//        ExamDataDao *examDao = [[ExamDataDao alloc]initWithDb:db];
//        NSString *examCode = [examDao loadExamCodeAtIndex:section];
//        if(examCode && examCode.length > 0){
//            SubjectDataDao *subjectDao = [[SubjectDataDao alloc]initWithDb:db];
//            SubjectData *subject = [subjectDao loadDataWithExamCode:examCode AtRow:row];
//            if(subject && subject.code){
//                PaperItemRecordDao *itemRecordDao = [[PaperItemRecordDao alloc]initWithDb:db];
//                NSInteger wrongs = [itemRecordDao totalWrongItemsWithSubjectCode:subject.code];
//                block(subject,wrongs);
//            }
//        }
//    }];
//}
//#pragma mark 根据科目ID获取科目名称
//-(NSString *)loadSubjectNameWithSubjectCode:(NSString *)subjectCode{
//    if(_dbQueue && subjectCode && subjectCode.length > 0){
//        __block NSString *subjectName;
//        [_dbQueue inDatabase:^(FMDatabase *db) {
//            SubjectDataDao *dao = [[SubjectDataDao alloc]initWithDb:db];
//            subjectName = [dao loadSubjectNameWithSubjectCode:subjectCode];
//        }];
//        return subjectName;
//    }
//    return nil;
//}
#pragma mark 加载错题答题卡
-(void)loadSheetWithSubjectCode:(NSString *)subjectCode
                    SheetsBlock:(void (^)(NSString *, NSArray *))block{
    if(_dbQueue && block && subjectCode && subjectCode.length > 0){
        NSArray *itemTypeArrays = @[[NSNumber numberWithInt:(int)PaperItemTypeSingle],
                                    [NSNumber numberWithInt:(int)PaperItemTypeMulty],
                                    [NSNumber numberWithInt:(int)PaperItemTypeUncertain],
                                    [NSNumber numberWithInt:(int)PaperItemTypeJudge],
                                    [NSNumber numberWithInt:(int)PaperItemTypeQanda],
                                    [NSNumber numberWithInt:(int)PaperItemTypeShareTitle],
                                    [NSNumber numberWithInt:(int)PaperItemTypeShareAnswer]];
        [_dbQueue inDatabase:^(FMDatabase *db) {
            PaperItemRecordDao *dao = [[PaperItemRecordDao alloc]initWithDb:db];
            NSInteger order = 0, index = 0;
            for(NSNumber *itemTypeValue in itemTypeArrays){
                if(!itemTypeValue)continue;
                PaperItemType itemType = (PaperItemType)itemTypeValue.intValue;
                NSInteger total = [dao totalWrongItemsWithSubjectCode:subjectCode AtItemType:itemType];
                if(total > 0){
                    NSMutableArray *sheetArrays =[NSMutableArray array];
                    for(NSInteger i = 0; i < total; i++){
                        [sheetArrays addObject:[NSNumber numberWithInteger:(order++)]];
                    }
                    block([NSString stringWithFormat:@"%ld.%@",(long)((int)(index++) + 1),[PaperItem itemTypeName:itemType]],sheetArrays);
                }
            }
        }];
    }
}
#pragma mark 加载错题数据
-(PaperItemRecord *)loadWrongWithSubjectCode:(NSString *)subjectCode
                                     AtOrder:(NSInteger)order{
    if(_dbQueue && subjectCode && subjectCode.length > 0){
        if(order < 0) order = 0;
        __block PaperItemRecord *data;
        [_dbQueue inDatabase:^(FMDatabase *db) {
            PaperItemRecordDao *dao = [[PaperItemRecordDao alloc]initWithDb:db];
            data = [dao loadWrongItemWithSubjectCode:subjectCode AtOrder:order];
        }];
        return data;
    }
    return nil;
}
@end
