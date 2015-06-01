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
#import "PaperItemModel.h"
#import "PaperRecordModel.h"
#import "PaperResultModel.h"

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
                NSDateFormatter *dtFormat = [[NSDateFormatter alloc] init];
                [dtFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *lastTime = [dtFormat stringFromDate:[NSDate date]];
                //执行SQL
                [db executeUpdate:update_sql,lastTime,record.Id];
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

#pragma mark 试题是否在记录中存在(0-不存在,1-做对,2-做错)
-(NSUInteger)exitRecordWithPaperRecordId:(NSString *)paperRecordId itemModel:(PaperItemModel *)model{
    __block NSUInteger result = 0;
    if(_dbQueue && paperRecordId && paperRecordId.length > 0 && model){
        NSString *itemId = [NSString stringWithFormat:@"%@$%d", model.itemId, (int)model.index];
        NSLog(@"查找试题[%@]在记录[%@]中存在的状态...", itemId, paperRecordId);
        static NSString *query_sql = @"SELECT status FROM tbl_itemRecords WHERE paperRecordId = ? and itemId = ? limit 0,1";
        [_dbQueue inDatabase:^(FMDatabase *db) {
            NSLog(@"exec-sql:%@", query_sql);
            FMResultSet *rs = [db executeQuery:query_sql, paperRecordId,itemId];
            while ([rs next]) {
                BOOL status = [rs boolForColumn:@"status"];
                result = (status ? 1 : 2);
                break;
            }
            [rs close];
        }];
    }
    return result;
}

#pragma mark 加载最新试题记录
-(NSString *)loadNewsItemIndexWithPaperRecordId:(NSString *)recordId{
    __block NSString *itemIndex = nil;
    if(_dbQueue && recordId && recordId.length > 0){
        NSLog(@"加载最新试卷[%@]的试题记录...", recordId);
        static NSString *query_sql = @"SELECT itemId FROM tbl_itemRecords WHERE paperRecordId = ? ORDER BY lastTime desc,createTime desc limit 0,1";
        [_dbQueue inDatabase:^(FMDatabase *db) {
            NSLog(@"exec-sql:%@",query_sql);
            itemIndex = [db stringForQuery:query_sql, recordId];
        }];
    }
    return itemIndex;
}

#pragma mark 交卷处理
-(void)submitWithPaperRecordId:(NSString *)paperRecordId{
    if(_dbQueue && paperRecordId && paperRecordId.length > 0){
        NSLog(@"开始交卷[paperReacordId=%@]处理...", paperRecordId);
        //统计得分/用时/正确
        static NSString *total_score_sql = @"SELECT SUM(score) AS score,SUM(useTimes) AS useTimes,SUM(status) AS rights FROM tbl_itemRecords WHERE paperRecordId = ?";
        //更新试卷记录
        static NSString *update_sql = @"UPDATE tbl_paperRecords SET status = 1,score = ?,useTimes = ?,rights = ?,lastTime = ? WHERE id = ?";
        [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            @try {
                //统计得分
                NSLog(@"统计得分/用时-exec-sql:%@", total_score_sql);
                double totalScore = 0, totalUseTimes = 0, totalRights = 0;
                FMResultSet *rs = [db executeQuery:total_score_sql, paperRecordId];
                while ([rs next]) {
                    //得分
                    totalScore = [rs doubleForColumn:@"score"];
                    //用时
                    totalUseTimes = [rs doubleForColumn:@"useTimes"];
                    //做对数量
                    totalRights = [rs doubleForColumn:@"rights"];
                    break;
                };
                [rs close];
                //更新试卷记录
                NSLog(@"exec-sql:%@", update_sql);
                
                NSDateFormatter *dtFormat = [[NSDateFormatter alloc] init];
                [dtFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *lastTime = [dtFormat stringFromDate:[NSDate date]];
                [db executeUpdate:update_sql,[NSNumber numberWithDouble:totalScore],[NSNumber numberWithDouble:totalUseTimes],[NSNumber numberWithDouble:totalRights], lastTime, paperRecordId];
            }
            @catch (NSException *exception) {
                *rollback = YES;
                NSLog(@"交卷处理[paperRecordId=%@]发生异常:%@", paperRecordId, exception);
            }
        }];
    }
}

#pragma mark 加载考试结果数据
-(PaperResultModel *)loadPaperResultWithPaperRecordId:(NSString *)paperRecordId{
    __block PaperResultModel *resultModel;
    if(_dbQueue && paperRecordId && paperRecordId.length > 0){
        NSLog(@"加载考试[%@]结果数据...", paperRecordId);
        static NSString *query_sql = @"SELECT paperId,score,rights,useTimes,createTime,lastTime FROM tbl_paperRecords WHERE id = ? limit 0,1";
        static NSString *error_sql = @"SELECT count(*) FROM tbl_itemRecords WHERE paperRecordId = ? and status = 0";
        static NSString *total_sql = @"SELECT total FROM tbl_papers WHERE id = ? limit 0,1";
        
        [_dbQueue inDatabase:^(FMDatabase *db) {
            //查询试卷记录信息
            FMResultSet *rs = [db executeQuery:query_sql, paperRecordId];
            while ([rs next]) {
                resultModel = [[PaperResultModel alloc]  init];
                resultModel.Id = paperRecordId;
                resultModel.paperId = [rs stringForColumn:@"paperId"];
                resultModel.score = [NSNumber numberWithDouble:[rs doubleForColumn:@"score"]];
                resultModel.rights = [rs intForColumn:@"rights"];
                resultModel.useTimes = [rs longForColumn:@"useTimes"];
                resultModel.createTime = [rs stringForColumn:@"createTime"];
                resultModel.lastTime = [rs stringForColumn:@"lastTime"];
                break;
            }
            [rs close];
            //
            if(resultModel){
                //查询错题数
                resultModel.errors = [db intForQuery:error_sql, paperRecordId];
                //查询总题数
                resultModel.total = [db intForQuery:total_sql, resultModel.paperId];
                //统计未做题
                if(resultModel.total > resultModel.errors > 0){
                    resultModel.nots = resultModel.total - resultModel.errors - resultModel.rights;
                }
            }
        }];
    }
    return resultModel;
}

#pragma mark 加载错题记录
-(NSArray *)totalErrorRecords{
    __block NSMutableArray *arrays = nil;
    if(_dbQueue){
        static NSString *total_sql = @"SELECT COUNT(a.id) as total,d.code,d.name FROM tbl_itemRecords a LEFT OUTER JOIN tbl_paperRecords b ON b.id = a.paperRecordId LEFT OUTER JOIN tbl_papers c ON c.id = b.paperId LEFT OUTER JOIN tbl_subjects d ON d.code = c.subjectCode WHERE a.status = 0 group by d.code,d.name";
        [_dbQueue inDatabase:^(FMDatabase *db) {
            arrays = [NSMutableArray array];
            FMResultSet *rs = [db executeQuery:total_sql];
            while ([rs next]) {
                [arrays addObject:@{@"subjectId":[rs stringForColumn:@"code"],
                                    @"subjectName":[rs stringForColumn:@"name"],
                                    @"total" : [NSNumber numberWithInt:[rs intForColumn:@"total"]]}];
            }
            [rs close];
        }];
    }
    return arrays;
}

#pragma mark 加载收藏记录
-(NSArray *)totalFavoriteRecords{
    __block NSMutableArray *arrays = nil;
    if(_dbQueue){
        static NSString *total_sql = @"select count(a.itemId) as total,b.code,b.name from tbl_favorites a left outer join tbl_subjects b on b.code = a.subjectCode group by b.code,b.name";
        [_dbQueue inDatabase:^(FMDatabase *db) {
            arrays = [NSMutableArray array];
            FMResultSet *rs = [db executeQuery:total_sql];
            while ([rs next]) {
                [arrays addObject:@{@"subjectId":[rs stringForColumn:@"code"],
                                    @"subjectName":[rs stringForColumn:@"name"],
                                    @"total" : [NSNumber numberWithInt:[rs intForColumn:@"total"]]}];
            }
            [rs close];
        }];
    }
    return arrays;
}
@end
