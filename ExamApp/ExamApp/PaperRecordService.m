//
//  PaperRecordService.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperRecordService.h"
#import <FMDB/FMDB.h>
#import "UserAccountData.h"

#import "PaperRecord.h"
#import "PaperRecordDao.h"

#import "PaperItemRecord.h"
#import "PaperItemRecordDao.h"


//试卷记录服务成员变量
@interface PaperRecordService (){
    FMDatabaseQueue *_dbQueue;
}
@end
//试卷记录服务实现
@implementation PaperRecordService
#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        NSError *err;
        NSString *dbPath = [[UserAccountData currentUser] loadDatabasePath:&err];
        if(!dbPath){
            NSLog(@"PaperRecordService加载数据文件路径时错误：%@",err);
        }else{
            _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        }
    }
    return self;
}
#pragma mark 加载最新试卷记录
-(PaperRecord *)loadLastRecordWithPaperCode:(NSString *)paperCode{
    if(_dbQueue && paperCode && paperCode.length > 0){
        __block PaperRecord *record;
        [_dbQueue inDatabase:^(FMDatabase *db) {
            PaperRecordDao *dao = [[PaperRecordDao alloc] initWithDb:db];
            record = [dao loadLastPaperRecord:paperCode];
        }];
        return record;
    }
    return nil;
}
#pragma mark 创建新的试卷记录
-(PaperRecord *)createNewRecordWithPaperCode:(NSString *)paperCode{
    if(_dbQueue && paperCode && paperCode.length > 0){
        __block PaperRecord *record = [[PaperRecord alloc] init];
        record.paperCode = paperCode;
        record.status = [NSNumber numberWithInt:0];
        record.score = [NSNumber numberWithDouble:0];
        record.rights = [NSNumber numberWithInt:0];
        record.useTimes = [NSNumber numberWithLong:0];
        //
        [_dbQueue inDatabase:^(FMDatabase *db) {
            PaperRecordDao *dao = [[PaperRecordDao alloc] initWithDb:db];
            [dao updateRecord:&record];
        }];
        return record;
    }
    return nil;
}
#pragma mark 更新试卷记录
-(BOOL)updatePaperRecord:(PaperRecord *__autoreleasing *)paperRecord{
    __block BOOL result = NO;
    if(_dbQueue && paperRecord && (*paperRecord).code && (*paperRecord).code.length == 0){
        [_dbQueue inDatabase:^(FMDatabase *db) {
            PaperRecordDao *dao = [[PaperRecordDao alloc] initWithDb:db];
            result = [dao updateRecord:paperRecord];
        }];
    }
    return result;
}
#pragma mark 交卷
-(void)subjectWithPaperRecord:(PaperRecord *)record{
    if(_dbQueue && record && record.code && record.code.length > 0){
        __block PaperRecord *paperRecord = record;
        [_dbQueue inDatabase:^(FMDatabase *db) {
            PaperItemRecordDao *itemDao = [[PaperItemRecordDao alloc] initWithDb:db];
            //统计试题得分
            paperRecord.score = [itemDao totalAllItemScoreWithPaperRecordCode:paperRecord.code];
            //统计用时
            //paperRecord.useTimes = [itemDao totalAllUseTimesWithPaperRecordCode:paperRecord.code];
            //统计做对的试题数
            paperRecord.rights = [itemDao totalAllRightsWithPaperRecordCode:paperRecord.code];
            //状态
            paperRecord.status = [NSNumber numberWithBool:YES];
            //更新数据
            PaperRecordDao *paperDao = [[PaperRecordDao alloc] initWithDb:db];
            [paperDao updateRecord:&paperRecord];
        }];
    }
}
#pragma mark 加载试卷记录下最新的试题记录
-(PaperItemRecord *)loadLastRecordWithPaperRecordCode:(NSString *)paperRecordCode{
    return nil;
}
#pragma mark 加载试题记录
-(PaperItemRecord *)loadRecordWithPaperRecordCode:(NSString *)paperRecordCode
                                         ItemCode:(NSString *)itemCode
                                          atIndex:(NSInteger)index{
    if(_dbQueue && paperRecordCode && paperRecordCode.length > 0 && itemCode && itemCode.length > 0){
        if(index < 0) index = 0;
        NSString *itemCodeIndex = [NSString stringWithFormat:@"%@$%ld",itemCode,(long)index];
        __block PaperItemRecord *itemRecord;
        [_dbQueue inDatabase:^(FMDatabase *db) {
            PaperItemRecordDao *dao = [[PaperItemRecordDao alloc] initWithDb:db];
            itemRecord = [dao loadRecordWithPaperRecordCode:paperRecordCode ItemCode:itemCodeIndex];
            if(!itemRecord){
                itemRecord = [[PaperItemRecord alloc] init];
                itemRecord.paperRecordCode = paperRecordCode;
                itemRecord.itemCode = itemCodeIndex;
                itemRecord.status = [NSNumber numberWithInt:-1];
                itemRecord.score = [NSNumber numberWithDouble:0];
                itemRecord.useTimes = 0;
                [dao updateRecordWithItemRecord:&itemRecord];
            }
        }];
        return itemRecord;
    }
    return nil;
}
#pragma mark 试题记录是否存在
-(BOOL)exitItemRecordWithPaperRecordCode:(NSString *)paperRecordCode
                                ItemCode:(NSString *)itemCode
                                 atIndex:(NSInteger)index{
    __block BOOL result = NO;
    if(_dbQueue && paperRecordCode && paperRecordCode.length > 0 && itemCode && itemCode.length > 0){
        if(index < 0) index = 0;
        NSString *itemCodeIndex = [NSString stringWithFormat:@"%@$%ld",itemCode,(long)index];
        [_dbQueue inDatabase:^(FMDatabase *db) {
            PaperItemRecordDao *dao = [[PaperItemRecordDao alloc] initWithDb:db];
            result = [dao exitRecordWithPaperRecordCode:paperRecordCode ItemCode:itemCodeIndex];
        }];
    }
    return result;
}
#pragma mark 提交试题记录
-(void)subjectWithItemRecord:(PaperItemRecord *)itemRecord{
    if(_dbQueue && itemRecord && itemRecord.code && itemRecord.code.length > 0
       && itemRecord.itemCode && itemRecord.itemCode.length > 0){
       
        __block PaperItemRecord *record = itemRecord;
        if(!record.answer || record.answer.length == 0){
            record.status = [NSNumber numberWithInt:-1];
        }
        
        [_dbQueue inDatabase:^(FMDatabase *db) {
            PaperItemRecordDao *dao = [[PaperItemRecordDao alloc] initWithDb:db];
            [dao updateRecordWithItemRecord:&record];
        }];
    }
}

#pragma mark 内存回收
-(void)dealloc{
    if(_dbQueue){
        [_dbQueue close];
    }
}
@end
