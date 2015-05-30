//
//  PaperService.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/24.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperService.h"
#import "AppConstants.h"

#import "DaoHelpers.h"
#import "PaperInfoModel.h"
#import "PaperModel.h"
#import "PaperRecordModel.h"

#import "PaperUtils.h"

#define __kPaperService_pageOfRows _kAPP_DEFAULT_PAGEROWS//分页
//试卷服务接口成员变量
@interface PaperService (){
    FMDatabaseQueue *_dbQueue;
    //DaoHelpers *_daoHelpers;
}
@end
//试卷服务接口实现
@implementation PaperService

#pragma mark 重构初始化
-(instancetype)init{
    if(self = [super init]){
        _pageOfRows = __kPaperService_pageOfRows;
        _dbQueue = [[[DaoHelpers alloc] init] createDatabaseQueue];
        if(!_dbQueue){
            NSLog(@"创建数据操作失败!");
        }
        _pageOfRows = __kPaperService_pageOfRows;
    }
    return self;
}

#pragma mark 按试卷类型分页查找试卷信息数据
-(NSArray *)findPapersInfoWithPaperType:(NSUInteger)paperType andPageIndex:(NSUInteger)pageIndex{
    NSLog(@"按试卷类型[%d]分页[%d]查找试卷数据...", (int)paperType, (int)pageIndex);
    if(!_dbQueue){
        NSLog(@"创建数据操作失败!");
        return nil;
    }
    static NSString *querySubjectNameSql = @"SELECT name FROM tbl_subjects WHERE code = ? limit 0,1";
    //拼接SQL
    NSMutableString *query_sql = [NSMutableString string];
    [query_sql appendString:@" SELECT id, title, total, createTime, subjectCode FROM tbl_papers "];
    [query_sql appendFormat:@" WHERE type = ? order by createTime desc limit %d,%d;",
     (int)(pageIndex * __kPaperService_pageOfRows), (int)__kPaperService_pageOfRows];
    
    __block NSMutableArray *arrays = [NSMutableArray arrayWithCapacity:__kPaperService_pageOfRows];
    //查询数据
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSLog(@"exec-sql:%@", query_sql);
        FMResultSet *rs = [db executeQuery:query_sql, [NSNumber numberWithInteger:paperType]];
        while ([rs next]) {
            //科目
            NSString *subjectCode = [rs stringForColumn:@"subjectCode"], *subjectName = @"";
            if(subjectCode && subjectCode.length > 0){
                subjectName = [db stringForQuery:querySubjectNameSql, subjectCode];
            }
            //创建试卷信息模型
            PaperInfoModel *model = [[PaperInfoModel alloc] init];
            model.Id = [rs stringForColumn:@"id"];
            model.name = [rs stringForColumn:@"title"];
            model.total = [rs intForColumn:@"total"];
            model.subject = subjectName;
            model.createTime = [rs stringForColumn:@"createTime"];
            //添加到集合
            [arrays addObject:model];
        }
        [rs close];
    }];
    //返回数据集合
    return (arrays && arrays.count > 0) ? [arrays copy] : nil;
}

#pragma 加载试卷数据
-(PaperModel *)loadPaperModelWithPaperId:(NSString *)paperId{
    if(!paperId || paperId.length == 0)return nil;
    NSLog(@"加载试卷[%@]数据...", paperId);
    static NSMutableDictionary *papersCache;
    if(!papersCache){
        NSLog(@"创建试卷缓存字典...");
        papersCache = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    PaperModel *paperModel = [papersCache objectForKey:paperId];
    if(!paperModel){
        if(!_dbQueue){
            NSLog(@"创建数据操作失败!");
            return nil;
        }
        __block NSString *contentHex = nil;
        //查询数据
        [_dbQueue inDatabase:^(FMDatabase *db) {
            //sql
            static NSString *query_sql = @"SELECT content FROM tbl_papers WHERE id = ? limit 0,1";
            contentHex = [db stringForQuery:query_sql, paperId];
        }];
        if(!contentHex || contentHex.length == 0) return nil;
        //解密数据
        NSLog(@"开始解密试卷数据...");
        NSString *json = [PaperUtils decryptPaperContentWithHex:contentHex andPassword:paperId];
        if(!json || json.length == 0){
            NSLog(@"试卷解密后无法解析...!");
            return nil;
        }
        //解析
        NSLog(@"开始解析JSON数据为试卷对象...");
        paperModel = [[PaperModel alloc] initWithJSON:json];
        if(paperModel){
            NSLog(@"加入缓存...");
            [papersCache setObject:paperModel forKey:paperId];
        }
    }
    return paperModel;
}

#pragma mark 加载最新的试卷记录
-(PaperRecordModel *)loadNewsRecordWithPaperId:(NSString *)paperId{
    if(!paperId || paperId.length == 0)return nil;
    NSLog(@"加载最新的试卷[%@]记录...", paperId);
    if(!_dbQueue){
        NSLog(@"创建数据操作失败!");
        return nil;
    }
    __block PaperRecordModel *recordModel = nil;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        static NSString *query_sql = @"SELECT id,status,score,rights,useTimes FROM tbl_paperRecords WHERE paperId = ? ORDER BY lastTime DESC,createTime DESC limit 0,1";
        FMResultSet *rs = [db executeQuery:query_sql, paperId];
        while ([rs next]) {
            recordModel = [[PaperRecordModel alloc] init];
            recordModel.Id = [rs stringForColumn:@"id"];
            recordModel.status = [rs boolForColumn:@"status"];
            recordModel.score = [NSNumber numberWithDouble:[rs doubleForColumn:@"score"]];
            recordModel.rights = [rs intForColumn:@"rights"];
            recordModel.useTimes = [rs longForColumn:@"useTimes"];
            recordModel.paperId = paperId;
            break;
        }
        [rs close];
    }];
    return recordModel;
}

