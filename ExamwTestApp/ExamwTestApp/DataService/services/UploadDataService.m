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

#import "DigestHTTPJSONProvider.h"

#import "AppClientPush.h"
#import "FavoriteSync.h"
#import "PaperRecordSync.h"
#import "PaperItemRecordSync.h"

#import "PaperUtils.h"
#import "JSONCallback.h"
//上传数据服务成员变量
@interface UploadDataService (){
    DigestHTTPJSONProvider *_provider;
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
        //初始化网络提供者
        _provider = [DigestHTTPJSONProvider shareProvider];
    }
    return self;
}

#pragma mark 上传数据
-(void)upload{
    //设置可以在后台运行
    _provider.shouldExecuteAsBackgroundTask = YES;
    //检查网络
    [_provider checkNetworkStatus:^(BOOL statusValue) {
        if(!statusValue){
            NSLog(@"网络不可用，不能上传数据...");
            return;
        }
        //1.上传收藏数据
        [self uploadFavorites];
        //2.上传试卷记录
        [self uploadPaperRecords];
        //3.上传做题记录
        [self uploadPaperItemRecords];
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
        //初始化上传数据模型
        AppClientPush *push = [[AppClientPush alloc] initWithRecords:arrays];
        //开始网络数据传输
        [_provider postDataWithUrl:_kAPP_API_FAVORITES_URL parameters:[push serialize] success:^(NSDictionary *result) {
            JSONCallback *callback = [JSONCallback callbackWithDict:result];
            if(callback.success){
                NSArray *failArrays = nil;
                if(callback.data && [callback.data isKindOfClass:[NSArray class]]){
                    failArrays = (NSArray *)callback.data;
                    NSLog(@"服务器更新失败的收藏:%@",failArrays);
                }
                //循环更新同步状态
                static NSString *update_sql = @"UPDATE tbl_favorites SET sync = 1 WHERE id = ?";
                [_dbQueue inDatabase:^(FMDatabase *db) {
                    for(FavoriteSync *fav in arrays){
                        if(failArrays && failArrays.count > 0 && [failArrays containsObject:fav.Id]){
                            continue;
                        }
                       [db executeUpdate:update_sql, fav.Id];
                    }
                }];
            }else{
                 NSLog(@"上传收藏数据失败:%@", callback.msg);
            }
        } fail:^(NSString *err) {
            NSLog(@"上传收藏数据失败:%@", err);
        }];
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
        //开始网络数据传输
        
        //初始化上传数据模型
        AppClientPush *push = [[AppClientPush alloc] initWithRecords:arrays];
        //上传数据
        [_provider postDataWithUrl:_kAPP_API_PAPERRECORDS_URL parameters:[push serialize] success:^(NSDictionary *result) {
            JSONCallback *callback = [JSONCallback callbackWithDict:result];
            if(callback.success){
                NSArray *failArrays = nil;
                if(callback.data && [callback.data isKindOfClass:[NSArray class]]){
                    failArrays = (NSArray *)callback.data;
                    NSLog(@"服务器更新失败的试卷记录:%@",failArrays);
                }
                //更新状态
                static NSString *update_sql = @"UPDATE tbl_paperRecords SET sync = 1 WHERE id = ?";
                [_dbQueue inDatabase:^(FMDatabase *db) {
                    //循环更新
                    for(PaperRecordSync *record in arrays){
                        if(failArrays && failArrays.count > 0 && [failArrays containsObject:record.Id]){
                            continue;
                        }
                        [db executeUpdate:update_sql, record.Id];
                    }
                }];
            }else{
                NSLog(@"上传试卷记录失败:%@",callback.msg);
            }
        } fail:^(NSString *err) {
             NSLog(@"上传试卷记录失败:%@",err);
        }];
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
        //开始网络数据传输
        
        //初始化上传数据模型
        AppClientPush *push = [[AppClientPush alloc] initWithRecords:arrays];
        //上传数据
        [_provider postDataWithUrl:_kAPP_API_PAPERITEMRECORDS_URL parameters:[push serialize] success:^(NSDictionary *result) {
            JSONCallback *callback = [JSONCallback callbackWithDict:result];
            if(callback.success){
                NSArray *failArrays = nil;
                if(callback.data && [callback.data isKindOfClass:[NSArray class]]){
                    failArrays = (NSArray *)callback.data;
                    NSLog(@"服务器更新失败的试题记录:%@",failArrays);
                }
                //更新状态
                static NSString *update_sql = @"UPDATE tbl_itemRecords SET sync = 1 WHERE id = ?";
                [_dbQueue inDatabase:^(FMDatabase *db) {
                    //循环更新
                    for(PaperItemRecordSync *record in arrays){
                        if(failArrays && failArrays.count > 0 && [failArrays containsObject:record.Id]){
                            continue;
                        }
                        [db executeUpdate:update_sql, record.Id];
                    }
                }];
            }else{
                NSLog(@"上传试题记录失败:%@",callback.msg);
            }
        } fail:^(NSString *err) {
            NSLog(@"上传试题记录失败:%@",err);
        }];
    }
    @catch (NSException *exception) {
         NSLog(@"上传试题记录数据异常:%@", exception);
    }
}
@end
