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

#define __k_paperitemrecorddao_tableName  @"tbl_itemRecords"//数据库表名称
#define __k_paperitemrecorddao_dtFormatter @"yyyy-MM-dd HH:mm:ss"
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
-(PaperItemRecord *)loadItemRecord:(NSString *)itemRecordCode{
    if(!_db || !itemRecordCode || itemRecordCode.length == 0 || ![_db tableExists:__k_paperitemrecorddao_tableName]) return nil;
    NSString *query_sql = [NSString stringWithFormat:@"select * from %@ where %@ = ? limit 0,1",
                           __k_paperitemrecorddao_tableName,__k_paperitemrecord_fields_code];
    PaperItemRecord *record;
    FMResultSet *rs = [_db executeQuery:query_sql,itemRecordCode];
    while ([rs next]) {
        record = [self createRecord:rs];
        break;
    }
    [rs close];
    return record;
}
#pragma mark 根据试卷ID和试题ID加载数据
-(PaperItemRecord *)loadLastItemRecordWithPaperRecordCode:(NSString *)paperRecordCode PaperItemCode:(NSString *)itemCode{
    if(!_db || !paperRecordCode || !itemCode || ![_db tableExists:__k_paperitemrecorddao_tableName]) return nil;
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
//根据数据集合创建对象
-(PaperItemRecord *)createRecord:(FMResultSet *)rs{
    if(rs){
        PaperItemRecord *record = [[PaperItemRecord alloc] init];
        record.code = [rs stringForColumn:__k_paperitemrecord_fields_code];
        record.paperRecordCode = [rs stringForColumn:__k_paperitemrecord_fields_paperRecordCode];
        record.structureCode = [rs stringForColumn:__k_paperitemrecord_fields_structureCode];
        record.itemCode = [rs stringForColumn:__k_paperitemrecord_fields_itemCode];
        record.itemContent = [rs stringForColumn:__k_paperitemrecord_fields_itemContent];
        record.answer = [rs stringForColumn:__k_paperitemrecord_fields_answer];
        record.status = [rs intForColumn:__k_paperitemrecord_fields_status];
        record.score = [NSNumber numberWithDouble:[rs doubleForColumn:__k_paperitemrecord_fields_score]];
        record.useTimes = [rs intForColumn:__k_paperitemrecord_fields_useTimes];
        
        NSString *strCreateTime = [rs stringForColumn:__k_paperitemrecord_fields_createTime];
        if(strCreateTime && strCreateTime.length > 0){
            record.createTime = [strCreateTime toDateWithFormat:__k_paperitemrecorddao_dtFormatter];
        }
        NSString *strLastTime = [rs stringForColumn:__k_paperitemrecord_fields_lastTime];
        if(strLastTime && strLastTime.length > 0){
            record.lastTime = [strLastTime toDateWithFormat:__k_paperitemrecorddao_dtFormatter];
        }
        record.sync = [rs intForColumn:__k_paperitemrecord_fields_sync];
        
        return record;
    }
    return nil;
}
#pragma mark 更新数据
-(BOOL)updateRecord:(PaperItemRecord *__autoreleasing *)record{
    if(!_db || !(*record) || !(*record).paperRecordCode || !(*record).paperRecordCode.length == 0) return NO;
    if(!(*record).itemCode || (*record).itemCode.length == 0 || ![_db tableExists:__k_paperitemrecorddao_tableName]) return NO;
    BOOL isExists = NO;
    NSString *query_sql;
    if((*record).code && (*record).code.length > 0){
        query_sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = ?",
                     __k_paperitemrecorddao_tableName, __k_paperitemrecord_fields_code];
        isExists = [_db intForQuery:query_sql,(*record).code] > 0;
    }else{
        query_sql = [NSString stringWithFormat:@"select %@ from %@ where %@ = ? and %@ = ? order by %@ desc limit 0,1",
                     __k_paperitemrecord_fields_code,
                     __k_paperitemrecorddao_tableName,
                     __k_paperitemrecord_fields_paperRecordCode,
                     __k_paperitemrecord_fields_itemCode,
                     __k_paperitemrecord_fields_lastTime];
        NSString *recordCode = [_db stringForQuery:query_sql,(*record).paperRecordCode,(*record).itemCode];
        if(recordCode && recordCode.length > 0){
            (*record).code = recordCode;
            isExists = YES;
        }
    }
    (*record).sync = [NSNumber numberWithBool:NO].integerValue;
    if(isExists){//更新数据
        (*record).lastTime = [[NSDate date] localTime];
        NSString *update_sql = [NSString stringWithFormat:@"update %@ set %@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ? where %@ = ?",
                                __k_paperitemrecorddao_tableName,
                                
                                __k_paperitemrecord_fields_paperRecordCode,
                                __k_paperitemrecord_fields_structureCode,
                                __k_paperitemrecord_fields_itemCode,
                                __k_paperitemrecord_fields_itemContent,
                                __k_paperitemrecord_fields_answer,
                                __k_paperitemrecord_fields_status,
                                __k_paperitemrecord_fields_score,
                                __k_paperitemrecord_fields_useTimes,
                                __k_paperitemrecord_fields_lastTime,
                                __k_paperitemrecord_fields_sync,
                                
                                __k_paperitemrecord_fields_code];
        return [_db executeUpdate:update_sql,(*record).paperRecordCode,(*record).structureCode,(*record).itemCode,(*record).itemContent,
                (*record).answer,(*record).status,(*record).score,(*record).useTimes,(*record).lastTime,(*record).sync,(*record).code];
    }else{//新增数据
        (*record).code = [NSUUID UUID].UUIDString;
        (*record).createTime = (*record).lastTime = [[NSDate date] localTime];
        NSString *insert_sql = [NSString stringWithFormat:@"insert into %@(%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@) values(?,?,?,?,?,?,?,?,?,?,?,?)",
                                __k_paperitemrecorddao_tableName,
                                
                                __k_paperitemrecord_fields_code,
                                __k_paperitemrecord_fields_paperRecordCode,
                                __k_paperitemrecord_fields_structureCode,
                                __k_paperitemrecord_fields_itemCode,
                                __k_paperitemrecord_fields_itemContent,
                                __k_paperitemrecord_fields_answer,
                                __k_paperitemrecord_fields_status,
                                __k_paperitemrecord_fields_score,
                                __k_paperitemrecord_fields_useTimes,
                                __k_paperitemrecord_fields_createTime,
                                __k_paperitemrecord_fields_lastTime,
                                __k_paperitemrecord_fields_sync];
        return [_db executeUpdate:insert_sql,(*record).code,(*record).paperRecordCode,(*record).structureCode,(*record).itemCode,(*record).itemContent,
                (*record).answer,(*record).status,(*record).score,(*record).useTimes,(*record).createTime,(*record).lastTime,(*record).sync];
    }
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
@end
