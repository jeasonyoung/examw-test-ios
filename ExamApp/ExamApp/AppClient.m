//
//  AppClient.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AppClient.h"
#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>

#define __k_appclient_parameters_id @"clientId"
#define __k_appclient_parameters_name @"clientName"
#define __k_appclient_parameters_version @"clientVersion"
#define __k_appclient_parameters_typeCode @"clientTypeCode"
#define __k_appclient_parameters_machine @"clientMachine"
#define __k_appclient_parameters_productId @"productId"

//应用客户端基类实现类
@implementation AppClient
#pragma mark 初始化函数
-(instancetype)init{
    if(self = [super init]){
        //初始化
        appSettings = [AppClientSettings clientSettings];
        //客户端唯一标示
        _clientId = appSettings.appClientID;
        //客户端名称
        _clientName = appSettings.appClientName;
        //软件版本
        _clientVersion = [[NSNumber numberWithDouble:appSettings.appClientVersion] stringValue];
        //客户端类型代码
        _clientTypeCode = [[NSNumber numberWithInt:appSettings.appClientTypeCode] stringValue];
        //产品ID
        _productId = appSettings.appClientProductID;
        //设备唯一标示(先获取广告标示)
        self.clientMachine = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        if(!self.clientMachine){//当无法获取广告标示时使用idfv
            self.clientMachine = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        }
    }
    return self;
}
#pragma mark 序列化
-(NSDictionary *)serializeJSON{
    return @{__k_appclient_parameters_id:self.clientId ? self.clientId : @"",
             __k_appclient_parameters_name:self.clientName ? self.clientName : @"",
             __k_appclient_parameters_version:self.clientVersion ? self.clientVersion : [NSNumber numberWithInt:0],
             __k_appclient_parameters_typeCode:(self.clientTypeCode ? self.clientTypeCode : @""),
             __k_appclient_parameters_machine:(self.clientMachine ? self.clientMachine : @""),
             __k_appclient_parameters_productId:(self.productId ? self.productId : @"")};
}
@end
