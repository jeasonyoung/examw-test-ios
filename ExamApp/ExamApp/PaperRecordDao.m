//
//  PaperRecordDao.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperRecordDao.h"
#import "PaperRecord.h"
#import <FMDB/FMDB.h>
#import "NSString+Date.h"
#import "NSDate+TimeZone.h"

#define __k_paperrecorddao_tableName @"tbl_paperRecords"
#define __k_paperrecorddao_dtFormatter @"yyyy-MM-dd HH:mm:ss"//
//试卷记录数据操作成员变量
@interface PaperRecordDao (){
    FMDatabase *_db;
}
@end
//试卷记录数据操作实现类
@implementation PaperRecordDao
#pragma mark 初始化
-(instancetype)initWithDb:(FMDatabase *)db{
    if(self = [super init]){
        _db = db;
    }
    return self;
}
#pragma mark 加载试卷记录
-(PaperRecord *)loadPaperRecord:(NSString *)recordCode{
    if(!_db || !recordCode || recordCode.length == 0 || ![_db tableExists:__k_paperrecorddao_tableName]) return nil;
    NSString *query_sql = [NSString stringWithFormat:@"select * from %@ where %@ = ? limit 0,1",
                           __k_paperrecorddao_tableName,__k_paperrecord_fields_code];
    PaperRecord *data;
    FMResultSet *rs = [_db executeQuery:query_sql,recordCode];
    while ([rs next]) {
        data = [self createPaperRecord:rs];
        break;
    }
    [rs close];
    return data;
}
//创建对象
-(PaperRecord *)createPaperRecord:(FMResultSet *)rs{
    if(!rs)return nil;
    PaperRecord *data = [[PaperRecord alloc] init];
    data = [[PaperRecord alloc] init];
    data.code = [rs stringForColumn:__k_paperrecord_fields_code];
    data.paperCode = [rs stringForColumn:__k_paperrecord_fields_paperCode];
    data.status = [rs intForColumn:__k_paperrecord_fields_status];
    data.score = [NSNumber numberWithDouble:[rs doubleForColumn:__k_paperrecord_fields_score]];
    data.rights = [rs intForColumn:__k_paperrecord_fields_rights];
    data.useTimes = [rs intForColumn:__k_paperrecord_fields_useTimes];
    NSString *strCreateTime = [rs stringForColumn:__k_paperrecord_fields_createTime];
    if(strCreateTime && strCreateTime.length > 0){
        data.createTime = [strCreateTime toDateWithFormat:__k_paperrecorddao_dtFormatter];
    }
    NSString *strLastTime = [rs stringForColumn:__k_paperrecord_fields_lastTime];
    if(strLastTime && strLastTime.length > 0){
        data.lastTime = [strLastTime toDateWithFormat:__k_paperrecorddao_dtFormatter];
    }
    data.sync = [rs intForColumn:__k_paperrecord_fields_sync];
    return data;
}
#pragma mark 加载试卷的最新记录
-(PaperRecord *)loadLastPaperRecord:(NSString *)paperCode{
    if(!_db || !paperCode || paperCode.length == 0 || ![_db tableExists:__k_paperrecorddao_tableName])return nil;
    NSString *query_sql = [NSString stringWithFormat:@"select * from %@ where %@ = ? and %@ = ? order by %@ desc limit 0,1",
                           __k_paperrecorddao_tableName,
                           __k_paperrecord_fields_paperCode,
                           __k_paperrecord_fields_status,
                           __k_paperrecord_fields_lastTime];
    PaperRecord *data;
    FMResultSet *rs = [_db executeQuery:query_sql,paperCode,[NSNumber numberWithBool:NO]];
    while ([rs next]) {
        data = [self createPaperRecord:rs];
        break;
    }
    [rs close];
    return data;
}
#pragma mark 更新数据
-(BOOL)updateRecord:(PaperRecord *__autoreleasing *)record{
    if(_db && [_db tableExists:__k_paperrecorddao_tableName] && (*record)){
        BOOL isExits = NO;
        NSString *query_sql;
        if((*record).code && (*record).code.length > 0){//用记录ID检查是否存在
            query_sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = ?",
                         __k_paperrecorddao_tableName,__k_paperrecord_fields_code];
            isExits = [_db intForQuery:query_sql,(*record).code] > 0;
        }else if((*record).paperCode && (*record).paperCode.length > 0){//用试卷ID检查是否存在未完成的试卷
            query_sql = [NSString stringWithFormat:@"select %@ from %@ where %@ = ? and %@ = ? order by %@ desc limit 0,1",
                         __k_paperrecord_fields_code,__k_paperrecorddao_tableName,
                         __k_paperrecord_fields_paperCode,__k_paperrecord_fields_status,__k_paperrecord_fields_lastTime];
            NSString *code = [_db stringForQuery:query_sql,(*record).paperCode,[NSNumber numberWithBool:NO]];
            if(code && code.length > 0){
                isExits = YES;
                (*record).code = code;
            }
        }
        (*record).sync = [NSNumber numberWithBool:NO].integerValue;
        if(!isExits){//新增
            (*record).code = [NSUUID UUID].UUIDString;
            (*record).createTime = (*record).lastTime = [[NSDate date] localTime];
            NSString *insert_sql = [NSString stringWithFormat:@"insert into %@(%@,%@,%@,%@,%@,%@,%@,%@,%@) values(?, ?, ?, ?, ?, ?, ?, ?, ?)",
                                    __k_paperrecorddao_tableName,
                                    
                                    __k_paperrecord_fields_code,
                                    __k_paperrecord_fields_paperCode,
                                    __k_paperrecord_fields_status,
                                    __k_paperrecord_fields_score,
                                    __k_paperrecord_fields_rights,
                                    __k_paperrecord_fields_useTimes,
                                    __k_paperrecord_fields_createTime,
                                    __k_paperrecord_fields_lastTime,
                                    __k_paperrecord_fields_sync];
            return [_db executeUpdate:insert_sql,(*record).code,(*record).paperCode,(*record).status,(*record).score,(*record).rights,(*record).useTimes,
                    (*record).createTime,(*record).lastTime,(*record).sync];
        }else{//更新
            (*record).lastTime = [[NSDate date] localTime];
            NSString *update_sql = [NSString stringWithFormat:@"update %@ set %@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ? where %@ = ?",
                                    __k_paperrecorddao_tableName,
                                    
                                    __k_paperrecord_fields_paperCode,
                                    __k_paperrecord_fields_status,
                                    __k_paperrecord_fields_score,
                                    __k_paperrecord_fields_rights,
                                    __k_paperrecord_fields_useTimes,
                                    //__k_paperrecord_fields_createTime,
                                    __k_paperrecord_fields_lastTime,
                                    __k_paperrecord_fields_sync,
                                    
                                    __k_paperrecord_fields_code];
            return [_db executeUpdate:update_sql,(*record).paperCode,(*record).status,(*record).score,(*record).rights,(*record).useTimes,(*record).lastTime,(*record).sync,(*record).code];
        }
    }
    return NO;
}
#pragma mark 加载需要同步的数据
-(NSArray *)loadSyncRecords{
    if(!_db || ![_db tableExists:__k_paperrecorddao_tableName])return nil;
    NSString *query_sql = [NSString stringWithFormat:@"select * from %@ where %@ = ? order by %@",
                           __k_paperrecorddao_tableName,__k_paperrecord_fields_sync,__k_paperrecord_fields_lastTime];
    NSMutableArray *arrays = [NSMutableArray array];
    FMResultSet *rs = [_db executeQuery:query_sql,[NSNumber numberWithBool:NO]];
    while ([rs next]) {
        PaperRecord *data = [self createPaperRecord:rs];
        if(data && data.code && data.code.length > 0){
            [arrays addObject:[data serializeJSON]];
        }
    }
    [rs close];
    return arrays;
}
#pragma mark 更新同步标示
-(void)updateSyncFlagWithIgnoreRecords:(NSArray *)ignores{
    if(!_db || ![_db tableExists:__k_paperrecorddao_tableName]) return;
    NSString *update_sql;
    if(ignores && ignores.count > 0){
        NSMutableString *ignore = [NSMutableString string];
        for(NSString *str in ignores){
            if(str && str.length > 0){
                if(ignore.length > 0){
                    [ignore appendString:@","];
                }
                [ignore appendFormat:@"'%@'",str];
            }
        }
        update_sql = [NSString stringWithFormat:@"update %@ set %@ = ? where %@ = ? and %@ not in(%@)",
                      __k_paperrecorddao_tableName,__k_paperrecord_fields_sync,__k_paperrecord_fields_sync,
                      __k_paperrecord_fields_code,ignore];
    }else{
        update_sql = [NSString stringWithFormat:@"update %@ set %@ = ? where %@ = ?",
                      __k_paperrecorddao_tableName,__k_paperrecord_fields_sync,__k_paperrecord_fields_sync];
    }
    if(update_sql){
        [_db executeUpdate:update_sql,[NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO]];
    }
}
@end
