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

#import "PaperItemFavorite.h"
#import "PaperItemFavoriteDao.h"

#import "PaperReview.h"

#import "PaperDataDao.h"

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
#pragma mark 加载试卷记录
-(PaperRecord *)loadRecordWithPaperRecordCode:(NSString *)paperRecordCode{
    if(_dbQueue && paperRecordCode && paperRecordCode.length > 0){
        __block PaperRecord *record;
        [_dbQueue inDatabase:^(FMDatabase *db) {
            PaperRecordDao * dao = [[PaperRecordDao alloc]initWithDb:db];
            record = [dao loadPaperRecord:paperRecordCode];
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
            //数据操作
            PaperRecordDao *paperDao = [[PaperRecordDao alloc] initWithDb:db];
            //更新数据
            [paperDao updateRecord:&paperRecord];
        }];
    }
}


#pragma mark 加载试卷记录下最新的试题记录
-(PaperItemRecord *)loadLastRecordWithPaperRecordCode:(NSString *)paperRecordCode{
    if(_dbQueue && paperRecordCode && paperRecordCode.length > 0){
        __block PaperItemRecord *record;
        [_dbQueue inDatabase:^(FMDatabase *db) {
            PaperItemRecordDao *dao = [[PaperItemRecordDao alloc] initWithDb:db];
            record = [dao loadLastRecordWithPaperRecordCode:paperRecordCode];
        }];
        return record;
    }
    return nil;
}
#pragma mark 加载完成的试题数
-(NSNumber *)loadFinishItemsWithPaperRecordCode:(NSString *)paperRecordCode{
    if(_dbQueue && paperRecordCode && paperRecordCode.length > 0){
        __block NSNumber *finishes = [NSNumber numberWithInt:0];
        [_dbQueue inDatabase:^(FMDatabase *db) {
            PaperItemRecordDao *dao = [[PaperItemRecordDao alloc]initWithDb:db];
            finishes = [dao totalFinishItemsWithPaperRecordCode:paperRecordCode];
        }];
        return finishes;
    }
    return [NSNumber numberWithInt:0];
}
#pragma mark 加载做对的试题数
-(NSNumber *)loadRightItemsWithPaperRecordCode:(NSString *)paperRecordCode{
    if(_dbQueue && paperRecordCode && paperRecordCode.length > 0){
        __block NSNumber *rights = [NSNumber numberWithInt:0];
        [_dbQueue inDatabase:^(FMDatabase *db) {
            PaperItemRecordDao *dao = [[PaperItemRecordDao alloc] initWithDb:db];
            rights = [dao totalAllRightsWithPaperRecordCode:paperRecordCode];
        }];
        return rights;
    }
    return [NSNumber numberWithInt:0];
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
        }];
        return itemRecord;

    }
    return nil;
}
#pragma mark 加载试题记录(不存在则创建新记录)
-(PaperItemRecord *)loadRecordAndNewWithPaperRecordCode:(NSString *)paperRecordCode
                                         ItemCode:(NSString *)itemCode
                                          atIndex:(NSInteger)index{
    if(_dbQueue && paperRecordCode && paperRecordCode.length > 0 && itemCode && itemCode.length > 0){
        PaperItemRecord *itemRecord = [self loadRecordWithPaperRecordCode:paperRecordCode ItemCode:itemCode atIndex:index];
        if(!itemRecord){
            itemRecord = [[PaperItemRecord alloc]init];
            itemRecord.paperRecordCode = paperRecordCode;
            itemRecord.itemCode = [NSString stringWithFormat:@"%@$%ld",itemCode,(long)(index < 0 ? 0 : index)];
            itemRecord.status = [NSNumber numberWithInt:-1];
            itemRecord.score = [NSNumber numberWithDouble:0];
            itemRecord.useTimes = [NSNumber numberWithInteger:0];
        }
        return itemRecord;
    }
    return nil;
}
#pragma mark 加载试题记录的答案
-(NSString *)loadAnswerRecordWithPaperRecordCode:(NSString *)paperRecordCode ItemCode:(NSString *)itemCode atIndex:(NSInteger)index{
    if(_dbQueue && paperRecordCode && paperRecordCode.length > 0 && itemCode && itemCode.length > 0){
        if(index < 0) index = 0;
        NSString *itemCodeIndex = [NSString stringWithFormat:@"%@$%ld",itemCode,(long)index];
        __block NSString *answer;
        [_dbQueue inDatabase:^(FMDatabase *db) {
            PaperItemRecordDao *dao = [[PaperItemRecordDao alloc] initWithDb:db];
            answer = [dao loadAnswerWithPaperRecordCode:paperRecordCode ItemCode:itemCodeIndex];
        }];
        return answer;
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
    if(_dbQueue && itemRecord && itemRecord.itemCode && itemRecord.itemCode.length > 0 &&
       itemRecord.paperRecordCode && itemRecord.paperRecordCode.length > 0){
       
        if(!itemRecord.answer || itemRecord.answer.length == 0){
            itemRecord.status = [NSNumber numberWithInt:-1];
        }
        __block PaperItemRecord *record = itemRecord;
        [_dbQueue inDatabase:^(FMDatabase *db) {
            PaperItemRecordDao *dao = [[PaperItemRecordDao alloc] initWithDb:db];
            [dao updateRecordWithItemRecord:&record];
        }];
    }
}

#pragma mark 检查试题收藏是否存在
-(BOOL)exitFavoriteWithPaperCode:(NSString *)code ItemCode:(NSString *)itemCode atIndex:(NSInteger)index{
    if(_dbQueue && code && code.length > 0 && itemCode && itemCode.length > 0){
        if(index < 0) index = 0;
        __block BOOL result = NO;
        [_dbQueue inDatabase:^(FMDatabase *db) {
            PaperDataDao *paperDao = [[PaperDataDao alloc] initWithDb:db];
            NSString *subjectCode = [paperDao loadSubjectCodeWithPaperCode:code];
            if(!subjectCode || subjectCode.length == 0)return;
            
            PaperItemFavoriteDao *dao = [[PaperItemFavoriteDao alloc] initWithDb:db];
            NSString *itemCodeIndex = [NSString stringWithFormat:@"%@$%ld",itemCode,(long)index];
            result = [dao existFavoriteWithSubjectCode:subjectCode ItemCode:itemCodeIndex];
        }];
        return result;
    }
    return NO;
}
#pragma mark 添加收藏
-(void)addFavoriteWithPaperCode:(NSString *)code Data:(PaperItemOrderIndexPath *)indexPath{
    if(!_dbQueue || !code || code.length == 0 || !indexPath || !indexPath.item) return;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        PaperDataDao *paperDao = [[PaperDataDao alloc] initWithDb:db];
        NSString *subjectCode = [paperDao loadSubjectCodeWithPaperCode:code];
        if(!subjectCode || subjectCode.length == 0)return;
        
        PaperItemFavoriteDao *dao = [[PaperItemFavoriteDao alloc] initWithDb:db];
        NSString *itemCodeIndex = [NSString stringWithFormat:@"%@$%ld",indexPath.item.code,(long)indexPath.index];
        PaperItemFavorite *favorite = [dao loadFavoriteWithSubjectCode:subjectCode ItemCode:itemCodeIndex];
        if(!favorite){
            favorite = [[PaperItemFavorite alloc] init];
            favorite.subjectCode = subjectCode;
            favorite.itemCode = itemCodeIndex;
        }
        favorite.itemType = [NSNumber numberWithInteger:indexPath.item.type];
        favorite.itemContent = [indexPath.item serialize];
        favorite.status = [NSNumber numberWithBool:YES];
        [dao updateFavorite:&favorite];
    }];
}
#pragma mark 移除收藏
-(void)removeFavoriteWithPaperCode:(NSString *)code ItemCode:(NSString *)itemCode atIndex:(NSInteger)index{
    if(!_dbQueue || !code || code.length == 0 || !itemCode || itemCode.length == 0)return;
    if(index < 0) index = 0;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        PaperDataDao *paperDao = [[PaperDataDao alloc] initWithDb:db];
        NSString *subjectCode = [paperDao loadSubjectCodeWithPaperCode:code];
        if(!subjectCode || subjectCode.length == 0)return;
        
        PaperItemFavoriteDao *dao = [[PaperItemFavoriteDao alloc] initWithDb:db];
        NSString *itemCodeIndex = [NSString stringWithFormat:@"%@$%ld",itemCode,(long)index];
        [dao removeFavoriteWithSubjectCode:subjectCode ItemCode:itemCodeIndex];
    }];
}

#pragma mark 内存回收
-(void)dealloc{
    if(_dbQueue){
        [_dbQueue close];
    }
}
@end
