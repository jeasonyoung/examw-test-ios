//
//  PaperRecordService.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperRecordService.h"

#import "PaperItemModel.h"

#import "DaoHelpers.h"
#import "PaperUtils.h"
//试卷记录服务成员变量
@interface PaperRecordService (){
    DaoHelpers *_daoHelpers;
}
@end
//试卷记录服务实现
@implementation PaperRecordService

#pragma mark 重构初始化
-(instancetype)init{
    if(self = [super init]){
        _daoHelpers = [[DaoHelpers alloc] init];
    }
    return self;
}

#pragma mark 加载试题记录中的答案
-(NSString *)loadRecordAnswersWithPaperRecordId:(NSString *)recordId itemModel:(PaperItemModel *)model{
    if(!model) return nil;
    NSLog(@"加载试卷记录[%@]中试题[%@:%d]答案...", recordId, model.itemId, (int)model.index);
    //创建数据操作队列
    FMDatabaseQueue *dbQueue = [_daoHelpers createDatabaseQueue];
    if(!dbQueue){
        NSLog(@"创建数据库操作失败!");
        return nil;
    }
    //SQL
    static NSString *query_sql = @"SELECT answer FROM tbl_itemRecords WHERE paperRecordId = ? and itemId = ? limit 0,1";
    __block NSString *answers = nil;
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSLog(@"exec-sql:%@", query_sql);
        NSString *itemId = [NSString stringWithFormat:@"%@$%d", model.itemId, (int)model.index];
        answers = [db stringForQuery:query_sql, recordId, itemId];
    }];
    
    return answers;
}

#pragma mark 添加试题记录
-(void)addRecordWithPaperRecordId:(NSString *)recordId itemModel:(PaperItemModel *)model myAnswers:(NSString *)answers{
    NSLog(@"添加试卷试题记录...");
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
    //创建数据操作队列
    FMDatabaseQueue *dbQueue = [_daoHelpers createDatabaseQueue];
    if(!dbQueue){
        NSLog(@"创建数据库操作失败!");
        return;
    }
    //执行脚本
    [dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            //查询SQL
            static NSString *query_sql = @"SELECT id FROM tbl_itemRecords WHERE paperRecordId = ? and itemId = ? limit 0,1";
            NSString *itemId = [NSString stringWithFormat:@"%@$%d", model.itemId, (int)model.index];
            //查询记录是否存在
            NSString *itemRecordId = [db stringForQuery:query_sql, recordId, itemId];
            if(itemRecordId && itemRecordId.length > 0){//更新记录
                //更新SQL
                static NSString *update_sql = @"UPDATE tbl_itemRecords SET answer = ?,status = ?,score = ?,lastTime = ?,sync = 0 WHERE id = ?";
                NSLog(@"exec-sql:%@", update_sql);
                [db executeUpdate:update_sql, answers, [NSNumber numberWithBool:isRight],score,[NSDate date], itemRecordId];
            }else{//新增
                itemRecordId = [[NSUUID UUID] UUIDString];
                //试题密文
                NSString *itemJSONEncypt = [PaperUtils encryptPaperContent:[model serializeJSON] andPassword:itemRecordId];
                //新增SQL
                static NSString *insert_sql = @"INSERT INTO  tbl_itemRecords(id,paperRecordId,structureId,itemId,itemType,content,answer,status,score) values(?,?,?,?,?,?,?,?,?)";
                NSLog(@"exec-sql:%@", insert_sql);
                [db executeUpdate:insert_sql,itemRecordId,recordId,model.structureId,itemId,[NSNumber numberWithInteger:model.itemType],itemJSONEncypt,answers,[NSNumber numberWithBool:isRight],score];
            }
        }
        @catch (NSException *exception) {
            *rollback = YES;
            NSLog(@"更新试题记录异常：%@", exception);
        }
    }];
}

//#pragma mark 加载试卷所属科目ID
//-(NSString *)loadSubjectCodeWithPaperId:(NSString *)paperId{
//    NSLog(@"加载试卷[%@]所属科目ID...", paperId);
//    if(paperId && paperId.length > 0){
//        static NSMutableDictionary *paperSubjectCache;
//        if(!paperSubjectCache){
//            paperSubjectCache = [NSMutableDictionary dictionary];
//        }
//        __block NSString *subjectCode = [paperSubjectCache objectForKey:paperId];
//        if(!subjectCode || subjectCode.length == 0){
//            //创建数据操作队列
//            FMDatabaseQueue *dbQueue = [_daoHelpers createDatabaseQueue];
//            if(!dbQueue){
//                NSLog(@"创建数据操作失败!");
//                return nil;
//            }
//            //执行SQL
//            [dbQueue inDatabase:^(FMDatabase *db) {
//                NSString *query_sql = @"SELECT subjectCode FROM tbl_papers WHERE id = ? limit 0,1";
//                NSLog(@"exec-sql:%@", query_sql);
//                subjectCode = [db stringForQuery:query_sql, paperId];
//                if(subjectCode && subjectCode.length > 0){
//                    [paperSubjectCache setObject:[subjectCode copy] forKey:paperId];
//                }
//            }];
//        }
//        return (subjectCode ? [subjectCode copy] : nil);
//    }
//    return nil;
//}

#pragma mark 收藏/取消收藏(收藏返回true,取消返回false)
-(BOOL)updateFavoriteWithPaperRecordId:(NSString *)recordId itemModel:(PaperItemModel *)model{
    __block BOOL result = NO;
    if(recordId && recordId.length > 0 && model && model.itemId && model.itemId.length > 0){
        NSLog(@"开始收藏/取消收藏(收藏返回true,取消返回false)...");
        //创建数据操作队列
        FMDatabaseQueue *dbQueue = [_daoHelpers createDatabaseQueue];
        if(!dbQueue){
            NSLog(@"创建数据操作失败!");
        }else{
            //查询sql
            static NSString *query_sql = @"SELECT id FROM tbl_favorites WHERE itemId = ? limit 0,1";
            [dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                @try {
                    NSString *favId = [db stringForQuery:query_sql, model.itemId];
                    if(favId && favId.length > 0){//已收藏，取消掉
                        NSString *update_sql = @"DELETE FROM tbl_favorites WHERE id = ?";
                        NSLog(@"exec-sql:%@", update_sql);
                        [db executeUpdate:update_sql, favId];
                        result = NO;
                    }else{//未收藏，收藏
                        static NSString *query_subject_sql = @"SELECT a.subjectCode FROM tbl_papers a inner join tbl_paperRecords b on b.paperId = a.id WHERE b.id = ? limit 0,1";
                        NSString *SubjectCode = [db stringForQuery:query_subject_sql, recordId];
                        //
                        favId = [[NSUUID UUID] UUIDString];
                        //试题密文
                        NSString *itemJSONEncypt = [PaperUtils encryptPaperContent:[model serializeJSON] andPassword:favId];
                        static NSString *insert_sql = @"INSERT INTO tbl_favorites(id,subjectCode,itemId,itemType,content) values(?,?,?,?,?) ";
                        NSLog(@"exec-sql:%@", insert_sql);
                        [db executeUpdate:insert_sql,favId,SubjectCode,model.itemId,[NSNumber numberWithInteger:model.itemType],itemJSONEncypt];
                        result = YES;
                    }
                }
                @catch (NSException *exception) {
                    *rollback = YES;
                    NSLog(@"执行收藏/取消收藏异常:%@",exception);
                }
            }];
        }
    }
    return result;
}

@end
