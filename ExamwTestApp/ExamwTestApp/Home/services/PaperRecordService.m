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
-(NSString *)loadRecordAnswersWithPaperRecordId:(NSString *)recordId itemId:(NSString *)itemId{
    NSLog(@"加载试卷记录[%@]中试题[%@]答案...", recordId, itemId);
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
    //创建数据操作队列
    FMDatabaseQueue *dbQueue = [_daoHelpers createDatabaseQueue];
    if(!dbQueue){
        NSLog(@"创建数据库操作失败!");
        return;
    }
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
    //查询SQL
    static NSString *query_sql = @"SELECT id FROM tbl_itemRecords WHERE paperRecordId = ? and itemId = ? limit 0,1";
    //执行脚本
    [dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            //查询记录是否存在
            NSString *itemRecordId = [db stringForQuery:query_sql, recordId, model.itemId];
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
                [db executeUpdate:insert_sql,itemRecordId,recordId,model.structureId,model.itemId,[NSNumber numberWithInteger:model.itemType],itemJSONEncypt,answers,[NSNumber numberWithBool:isRight],score];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"更新试题记录异常：%@", exception);
        }
    }];
}
@end
