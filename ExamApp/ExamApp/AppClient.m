//
//  AppClient.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AppClient.h"

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
        [self setClientId:_kAppClientID];
        [self setClientName:_kAppClientName];
        [self setClientVersion:[[NSNumber numberWithDouble:_kAppClientVersion] stringValue]];
    }
    return self;
}
#pragma mark 序列化
-(NSDictionary *)serializeJSON{
    return @{__k_appclient_parameters_id:self.clientId,
             __k_appclient_parameters_name:self.clientName,
             __k_appclient_parameters_version:self.clientVersion,
             __k_appclient_parameters_typeCode:(self.clientTypeCode ? self.clientTypeCode : @""),
             __k_appclient_parameters_machine:(self.clientMachine ? self.clientMachine : @""),
             __k_appclient_parameters_productId:(self.productId ? self.productId : @"")};
}
@end