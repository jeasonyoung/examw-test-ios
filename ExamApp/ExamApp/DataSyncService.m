//
//  DataSyncService.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "DataSyncService.h"
#import "AppConstant.h"
#import "AppClientSync.h"
#import "UserAccountData.h"

#import "HttpUtils.h"
#import "JSONCallback.h"

#import <FMDB/FMDatabaseQueue.h>
#import "ExamDataDao.h"

#define __k_datasyncservice_err_user @"未登录不能同步数据!"
#define __k_datasyncservice_err_code @"未注册不能同步数据!"
#define __k_datasyncservice_err_dbPath @"加载本地数据库异常:"
//数据同步服务成员变量
@interface DataSyncService(){
    NSString *_dbPath;
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
    _dbPath = [current loadDatabasePath:&err];
    if(!_dbPath && err){
        if(result){
            result([NSString stringWithFormat:@"%@ %@",__k_datasyncservice_err_dbPath, err]);
        }
        return;
    }
    AppClientSync *syncReq = [[AppClientSync alloc] init];
    syncReq.code = current.registerCode;
    //同步考试科目数据
    [self syncExamsWithReq:syncReq Result:^(NSString *r) {
        if(result){
            result(r);
        }
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
                                         [self syncExamsToLocalDbWithData:(NSDictionary *)callback.data];
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
#pragma mark 数据存储到本地Sqlite数据库
-(void)syncExamsToLocalDbWithData:(NSDictionary *)data{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:_dbPath];
    [queue inDatabase:^(FMDatabase *db) {
        //同步数据到本地数据库
        [[[ExamDataDao alloc] initWithDb:db] syncWithData:data];
    }];
}
@end