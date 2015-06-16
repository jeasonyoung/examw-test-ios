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

#import "MySubjectModel.h"

#import "PaperUtils.h"

#define __kPaperService_pageOfRows _kAPP_DEFAULT_PAGEROWS//分页
//试卷服务接口成员变量
@interface PaperService (){
    FMDatabaseQueue *_dbQueue;
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
    }
    return self;
}

#pragma mark 加载试卷类型集合。
-(NSArray *)findPaperTypes{
    NSLog(@"加载试卷类型集合数据...");
    if(_dbQueue){
        static NSString *query_sql = @"select type from tbl_papers group by type order by type desc";
        NSMutableArray *arrays = [NSMutableArray array];
        //
        NSLog(@"exec-sql:%@", query_sql);
        [_dbQueue inDatabase:^(FMDatabase *db) {
            FMResultSet *rs = [db executeQuery:query_sql];
            while ([rs next]){
                [arrays addObject:[NSNumber numberWithInt:[rs intForColumn:@"type"]]];
            }
            [rs close];
        }];
        return arrays;
    }
    return nil;
}

#pragma mark 按试卷类型分页查找试卷信息数据
-(NSArray *)findPapersInfoWithPaperType:(NSUInteger)paperType andPageIndex:(NSUInteger)pageIndex{
    NSLog(@"按试卷类型[%d]分页[%d]查找试卷数据...", (int)paperType, (int)pageIndex);
    if(_dbQueue){
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
    return nil;
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
    if(!paperModel && _dbQueue){
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

#pragma mark 加载科目下的试卷记录集合
-(NSArray *)loadPaperRecordsWithSubjectCode:(NSString *)subjectCode andPageIndex:(NSUInteger)pageIndex{
    if(_dbQueue && subjectCode && subjectCode.length > 0){
        NSLog(@"加载科目[%@]下的试卷记录集合...", subjectCode);
        NSString *query_sql = [NSString stringWithFormat:@"SELECT a.id,a.paperId,b.title,a.status,a.score,a.rights,a.useTimes,a.lastTime FROM tbl_paperRecords a LEFT OUTER JOIN tbl_papers b ON b.id = a.paperId WHERE b.subjectCode = ? ORDER BY a.lastTime DESC LIMIT %d,%d",(int)(pageIndex * _pageOfRows), (int)_pageOfRows];
        //
        NSMutableArray *arrays = [NSMutableArray arrayWithCapacity:_pageOfRows];
        [_dbQueue inDatabase:^(FMDatabase *db) {
            NSLog(@"exec-sql:%@", query_sql);
            FMResultSet *rs = [db executeQuery:query_sql, subjectCode];
            while ([rs next]) {
                PaperRecordModel *model = [[PaperRecordModel alloc] init];
                model.Id = [rs stringForColumn:@"id"];
                model.paperId = [rs stringForColumn:@"paperId"];
                model.paperName = [rs stringForColumn:@"title"];
                model.status = [rs boolForColumn:@"status"];
                model.score = [NSNumber numberWithDouble:[rs doubleForColumn:@"score"]];
                model.rights = [rs intForColumn:@"rights"];
                model.useTimes = [rs intForColumn:@"useTimes"];
                model.lastTime = [rs stringForColumn:@"lastTime"];
                [arrays addObject:model];
            }
            [rs close];
        }];
        return arrays;
    }
    return nil;
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
-(BOOL)exitFavoriteWithModel:(PaperItemModel *)itemModel{
    __block BOOL result = NO;
    if(_dbQueue && itemModel){
        NSString *itemId = [NSString stringWithFormat:@"%@$%d", itemModel.itemId, (int)itemModel.index];
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
#pragma mark 加载试题记录中的答案
-(NSString *)loadRecordAnswersWithPaperRecordId:(NSString *)recordId itemModel:(PaperItemModel *)model{
    __block NSString *answers = nil;
    if(_dbQueue && recordId && model){
        NSString *itemId = [NSString stringWithFormat:@"%@$%d", model.itemId, (int)model.index];
        static NSString *query_sql = @"SELECT answer FROM tbl_itemRecords WHERE paperRecordId = ? and itemId = ? limit 0,1";
        [_dbQueue inDatabase:^(FMDatabase *db) {
            NSLog(@"exec-sql:%@", query_sql);
            answers = [db stringForQuery:query_sql, recordId, itemId];
        }];
    }
    return answers;
}

#pragma mark 删除试卷记录
-(void)deleteRecordWithPaperRecordId:(NSString *)recordId{
    if(_dbQueue && recordId && recordId.length > 0){
        NSLog(@"准备删除试卷记录[%@]...", recordId);
        //删除试题SQL
        static NSString *del_item_sql = @"DELETE FROM tbl_itemRecords WHERE paperRecordId = ?";
        //删除试卷SQL
        static NSString *del_paper_sql = @"DELETE FROM tbl_paperRecords WHERE id = ?";
        //
        [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            @try {
                //1.先删除试题记录
                NSLog(@"exec-sql-1.%@", del_item_sql);
                [db executeUpdate:del_item_sql, recordId];
                //2.再删除试卷记录
                 NSLog(@"exec-sql-2.%@", del_paper_sql);
                [db executeUpdate:del_paper_sql, recordId];
            }
            @catch (NSException *exception) {
                *rollback = YES;
                NSLog(@"删除试卷记录[%@]异常:%@",recordId, exception);
            }
        }];
    }
}

#pragma mark 添加试题记录
-(void)addRecordWithPaperRecordId:(NSString *)recordId itemModel:(PaperItemModel *)model
                        myAnswers:(NSString *)answers useTimes:(NSUInteger)useTimes{
    NSLog(@"添加试卷试题记录...");
    if(!_dbQueue)return;
    if(!answers || answers.length == 0)return;
    if(!recordId || recordId.length == 0)return;
    if(!model || !model.itemId || model.itemId.length == 0)return;
    //计算得分
    NSNumber *score = @0;
    BOOL isRight = NO;
    if(model.itemAnswer && model.itemAnswer.length > 0){
        NSUInteger count = 0;
        isRight =YES;
        NSArray *myAnswerArrays = [answers componentsSeparatedByString:@","];
        for(NSString *myAnswer in myAnswerArrays){
            if(!myAnswer || myAnswer.length == 0)continue;
            NSRange range = [model.itemAnswer rangeOfString:myAnswer];
            if(range.location != NSNotFound){
                count += 1;
            }else{
                isRight = NO;
            }
        }
        if(count == 0){
            isRight = NO;
        }
        if(isRight){
            score = model.structureScore;
        }else if(count > 0){
            score = model.structureMin;
        }
    }
    //执行脚本
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            //查询SQL
            static NSString *query_sql = @"SELECT id FROM tbl_itemRecords WHERE paperRecordId = ? and itemId = ? limit 0,1";
            NSString *itemId = [NSString stringWithFormat:@"%@$%d", model.itemId, (int)model.index];
            //查询记录是否存在
            NSString *itemRecordId = [db stringForQuery:query_sql, recordId, itemId];
            if(itemRecordId && itemRecordId.length > 0){//更新记录
                //更新SQL
                static NSString *update_sql = @"UPDATE tbl_itemRecords SET answer = ?,status = ?,score = ?,useTimes = ?,lastTime = ?,sync = 0 WHERE id = ?";
                NSLog(@"exec-sql:%@", update_sql);
                NSDateFormatter *dtFormat = [[NSDateFormatter alloc] init];
                [dtFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *lastTime = [dtFormat stringFromDate:[NSDate date]];
                [db executeUpdate:update_sql, answers, [NSNumber numberWithBool:isRight],score,[NSNumber numberWithInteger:useTimes],lastTime, itemRecordId];
            }else{//新增
                itemRecordId = [[NSUUID UUID] UUIDString];
                //试题密文
                NSString *itemJSONEncypt = [PaperUtils encryptPaperContent:[model serializeJSON] andPassword:itemRecordId];
                //新增SQL
                static NSString *insert_sql = @"INSERT INTO  tbl_itemRecords(id,paperRecordId,structureId,itemId,itemType,content,answer,status,score,useTimes) values(?,?,?,?,?,?,?,?,?,?)";
                NSLog(@"exec-sql:%@", insert_sql);
                [db executeUpdate:insert_sql,itemRecordId,recordId,model.structureId,itemId,[NSNumber numberWithInteger:model.itemType],itemJSONEncypt,answers,[NSNumber numberWithBool:isRight],score,[NSNumber numberWithInteger:useTimes]];
            }
        }
        @catch (NSException *exception) {
            *rollback = YES;
            NSLog(@"更新试题记录异常：%@", exception);
        }
    }];
}

#pragma mark 收藏/取消收藏(收藏返回true,取消返回false)
-(BOOL)updateFavoriteWithPaperId:(NSString *)paperId itemModel:(PaperItemModel *)model{
    return [self updateFavoriteWithItemModel:model withSubjectBlock:^NSString *(FMDatabase *db) {
        static NSString *query_subject_sql = @"SELECT subjectCode FROM tbl_papers WHERE id = ?";
        
        return [db stringForQuery:query_subject_sql, paperId];
    }];
}

//收藏/取消收藏(收藏返回true,取消返回false)
-(BOOL)updateFavoriteWithSubjectCode:(NSString *)subjectCode itemModel:(PaperItemModel *)model{
    return [self updateFavoriteWithItemModel:model withSubjectBlock:^NSString *(FMDatabase *db) {
        return subjectCode;
    }];
}
//收藏/取消收藏(收藏返回true,取消返回false)
-(BOOL)updateFavoriteWithItemModel:(PaperItemModel *)model withSubjectBlock:(NSString *(^)(FMDatabase *db))subject{
    __block BOOL result = NO;
    if(_dbQueue && model && model.itemId && model.itemId.length > 0){
        NSLog(@"开始收藏/取消收藏(收藏返回true,取消返回false)...");
        NSString *itemId = [NSString stringWithFormat:@"%@$%d", model.itemId, (int)model.index];
        //查询sql
        static NSString *query_sql = @"SELECT id,status FROM tbl_favorites WHERE itemId = ? limit 0,1";
        [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            @try {
                NSString *favId = nil;
                BOOL status = NO;
                //查询数据
                FMResultSet *rs = [db executeQuery:query_sql, itemId];
                while ([rs next]) {
                    favId = [rs stringForColumn:@"id"];
                    status = [rs boolForColumn:@"status"];
                    break;
                }
                [rs close];
                //
                if(status){//已收藏(应变为未收藏)
                    result = YES;
                    static NSString *update_sql_non = @"UPDATE tbl_favorites SET status = 0 WHERE id = ?";
                    [db executeUpdate:update_sql_non, favId];
                    result = NO;
                }else{//未收藏
                    result = NO;
                    if(favId && favId.length > 0){//未收藏状态，更新状态变为已收藏
                        static NSString *update_sql_has = @"UPDATE tbl_favorites SET status = 1 WHERE id = ?";
                        [db executeUpdate:update_sql_has, favId];
                        result = YES;
                    }else{//新收藏
                        NSString *subjectCode = (subject ? subject(db) : nil);
                        if(subjectCode && subjectCode.length > 0){
                            static NSString *insert_sql = @"INSERT INTO tbl_favorites(id,subjectCode,itemId,itemType,content) values(?,?,?,?,?) ";
                            favId = [[NSUUID UUID] UUIDString];
                            //试题密文
                            NSString *itemJSONEncypt = [PaperUtils encryptPaperContent:[model serializeJSON] andPassword:favId];
                            NSLog(@"exec-sql:%@", insert_sql);
                            [db executeUpdate:insert_sql,favId,subjectCode,itemId,[NSNumber numberWithInteger:model.itemType],itemJSONEncypt];
                            result = YES;
                        }else{
                            NSLog(@"所属科目[%@]不存在!", subjectCode);
                        }
                    }
                }
            }
            @catch (NSException *exception) {
                *rollback = YES;
                NSLog(@"执行收藏/取消收藏异常:%@",exception);
            }
        }];
    }
    return result;

}

#pragma mark 交卷处理
-(void)submitWithPaperRecordId:(NSString *)paperRecordId andUseTimes:(NSUInteger)useTimes{
    if(_dbQueue && paperRecordId && paperRecordId.length > 0){
        NSLog(@"开始交卷[paperReacordId=%@]处理...", paperRecordId);
        //统计得分/用时/正确
        static NSString *total_score_sql = @"SELECT SUM(score) AS score,SUM(useTimes) as useTimes,SUM(status) AS rights FROM tbl_itemRecords WHERE paperRecordId = ?";
        //更新试卷记录
        static NSString *update_sql = @"UPDATE tbl_paperRecords SET status = 1,score = ?,useTimes = ?,rights = ?,lastTime = ? WHERE id = ?";
        [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            @try {
                //统计得分
                NSLog(@"统计得分/用时-exec-sql:%@", total_score_sql);
                double totalScore = 0, totalRights = 0, totalUseTimes = 0;
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
                totalUseTimes += useTimes;
                NSDateFormatter *dtFormat = [[NSDateFormatter alloc] init];
                [dtFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *lastTime = [dtFormat stringFromDate:[NSDate date]];
                [db executeUpdate:update_sql,[NSNumber numberWithDouble:totalScore],
                 [NSNumber numberWithDouble:totalUseTimes],[NSNumber numberWithDouble:totalRights], lastTime, paperRecordId];
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
        static NSString *total_sql = @"SELECT a.code,a.name,COUNT(d.itemId) AS total FROM tbl_subjects a LEFT OUTER JOIN tbl_papers b ON b.subjectCode = a.code LEFT OUTER JOIN tbl_paperRecords c ON c.paperId = b.id LEFT OUTER JOIN tbl_itemRecords d ON d.paperRecordId = c.id WHERE ((d.status IS NULL) OR (d.status = 0)) GROUP BY a.code,a.name";
        [_dbQueue inDatabase:^(FMDatabase *db) {
            arrays = [NSMutableArray array];
            NSLog(@"exec-sql:%@", total_sql);
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
        static NSString *total_sql = @"SELECT a.code,a.name,COUNT(b.itemId) AS total FROM tbl_subjects a LEFT OUTER JOIN tbl_favorites b ON b.subjectCode = a.code WHERE ((b.status IS NULL) OR (b.status = 1)) GROUP BY a.code,a.name";
        [_dbQueue inDatabase:^(FMDatabase *db) {
            arrays = [NSMutableArray array];
            NSLog(@"exec-sql:%@", total_sql);
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

#pragma mark 根据科目加载收藏集合
-(NSArray *)loadFavoritesWithSubjectCode:(NSString *)subjectCode{
    NSLog(@"加载科目[%@]下的收藏试题数据...",subjectCode);
    if(!subjectCode || subjectCode.length == 0) return nil;
    if(_dbQueue){
        static NSString *query_sql = @"SELECT id,content FROM tbl_favorites WHERE status = 1 AND subjectCode = ? ORDER BY itemType,createTime DESC";
        NSMutableArray *arrays = [NSMutableArray array];
        [_dbQueue inDatabase:^(FMDatabase *db) {
            FMResultSet *rs = [db executeQuery:query_sql,subjectCode];
            while ([rs next]) {
                NSString *favId = [rs stringForColumn:@"id"];
                NSString *contentHex = [rs stringForColumn:@"content"];
                NSString *json = [PaperUtils decryptPaperContentWithHex:contentHex andPassword:favId];
                PaperItemModel *itemModel = [[PaperItemModel alloc] initWithJSON:json];
                if(itemModel){
                    [arrays addObject:itemModel];
                }
            }
            [rs close];
        }];
        return arrays;
    }
    return nil;
}

#pragma mark 根据科目加载错题集合
-(NSArray *)loadErrorsWithSubjectCode:(NSString *)subjectCode{
    NSLog(@"加载科目[%@]下错题数据...",subjectCode);
    if(!subjectCode || subjectCode.length == 0)return nil;
    if(_dbQueue){
        static NSString *query_sql = @"SELECT a.id,a.paperRecordId,a.content FROM tbl_itemRecords a LEFT OUTER JOIN tbl_paperRecords b ON b.id = a.paperRecordId LEFT OUTER JOIN tbl_papers c ON c.id = b.paperId WHERE a.status = 0 AND c.subjectCode = ? ORDER BY a.itemType";
        NSMutableArray *arrays = [NSMutableArray array];
        [_dbQueue inDatabase:^(FMDatabase *db) {
            FMResultSet *rs = [db executeQuery:query_sql,subjectCode];
            while ([rs next]) {
                NSString *itemRecordId = [rs stringForColumn:@"id"];
                NSString *contentHex = [rs stringForColumn:@"content"];
                NSString *json = [PaperUtils decryptPaperContentWithHex:contentHex andPassword:itemRecordId];
                PaperItemModel *itemModel = [[PaperItemModel alloc] initWithJSON:json];
                if(itemModel){
                    itemModel.itemRecordId = itemRecordId;
                    itemModel.paperRecordId = [rs stringForColumn:@"paperRecordId"];
                    [arrays addObject:itemModel];
                }
            }
            [rs close];
        }];
        return arrays;
    }
    return nil;
}

#pragma mark 根据考试加载试卷记录
-(NSArray *)totalPaperRecords{
    NSLog(@"加载试卷记录...");
    if(_dbQueue){
        static NSString *query_sql = @"SELECT a.code,a.name,COUNT(c.id) AS total FROM tbl_subjects a LEFT OUTER JOIN tbl_papers b ON b.subjectCode = a.code LEFT OUTER JOIN tbl_paperRecords c ON c.paperId = b.id WHERE a.status = 1 GROUP BY a.code,a.name";
        NSMutableArray *arrays = [NSMutableArray array];
        [_dbQueue inDatabase:^(FMDatabase *db) {
            NSLog(@"exec-sql:%@", query_sql);
            FMResultSet *rs = [db executeQuery:query_sql];
            while ([rs next]) {
                MySubjectModel *model = [[MySubjectModel alloc] init];
                model.subjectCode = [rs stringForColumn:@"code"];
                model.subject = [rs stringForColumn:@"name"];
                model.total = [rs intForColumn:@"total"];
                [arrays addObject:model];
            }
            [rs close];
        }];
        return arrays;
    }
    return nil;
}
@end
