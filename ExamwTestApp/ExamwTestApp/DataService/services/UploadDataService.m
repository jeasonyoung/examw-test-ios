//
//  UploadDataService.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "UploadDataService.h"
#import "AppConstants.h"

#import "DaoHelpers.h"

#import "HttpUtils.h"

#import "AppClientPush.h"
#import "FavoriteSync.h"
#import "PaperRecordSync.h"
#import "PaperItemRecordSync.h"

#import "PaperUtils.h"
#import "JSONCallback.h"
//上传数据服务成员变量
@interface UploadDataService (){
    FMDatabaseQueue *_dbQueue;
    NSDateFormatter *_dtFormatter;
}
@end
//上传数据服务实现
@implementation UploadDataService

#pragma mark 重构初始化
-(instancetype)init{
    if(self = [super init]){
        //初始化DbQueue
        _dbQueue = [[[DaoHelpers alloc] init] createDatabaseQueue];
        //初始化日期格式化
        _dtFormatter = [[NSDateFormatter alloc] init];
        [_dtFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return self;
}

#pragma mark 上传数据
-(void)upload{
    //0.检查网络
    [HttpUtils checkNetWorkStatus:^(BOOL statusValue) {
        if(statusValue){
            //1.上传收藏数据
            [self uploadFavorites];
            //2.上传试卷记录
            [self uploadPaperRecords];
            //3.上传做题记录
            [self uploadPaperItemRecords];
        }else{
            NSLog(@"网络不通，暂不能上传数据，请检查网络!");
        }
    }];
}
//上传收藏记录数据
-(void)uploadFavorites{
    @try {
        if(!_dbQueue)return;
        NSLog(@"准备上传收藏数据...");
        static NSString *del_sql = @"DELETE FROM tbl_favorites WHERE sync = 1 AND status = 0";
        static NSString *query_sql = @"SELECT * FROM tbl_favorites WHERE sync = 0 ORDER BY createTime DESC limit 0,10";
        //0.定义查询结果数组
        NSMutableArray *arrays = [NSMutableArray arrayWithCapacity:10];
        [_dbQueue inDatabase:^(FMDatabase *db) {
            //0.删除已同步的取消收藏的试题
            [db executeUpdate:del_sql];
            //1.查询数据
            FMResultSet *rs = [db executeQuery:query_sql];
            while ([rs next]) {
                //2.初始化数据模型
                FavoriteSync *fav = [[FavoriteSync alloc] init];
                fav.Id = [rs stringForColumn:@"id"];
                fav.subjectId = [rs stringForColumn:@"subjectCode"];
                fav.itemId = [rs stringForColumn:@"itemId"];
                fav.itemType = [rs intForColumn:@"itemType"];
                fav.content = [PaperUtils decryptPaperContentWithHex:[rs stringForColumn:@"content"] andPassword:fav.Id];
                fav.status = [rs intForColumn:@"status"];
                fav.createTime = [_dtFormatter dateFromString:[rs stringForColumn:@"createTime"]];
                //3.添加到数组集合
                [arrays addObject:fav];
            }
            [rs close];
        }];
        //检查是否查询到需要上传的数据
        if(!arrays || arrays.count == 0)return;
        //更新收藏同步状态
        static NSString *update_sql = @"UPDATE tbl_favorites SET sync = 1 WHERE id = ?";
        void(^asyncUpdateStatus)(NSString *) = ^(NSString *favId){
            //异步线程更新收藏同步状态
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSLog(@"异步线程更新收藏同步状态[%@]...",favId);
                if(_dbQueue && favId && favId.length > 0){
                    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                        @try {
                            [db executeUpdate:update_sql, favId];
                        }
                        @catch (NSException *exception) {
                            *rollback = YES;
                            NSLog(@"更新收藏[%@]同步状态时异常:%@",favId, exception);
                        }
                    }];
                }
            });
        };
        //异步线程上传处理块
        void(^asyncUploadHandler)(FavoriteSync *) = ^(FavoriteSync *model){
            if(!model || !model.Id || model.Id.length == 0)return;
            //异步线程上传
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @try {
                    NSLog(@"异步线程上传试题收藏:[%@=>%@]...",model.Id, model.itemId);
                    //检查网络
                    [HttpUtils checkNetWorkStatus:^(BOOL statusValue) {
                        if(!statusValue)return;//网络断开，不能上传
                        //初始化上传数据模型
                        AppClientPush *push = [[AppClientPush alloc] initWithRecords:@[model]];
                        //上传数据
                        [HttpUtils JSONDataWithUrl:_kAPP_API_FAVORITES_URL method:HttpUtilsMethodPOST
                                        parameters:[push serialize] progress:nil success:^(NSDictionary *result) {
                                            JSONCallback *callback = [JSONCallback callbackWithDict:result];
                                            if(callback.success){
                                                //上传成功，更新同步状态
                                                asyncUpdateStatus(model.Id);
                                            }else{
                                                NSLog(@"上传收藏[%@,%@]失败:%@", model.Id,model.itemId, callback.msg);
                                            }
                                        } fail:^(NSString *err) {
                                           NSLog(@"上传收藏[%@,%@]失败:%@", model.Id,model.itemId, err);
                                        }];
                    }];
                }
                @catch (NSException *exception) {
                    NSLog(@"异步线程上传试题收藏[%@=>%@]时异常:%@",model.Id, model.itemId, exception);
                }
            });
        };
        //开始网络数据传输
        for(FavoriteSync *model in arrays){
            if(!model)continue;
            //按条上传试题收藏
            asyncUploadHandler(model);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"上传收藏数据异常:%@", exception);
    }
}
//上传试卷记录数据
-(void)uploadPaperRecords{
    @try {
        if(!_dbQueue)return;
        NSLog(@"准备上传试卷记录数据...");
        static NSString *query_sql = @"SELECT * FROM tbl_paperRecords WHERE sync = 0 ORDER BY lastTime DESC limit 0,10";
        //0.定义查询结果数组
        NSMutableArray *arrays = [NSMutableArray arrayWithCapacity:10];
        [_dbQueue inDatabase:^(FMDatabase *db) {
            //1.查询数据
            FMResultSet *rs = [db executeQuery:query_sql];
            while ([rs next]) {
                //2.初始化试卷记录数据模型
                PaperRecordSync *record = [[PaperRecordSync alloc] init];
                record.Id = [rs stringForColumn:@"id"];
                record.paperId = [rs stringForColumn:@"paperId"];
                record.status = [rs intForColumn:@"status"];
                record.score = [rs doubleForColumn:@"score"];
                record.rights = [rs intForColumn:@"rights"];
                record.useTimes = [rs intForColumn:@"useTimes"];
                record.createTime = [_dtFormatter dateFromString:[rs stringForColumn:@"createTime"]];
                record.lastTime = [_dtFormatter dateFromString:[rs stringForColumn:@"lastTime"]];
                //添加到结果数组
                [arrays addObject:record];
            }
            [rs close];
        }];
        //检查是否查询到需要上传的数据
        if(!arrays || arrays.count == 0)return;
        //更新状态
        static NSString *update_sql = @"UPDATE tbl_paperRecords SET sync = 1 WHERE id = ?";
        void(^asyncUpdateStatus)(NSString *) = ^(NSString *recordId){
            //异步线程更新试卷记录状态
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSLog(@"异步线程更新试题[%@]记录状态...",recordId);
                if(_dbQueue && recordId && recordId.length > 0){
                    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                        @try {
                            [db executeUpdate:update_sql,recordId];
                        }
                        @catch (NSException *exception) {
                            *rollback = YES;
                             NSLog(@"异步线程更新试题[%@]记录状态异常:%@",recordId, exception);
                        }
                    }];
                }
            });
        };
        //异步线程上传试卷记录
        void(^asyncUploadHandler)(PaperRecordSync *) = ^(PaperRecordSync *record){
            if(!record || !record.Id || record.Id.length == 0)return;
            //异步线程
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @try {
                    NSLog(@"异步线程上传试卷记录:[%@=>%@]...",record.Id, record.paperId);
                    //检查网络
                    [HttpUtils checkNetWorkStatus:^(BOOL statusValue) {
                        if(!statusValue)return;//网络断开，不能上传
                        //初始化上传数据模型
                        AppClientPush *push = [[AppClientPush alloc] initWithRecords:@[record]];
                        //上传数据
                        [HttpUtils JSONDataWithUrl:_kAPP_API_PAPERRECORDS_URL method:HttpUtilsMethodPOST
                                        parameters:[push serialize] progress:nil success:^(NSDictionary *result) {
                                            JSONCallback *callback = [JSONCallback callbackWithDict:result];
                                            if(callback.success){
                                                //上传成功，更新同步状态
                                                asyncUpdateStatus(record.Id);
                                            }else{
                                                NSLog(@"上传试卷记录[%@,%@]失败:%@", record.Id,record.paperId, callback.msg);
                                            }
                                        } fail:^(NSString *err) {
                                            NSLog(@"异步线程上传试卷记录[%@=>%@]失败:%@",record.Id, record.paperId, err);
                                        }];
                    }];
                }
                @catch (NSException *exception) {
                     NSLog(@"异步线程上传试卷记录[%@=>%@]时异常:%@",record.Id, record.paperId, exception);
                }
            });
        };
        //开始网络数据传输
        for(PaperRecordSync *model in arrays){
            if(!model)continue;
            //按条上传试卷记录
            asyncUploadHandler(model);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"上传试卷记录数据异常:%@", exception);
    }
}

