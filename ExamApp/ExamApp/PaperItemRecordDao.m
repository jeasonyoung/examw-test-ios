//
//  PaperItemRecordDao.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemRecordDao.h"
#import <FMDB/FMDB.h>
#import "NSString+Date.h"
#import "NSDate+TimeZone.h"

#import "PaperItemRecord.h"
#import "PaperRecord.h"
#import "PaperData.h"

//做题记录数据操作成员变量
@interface PaperItemRecordDao (){
    FMDatabase *_db;
}
@end
//做题记录数据操作实现
@implementation PaperItemRecordDao
#pragma mark 初始化
-(instancetype)initWithDb:(FMDatabase *)db{
    if(self = [super init]){
        _db = db;
    }
    return self;
}
#pragma mark 根据试题记录ID加载数据
-(PaperItemRecord *)loadRecordWithItemRecordCode:(NSString *)itemRecordCode{
    if(!_db || !itemRecordCode || itemRecordCode.length == 0 || ![_db tableExists:__k_paperitemrecorddao_tableName]) return nil;
    NSString *query_sql = [NSString stringWithFormat:@"select * from %@ where %@ = ? order by %@ desc limit 0,1",
                           __k_paperitemrecorddao_tableName,
                           __k_paperitemrecord_fields_code,
                           __k_paperitemrecord_fields_lastTime];
    PaperItemRecord *record;
    FMResultSet *rs = [_db executeQuery:query_sql,itemRecordCode];
    while ([rs next]) {
        record = [self createRecord:rs];
        break;
    }
    [rs close];
    return record;
}
#pragma mark 根据试卷记录ID和试题ID加载试题记录
-(PaperItemRecord *)loadRecordWithPaperRecordCode:(NSString *)paperRecordCode ItemCode:(NSString *)itemCode{
    if(!_db || !paperRecordCode || paperRecordCode.length == 0 || !itemCode || itemCode.length == 0)return nil;
    if(![_db tableExists:__k_paperitemrecorddao_tableName])return nil;
    NSString *query_sql = [NSString stringWithFormat:@"select * from %@ where %@ = ? and %@ = ? order by %@ desc limit 0,1",
                           __k_paperitemrecorddao_tableName,
                           __k_paperitemrecord_fields_paperRecordCode,
                           __k_paperitemrecord_fields_itemCode,
                           __k_paperitemrecord_fields_lastTime];
    PaperItemRecord *record;
    FMResultSet *rs = [_db executeQuery:query_sql,paperRecordCode,itemCode];
    while ([rs next]) {
        record = [self createRecord:rs];
        break;
    }
    [rs close];
    return record;
}
#pragma mark 加载记录的答案
-(NSString *)loadAnswerWithPaperRecordCode:(NSString *)paperRecordCode ItemCode:(NSString *)itemCode{
    if(!_db || !paperRecordCode || paperRecordCode.length == 0 || !itemCode || itemCode.length == 0)return nil;
    if(![_db tableExists:__k_paperitemrecorddao_tableName]) return nil;
    NSString *query_sql = [NSString stringWithFormat:@"select %@ from %@ where %@ = ? and %@ = ? order by %@ desc limit 0,1",
                           __k_paperitemrecord_fields_answer,
                           __k_paperitemrecorddao_tableName,
                           __k_paperitemrecord_fields_paperRecordCode,
                           __k_paperitemrecord_fields_itemCode,
                           __k_paperitemrecord_fields_lastTime];
    return [_db stringForQuery:query_sql,paperRecordCode,itemCode];
}
#pragma mark 试题记录是否存在
-(BOOL)exitRecordWithPaperRecordCode:(NSString *)paperRecordCode ItemCode:(NSString *)itemCode{
    BOOL result = NO;
    if(_db && paperRecordCode && paperRecordCode.length > 0 && itemCode && itemCode.length > 0){
        NSString *query_sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = ? and %@ = ?",
                               __k_paperitemrecorddao_tableName,
                               __k_paperitemrecord_fields_paperRecordCode,
                               __k_paperitemrecord_fields_itemCode];
        result = [_db intForQuery:query_sql,paperRecordCode,itemCode] > 0;
    }
    return result;
}
#pragma mark 根据试卷ID和试题ID加载数据
-(PaperItemRecord *)loadLastRecordWithPaperRecordCode:(NSString *)paperRecordCode{
    if(!_db || !paperRecordCode || ![_db tableExists:__k_paperitemrecorddao_tableName]) return nil;
    NSString *query_sql = [NSString stringWithFormat:@"select * from %@ where %@ = ? order by %@ desc limit 0,1",
                           __k_paperitemrecorddao_tableName,
                           __k_paperitemrecord_fields_paperRecordCode,
                           __k_paperitemrecord_fields_lastTime];
    PaperItemRecord *record;
    FMResultSet *rs = [_db executeQuery:query_sql,paperRecordCode];
    while ([rs next]) {
        record = [self createRecord:rs];
        break;
    }
    [rs close];
    return record;
}
//根据数据集合创建对象
-(PaperItemRecord *)createRecord:(FMResultSet *)rs{
    if(rs){
        PaperItemRecord *record = [[PaperItemRecord alloc] init];
        record.code = [rs stringForColumn:__k_paperitemrecord_fields_code];
        record.paperRecordCode = [rs stringForColumn:__k_paperitemrecord_fields_paperRecordCode];
        record.structureCode = [rs stringForColumn:__k_paperitemrecord_fields_structureCode];
        record.itemCode = [rs stringForColumn:__k_paperitemrecord_fields_itemCode];
        record.itemType = [NSNumber numberWithInt:[rs intForColumn:__k_paperitemrecord_fields_itemType]];
        record.itemContent = [rs stringForColumn:__k_paperitemrecord_fields_itemContent];
        record.answer = [rs stringForColumn:__k_paperitemrecord_fields_answer];
        record.status =[NSNumber numberWithInt:[rs intForColumn:__k_paperitemrecord_fields_status]];
        record.score = [NSNumber numberWithDouble:[rs doubleForColumn:__k_paperitemrecord_fields_score]];
        record.useTimes = [NSNumber numberWithLong:[rs longForColumn:__k_paperitemrecord_fields_useTimes]];
        
        NSString *strCreateTime = [rs stringForColumn:__k_paperitemrecord_fields_createTime];
        if(strCreateTime && strCreateTime.length > 0){
            record.createTime = [strCreateTime toDateWithFormat:nil];
        }
        NSString *strLastTime = [rs stringForColumn:__k_paperitemrecord_fields_lastTime];
        if(strLastTime && strLastTime.length > 0){
            record.lastTime = [strLastTime toDateWithFormat:nil];
        }
        record.sync = [NSNumber numberWithInt:[rs intForColumn:__k_paperitemrecord_fields_sync]];
        
        return record;
    }
    return nil;
}
#pragma mark 更新数据
-(BOOL)updateRecordWithItemRecord:(PaperItemRecord *__autoreleasing *)record{
    if(!_db || !(*record) || !(*record).paperRecordCode || (*record).paperRecordCode.length == 0) return NO;
    if(!(*record).itemCode || (*record).itemCode.length == 0 || ![_db tableExists:__k_paperitemrecorddao_tableName]) return NO;
    BOOL isExists = NO;
    NSString *query_sql;
    if((*record).code && (*record).code.length > 0){
        query_sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = ?",
                     __k_paperitemrecorddao_tableName, __k_paperitemrecord_fields_code];
        isExists = [_db intForQuery:query_sql,(*record).code] > 0;
    }
    (*record).sync = [NSNumber numberWithBool:NO];
    if(isExists){//更新数据
        (*record).lastTime = [NSDate currentLocalTime];
        NSString *update_sql = [NSString stringWithFormat:@"update %@ set %@ = ?,%@ = ?,%@ = ?,%@ = ?, %@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ? where %@ = ?",
                                __k_paperitemrecorddao_tableName,
                                
                                __k_paperitemrecord_fields_paperRecordCode,
                                __k_paperitemrecord_fields_structureCode,
                                __k_paperitemrecord_fields_itemCode,
                                __k_paperitemrecord_fields_itemType,
                                __k_paperitemrecord_fields_itemContent,
                                __k_paperitemrecord_fields_answer,
                                __k_paperitemrecord_fields_status,
                                __k_paperitemrecord_fields_score,
                                __k_paperitemrecord_fields_useTimes,
                                __k_paperitemrecord_fields_lastTime,
                                __k_paperitemrecord_fields_sync,
                                
                                __k_paperitemrecord_fields_code];
        return [_db executeUpdate:update_sql,
                (*record).paperRecordCode,
                (*record).structureCode,
                (*record).itemCode,
                (*record).itemType,
                (*record).itemContent,
                (*record).answer,
                (*record).status,
                (*record).score,
                (*record).useTimes,
                [NSString stringFromDate:(*record).lastTime],
                (*record).sync,
                (*record).code];
    }else{//新增数据
        (*record).code = [NSUUID UUID].UUIDString;
        (*record).createTime = (*record).lastTime = [NSDate currentLocalTime];
        NSString *insert_sql = [NSString stringWithFormat:@"insert into %@(%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@) values(?,?,?,?,?,?,?,?,?,?,?,?,?)",
                                __k_paperitemrecorddao_tableName,
                                
                                __k_paperitemrecord_fields_code,
                                __k_paperitemrecord_fields_paperRecordCode,
                                __k_paperitemrecord_fields_structureCode,
                                __k_paperitemrecord_fields_itemCode,
                                __k_paperitemrecord_fields_itemType,
                                __k_paperitemrecord_fields_itemContent,
                                __k_paperitemrecord_fields_answer,
                                __k_paperitemrecord_fields_status,
                                __k_paperitemrecord_fields_score,
                                __k_paperitemrecord_fields_useTimes,
                                __k_paperitemrecord_fields_createTime,
                                __k_paperitemrecord_fields_lastTime,
                                __k_paperitemrecord_fields_sync];
        return [_db executeUpdate:insert_sql,
                (*record).code,
                (*record).paperRecordCode,
                (*record).structureCode,
                (*record).itemCode,
                (*record).itemType,
                (*record).itemContent,
                (*record).answer,
                (*record).status,
                (*record).score,
                (*record).useTimes,
                [NSString stringFromDate:(*record).createTime],
                [NSString stringFromDate:(*record).lastTime],
                (*record).sync];
    }
}
#pragma mark 统计试卷记录下的试题数
-(NSNumber *)totalFinishItemsWithPaperRecordCode:(NSString *)paperRecordCode{
    NSNumber *totalFinish = [NSNumber numberWithInteger:0];
    if(_db && paperRecordCode && paperRecordCode.length > 0 && [_db tableExists:__k_paperitemrecorddao_tableName]){
        NSString *query_sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = ?",
                     __k_paperitemrecorddao_tableName, __k_paperitemrecord_fields_paperRecordCode];
        totalFinish = [NSNumber numberWithInt:[_db intForQuery:query_sql,paperRecordCode]];
    }
    return totalFinish;
}
#pragma mark 统计试卷记录下的试题得分
-(NSNumber *)totalAllItemScoreWithPaperRecordCode:(NSString *)paperRecordCode{
    NSNumber *totalScore = [NSNumber numberWithDouble:0];
    if(_db && paperRecordCode && paperRecordCode.length > 0 && [_db tableExists:__k_paperitemrecorddao_tableName]){
        NSString *query_sql = [NSString stringWithFormat:@"select sum(%@) from %@ where %@ = ? order by %@ desc",
                               __k_paperitemrecord_fields_score,
                               __k_paperitemrecorddao_tableName,
                               __k_paperitemrecord_fields_paperRecordCode,
                               __k_paperitemrecord_fields_lastTime];
        
        totalScore = [NSNumber numberWithDouble:[_db doubleForQuery:query_sql,paperRecordCode]];
    }
    return totalScore;
}
#pragma mark 统计试卷记录下的试题用时
-(NSNumber *)totalAllUseTimesWithPaperRecordCode:(NSString *)paperRecordCode{
    NSNumber *useTimes = [NSNumber numberWithLong:0];
    if(_db && paperRecordCode && paperRecordCode.length > 0 && [_db tableExists:__k_paperitemrecorddao_tableName]){
        NSString *query_sql = [NSString stringWithFormat:@"select sum(%@) from %@ where %@ = ? order by %@ desc",
                               __k_paperitemrecord_fields_useTimes,
                              __k_paperitemrecorddao_tableName,
                              __k_paperitemrecord_fields_paperRecordCode,
                              __k_paperitemrecord_fields_lastTime];
        useTimes = [NSNumber numberWithLong:[_db longForQuery:query_sql,paperRecordCode]];
    }
    return useTimes;
}
#pragma mark 统计做对的试题数量
-(NSNumber *)totalAllRightsWithPaperRecordCode:(NSString *)paperRecordCode{
    NSNumber *rights = [NSNumber numberWithInt:0];
    if(_db && paperRecordCode && paperRecordCode.length > 0 && [_db tableExists:__k_paperitemrecorddao_tableName]){
        NSString *query_sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = ? and %@ = ?",
                               __k_paperitemrecorddao_tableName,
                               __k_paperitemrecord_fields_paperRecordCode,
                               __k_paperitemrecord_fields_status];
        rights = [NSNumber numberWithLong:[_db longForQuery:query_sql,paperRecordCode,[NSNumber numberWithBool:YES]]];
    }
    return rights;
}