#pragma mark 按试卷记录ID加载试卷记录
-(PaperRecordModel *)loadRecordWithPaperRecordId:(NSString *)paperRecordId{
    if(!paperRecordId || paperRecordId.length == 0) return nil;
    NSLog(@"按试卷记录ID[%@]加载试卷记录...", paperRecordId);
    if(!_dbQueue){
        NSLog(@"创建数据操作失败!");
        return nil;
    }
    __block PaperRecordModel *recordModel = nil;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        static NSString *query_sql = @"SELECT id,paperId,status,score,rights,useTimes FROM tbl_paperRecords WHERE id = ? limit 0,1";
        FMResultSet *rs = [db executeQuery:query_sql, paperRecordId];
        while ([rs next]) {
            recordModel = [[PaperRecordModel alloc] init];
            recordModel.Id = [rs stringForColumn:@"id"];
            recordModel.paperId = [rs stringForColumn:@"paperId"];
            recordModel.status = [rs boolForColumn:@"status"];
            recordModel.score = [NSNumber numberWithDouble:[rs doubleForColumn:@"score"]];
            recordModel.rights = [rs intForColumn:@"rights"];
            recordModel.useTimes = [rs intForColumn:@"useTimes"];
            break;
        }
    }];
    return recordModel;
}

#pragma mark 更新试卷记录
-(void)addPaperRecord:(PaperRecordModel *)record{
    if(!record)return;
    NSLog(@"准备更新试卷记录数据...");
    if(!record.paperId || record.paperId.length == 0){
        NSLog(@"关联的试卷ID不能为空!");
        return;
    }
    if(!_dbQueue){
        NSLog(@"创建数据操作失败!");
        return;
    }
    //查找sql
    static NSString *query_sql = @"SELECT count(*) FROM tbl_paperRecords WHERE id = ?";
    //新增sql
    static NSString *insert_sql = @"INSERT INTO tbl_paperRecords(id,paperId,status,score,rights,useTimes) values(?,?,?,?,?,?)";
    //更新sql
    static NSString *update_sql = @"UPDATE tbl_paperRecords SET lastTime=? WHERE id=?";
    
    //执行数据
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            BOOL isAdded = (!record.Id || record.Id.length == 0);
            if(!isAdded){
                isAdded = !([db intForQuery:query_sql, record.Id] > 0);
            }
            if(isAdded){//新增
                if(!record.Id || record.Id.length == 0){
                    record.Id = [[NSUUID UUID] UUIDString];
                }
                //执行SQL
                [db executeUpdate:insert_sql,record.Id,record.paperId,[NSNumber numberWithBool:NO],@0,@0,@0];
            }else{//更新
                //执行SQL
                [db executeUpdate:update_sql,[NSDate date],record.Id];
            }
        }
        @catch (NSException *exception) {
            *rollback = YES;
            NSLog(@"执行SQL脚本异常:%@", exception);
        }
    }];
}

#pragma mark 试题是否被收藏
-(BOOL)exitFavoriteWithItemId:(NSString *)itemId{
    __block BOOL result = NO;
    if(itemId && itemId.length > 0){
        if(!_dbQueue){
            NSLog(@"创建数据操作失败!");
            return result;
        }
        static NSString *query_sql = @"SELECT count(*) FROM tbl_favorites WHERE itemId = ?";
        [_dbQueue inDatabase:^(FMDatabase *db) {
            //执行脚本
            NSLog(@"exec-sql:%@", query_sql);
            result = [db intForQuery:query_sql, itemId] > 0;
        }];
    }
    return result;
}
@end