//上传试题记录数据
-(void)uploadPaperItemRecords{
    @try {
        if(!_dbQueue)return;
        NSLog(@"准备上传试题记录数据...");
        static NSString *query_sql = @"SELECT * FROM tbl_itemRecords WHERE sync = 0 ORDER BY lastTime DESC limit 0,10";
        //0.定义查询结果数组
        NSMutableArray *arrays = [NSMutableArray arrayWithCapacity:10];
        [_dbQueue inDatabase:^(FMDatabase *db) {
            //1.查询数据
            FMResultSet *rs = [db executeQuery:query_sql];
            while ([rs next]) {
                //2.初始化试题记录数据模型
                PaperItemRecordSync *record = [[PaperItemRecordSync alloc] init];
                record.Id = [rs stringForColumn:@"id"];
                record.paperRecordId = [rs stringForColumn:@"paperRecordId"];
                record.structureId = [rs stringForColumn:@"structureId"];
                record.itemId = [rs stringForColumn:@"itemId"];
                record.content = [PaperUtils decryptPaperContentWithHex:[rs stringForColumn:@"content"] andPassword:record.Id];
                record.answer = [rs stringForColumn:@"answer"];
                record.status = [rs intForColumn:@"status"];
                record.score = [rs doubleForColumn:@"score"];
                record.useTimes = [rs intForColumn:@"useTimes"];
                record.createTime = [_dtFormatter dateFromString:[rs stringForColumn:@"createTime"]];
                record.lastTime = [_dtFormatter dateFromString:[rs stringForColumn:@"lastTime"]];
                //添加到结果数组
                [arrays addObject:record];
            }
            [rs close];
        }];
        //检查是否查询到需要上传的数据
        if(!arrays || arrays.count == 0)return;
        //更新状态
        static NSString *update_sql = @"UPDATE tbl_itemRecords SET sync = 1 WHERE id = ?";
        void(^asyncUpdateStatus)(NSString *) = ^(NSString *recordId){
            //异步线程更新试题记录状态
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSLog(@"异步线程更新试题[%@]记录状态...",recordId);
                if(_dbQueue && recordId && recordId.length > 0){
                    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                        @try {
                            [db executeUpdate:update_sql,recordId];
                        }
                        @catch (NSException *exception) {
                            *rollback = YES;
                            NSLog(@"异步线程更新试题[%@]记录状态异常:%@",recordId, exception);
                        }
                    }];
                }
            });
        };
        //异步线程上传试题记录
        void(^asyncUploadHandler)(PaperItemRecordSync *) = ^(PaperItemRecordSync *record){
            if(!record || !record.Id || record.Id.length == 0)return;
            //异步线程
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @try {
                    NSLog(@"异步线程上传试题记录:[%@=>%@]...",record.Id, record.itemId);
                    //检查网络
                    [HttpUtils checkNetWorkStatus:^(BOOL statusValue) {
                        if(!statusValue)return;//网络断开，不能上传
                        //初始化上传数据模型
                        AppClientPush *push = [[AppClientPush alloc] initWithRecords:@[record]];
                        //上传数据
                        [HttpUtils JSONDataWithUrl:_kAPP_API_PAPERITEMRECORDS_URL method:HttpUtilsMethodPOST
                                        parameters:[push serialize] progress:nil success:^(NSDictionary *result) {
                                            JSONCallback *callback = [JSONCallback callbackWithDict:result];
                                            if(callback.success){
                                                //上传成功，更新同步状态
                                                asyncUpdateStatus(record.Id);
                                            }else{
                                                NSLog(@"上传试题记录[%@,%@]失败:%@", record.Id,record.itemId, callback.msg);
                                            }
                                        } fail:^(NSString *err) {
                                            NSLog(@"异步线程上传试题记录[%@=>%@]失败:%@",record.Id, record.itemId, err);
                                        }];
                    }];
                }
                @catch (NSException *exception) {
                    NSLog(@"异步线程上传试题记录[%@=>%@]时异常:%@",record.Id, record.itemId, exception);
                }
            });
        };
        //开始网络数据传输
        for(PaperItemRecordSync *model in arrays){
            if(!model)continue;
            //按条上传试题记录
            asyncUploadHandler(model);
        }
    }
    @catch (NSException *exception) {
         NSLog(@"上传试题记录数据异常:%@", exception);
    }
}
@end
