//
//  DataSyncService.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "DataSyncService.h"
#import "AppClientSync.h"
#import "UserAccountData.h"

#import "HttpUtils.h"
#import "JSONCallback.h"

#import <FMDB/FMDatabaseQueue.h>
#import "ExamDataDao.h"
#import "PaperDataDao.h"

#define __k_datasyncservice_err_user @"未登录不能同步数据!"
#define __k_datasyncservice_err_code @"未注册不能同步数据!"
#define __k_datasyncservice_err_dbPath @"加载本地数据库异常:"
//数据同步服务成员变量
@interface DataSyncService(){
    FMDatabaseQueue *_queue;
}
@end
//数据同步服务实现
@implementation DataSyncService
#pragma mark 同步数据
-(void)sync:(void (^)(NSString *))result{
    UserAccountData *current = [UserAccountData currentUser];
    if(!current){
        result(__k_datasyncservice_err_user);
        return;
    }
    if(!current.registerCode || current.registerCode.length == 0){
        result(__k_datasyncservice_err_code);
        return;
    }
    NSError *err;
    NSString *dbPath = [current loadDatabasePath:&err];
    if(!dbPath && err){
        if(result){
            result([NSString stringWithFormat:@"%@ %@",__k_datasyncservice_err_dbPath, err]);
        }
        return;
    }
    AppClientSync *syncReq = [[AppClientSync alloc] init];
    syncReq.code = current.registerCode;
    if(!_queue){
        _queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    //同步考试科目数据
    [self syncExamsWithReq:syncReq Result:^(NSString *r) {
        if(r){
            if(result)result(r);
            return;
        }
        //同步试卷数据
        [self syncPapersWithReq:syncReq Result:^(NSString *r) {
            if(result){
                result(r);
            }
        }];
    }];
}
#pragma mark 同步考试科目数据
-(void)syncExamsWithReq:(AppClientSync *)req Result:(void(^)(NSString *))result{
    [HttpUtils JSONDataDigestWithUrl:_kAppClientSyncExamsUrl
                              Method:HttpUtilsMethodPOST
                          Parameters:[req serializeJSON]
                            Username:_kAppClientUserName
                            Password:_kAppClientPassword
                             Success:^(NSDictionary *data) {
                                 JSONCallback *callback = [JSONCallback callbackWithDictionary:data];
                                 if(!callback.success){
                                     if(result){
                                         result(callback.msg);
                                     }
                                     return;
                                 }
                                 //NSLog(@"success => %d",[callback.data isKindOfClass:[NSDictionary class]]);
                                 if([callback.data isKindOfClass:[NSDictionary class]]){
                                     @try {
                                         //数据库操作
                                         [_queue inDatabase:^(FMDatabase *db) {
                                             //同步数据到本地数据库
                                             [[[ExamDataDao alloc] initWithDb:db] syncWithData:(NSDictionary *)callback.data];
                                         }];
                                         if(result){
                                             result(nil);
                                         }
                                     }
                                     @catch (NSException *exception) {
                                         if(result){
                                             result([exception name]);
                                         }
                                     }
                                 }
                             } Fail:^(NSString *fail) {
                                 if(result){
                                     result(fail);
                                 }
                             }];
}
#pragma mark 同步试卷数据
-(void)syncPapersWithReq:(AppClientSync *)req Result:(void(^)(NSString *))result{
    if(_queue){//数据库队列
        [_queue inDatabase:^(FMDatabase *db) {
            //初始化试卷数据操作对象
            PaperDataDao *paperDao = [[PaperDataDao alloc] initWithDb:db];
            //加载更新起始时间
            req.startTime = [paperDao loadLastSyncTime];
            //从服务器获取数据
            [HttpUtils JSONDataDigestWithUrl:_kAppClientSyncPapersUrl
                                      Method:HttpUtilsMethodPOST
                                  Parameters:[req serializeJSON]
                                    Username:_kAppClientUserName
                                    Password:_kAppClientPassword
                                     Success:^(NSDictionary *data) {
                                         //反馈数据反序列化
                                         JSONCallback *callback = [JSONCallback callbackWithDictionary:data];
                                         if(!callback.success){//下载数据发生异常
                                             if(result)result(callback.msg);
                                             return;
                                         }
                                         if([callback.data isKindOfClass:[NSArray class]]){//反馈数据格式为数组集合
                                            [_queue inDatabase:^(FMDatabase *db){
                                                NSString *err;
                                                @try {
                                                    //数据存储到本地数据库
                                                    PaperDataDao *dao = [[PaperDataDao alloc] initWithDb:db];
                                                    [dao syncWithData:(NSArray *)callback.data];
                                                }
                                                @catch (NSException *exception) {
                                                    err = [exception description];
                                                }
                                                @finally{
                                                    if(result)result(err);
                                                }
                                            }];
                                         }
                                        }
                                        Fail:^(NSString *err) {
                                            if(err && result){
                                                result(err);
                                            }
                                        }];
        }];
    }
}
#pragma mark 释放内存
-(void)dealloc{
    if(_queue){
        [_queue close];
    }
}
@end