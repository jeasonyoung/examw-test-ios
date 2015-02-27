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

#define __k_datasyncservice_err_user @"未登录不能同步数据!"
#define __k_datasyncservice_err_code @"未注册不能同步数据!"

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
                                 NSLog(@"success => %@",data);
                             } Fail:^(NSString *fail) {
                                 if(result){
                                     result(fail);
                                 }
                             }];
}
@end