#pragma mark 统计科目下的错题统计
-(NSInteger)totalWrongItemsWithSubjectCode:(NSString *)subjectCode{
    if(subjectCode && subjectCode.length > 0 && _db && [_db tableExists:__k_paperitemrecorddao_tableName]){
        NSMutableString *query_sql = [NSMutableString string];
        [query_sql appendFormat:@"select count(a.%@) ",__k_paperitemrecord_fields_code];
        [query_sql appendFormat:@"from %@ a ",__k_paperitemrecorddao_tableName];
        [query_sql appendFormat:@"left outer join %@ b ",__k_paperrecorddao_tableName];
        [query_sql appendFormat:@"on b.%@ = a.%@ ",__k_paperrecord_fields_code, __k_paperitemrecord_fields_paperRecordCode];
        [query_sql appendFormat:@"left outer join %@ c ",__k_paperdatadao_tableName];
        [query_sql appendFormat:@"on c.%@ = b.%@ ", __k_paperdata_fields_code, __k_paperrecord_fields_paperCode];
        [query_sql appendFormat:@"where a.%@ = ? and c.%@ = ? ",__k_paperitemrecord_fields_status, __k_paperdata_fields_subjectCode];
        
        return [_db intForQuery:query_sql,[NSNumber numberWithBool:NO],subjectCode];
    }
    return 0;
}
#pragma mark 统计科目题型下的错题统计
-(NSInteger)totalWrongItemsWithSubjectCode:(NSString *)subjectCode AtItemType:(PaperItemType)itemType{
    if(subjectCode && subjectCode.length > 0 && _db && [_db tableExists:__k_paperitemrecorddao_tableName]){
        NSMutableString *query_sql = [NSMutableString string];
        [query_sql appendFormat:@"select count(a.%@) ",__k_paperitemrecord_fields_code];
        [query_sql appendFormat:@"from %@ a ",__k_paperitemrecorddao_tableName];
        
        [query_sql appendFormat:@"left outer join %@ b ",__k_paperrecorddao_tableName];
        [query_sql appendFormat:@"on b.%@ = a.%@ ",__k_paperrecord_fields_code, __k_paperitemrecord_fields_paperRecordCode];
        
        [query_sql appendFormat:@"left outer join %@ c ",__k_paperdatadao_tableName];
        [query_sql appendFormat:@"on c.%@ = b.%@ ", __k_paperdata_fields_code, __k_paperrecord_fields_paperCode];
        
        [query_sql appendFormat:@"where a.%@ = ? and a.%@ = ? and c.%@ = ? ",__k_paperitemrecord_fields_status,
            __k_paperitemrecord_fields_itemType,__k_paperdata_fields_subjectCode];
        
        return [_db intForQuery:query_sql,[NSNumber numberWithBool:NO],[NSNumber numberWithInt:(int)itemType],subjectCode];
    }
    return 0;
}
#pragma mark 加载指定索引的错题
-(PaperItemRecord*)loadWrongItemWithSubjectCode:(NSString *)subjectCode AtOrder:(NSInteger)order{
    if(subjectCode && subjectCode.length > 0 && _db && [_db tableExists:__k_paperitemrecorddao_tableName]){
        if(order < 0) order = 0;
        NSMutableString *query_sql = [NSMutableString string];
        [query_sql appendString:@"select a.* "];
        [query_sql appendFormat:@"from %@ a ",__k_paperitemrecorddao_tableName];
        
        [query_sql appendFormat:@"left outer join %@ b ",__k_paperrecorddao_tableName];
        [query_sql appendFormat:@"on b.%@ = a.%@ ",__k_paperrecord_fields_code, __k_paperitemrecord_fields_paperRecordCode];
        
        [query_sql appendFormat:@"left outer join %@ c ",__k_paperdatadao_tableName];
        [query_sql appendFormat:@"on c.%@ = b.%@ ", __k_paperdata_fields_code, __k_paperrecord_fields_paperCode];
        
        [query_sql appendFormat:@"where a.%@ = ? and c.%@ = ? ",__k_paperitemrecord_fields_status, __k_paperdata_fields_subjectCode];
        [query_sql appendFormat:@"order by a.%@ ",__k_paperitemrecord_fields_itemType];
        [query_sql appendFormat:@"limit %ld,1 ",(long)order];
        
        PaperItemRecord *data;
        FMResultSet *rs = [_db executeQuery:query_sql,[NSNumber numberWithBool:NO],subjectCode];
        while ([rs next]) {
            data = [self createRecord:rs];
            break;
        }
        [rs close];
        return data;
    }
    return nil;
}
#pragma mark 加载需要同步的数据集合
-(NSArray *)loadSyncRecords{
    if(!_db || ![_db tableExists:__k_paperitemrecorddao_tableName]) return nil;
    NSString *query_sql = [NSString stringWithFormat:@"select * from %@ where %@ = ? order by %@",
                           __k_paperitemrecorddao_tableName,__k_paperitemrecord_fields_sync,__k_paperitemrecord_fields_lastTime];
    NSMutableArray *arrays = [NSMutableArray array];
    FMResultSet *rs = [_db executeQuery:query_sql,[NSNumber numberWithBool:NO]];
    while ([rs next]) {
        PaperItemRecord *record = [self createRecord:rs];
        if(record && record.code && record.code.length > 0){
            [arrays addObject:[record serializeJSON]];
        }
    }
    [rs close];
    return arrays;
}
#pragma mark 更新同步标示
-(void)updateSyncFlagWithIgnoreRecords:(NSArray *)ignores{
    if(!_db || ![_db tableExists:__k_paperitemrecorddao_tableName])return;
    NSString *update_sql;
    if(ignores && ignores.count > 0){
        NSMutableString *ignoreRecords = [NSMutableString string];
        for(NSString *str in ignores){
            if(str && str.length > 0){
                if(ignoreRecords.length > 0){
                    [ignoreRecords appendString:@","];
                }
                [ignoreRecords appendFormat:@"'%@'",str];
            }
        }
        update_sql = [NSString stringWithFormat:@"update %@ set %@ = ? where %@ = ? and %@ not in (%@)",
                      __k_paperitemrecorddao_tableName,
                      __k_paperitemrecord_fields_sync,
                      __k_paperitemrecord_fields_sync,
                      __k_paperitemrecord_fields_code,
                      ignoreRecords];
    }else{
        update_sql = [NSString stringWithFormat:@"update %@ set %@ = ? where %@ = ?",
                      __k_paperitemrecorddao_tableName,
                      __k_paperitemrecord_fields_sync,
                      __k_paperitemrecord_fields_sync];
    }
    if(update_sql){
        [_db executeUpdate:update_sql,[NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO]];
    }
}
#pragma mark 根据试卷记录ID删除试题记录
-(BOOL)deleteRecordWithPaperRecordCode:(NSString *)paperRecordCode{
    if(!paperRecordCode || paperRecordCode.length == 0 || !_db || ![_db tableExists:__k_paperitemrecorddao_tableName]) return NO;
    NSString *delete_sql = [NSString stringWithFormat:@"delete from %@ where %@ = ?",
                            __k_paperitemrecorddao_tableName,__k_paperitemrecord_fields_paperRecordCode];
    return [_db executeUpdate:delete_sql,paperRecordCode];
}
@end
