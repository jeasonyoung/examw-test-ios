//
//  AppClient.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AppClient.h"
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>

#import "AppConstants.h"
#import "AppSettings.h"
#import "AppDelegate.h"
//应用客户端实现
@implementation AppClient

#pragma mark 初始化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if(self = [super init]){
        [self initializationComponents];
    }
    return self;
}

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        [self initializationComponents];
    }
    return self;
}

//初始化组件
-(void)initializationComponents{
    NSLog(@"初始化客户端同步配置信息...");
    //客户端唯一标示
    _clientId = __kAPP_ID;
    //客户端名称
    _clientName = [NSString stringWithFormat:__kAPP_NAME, __kAPP_VER];
    //客户端软件版本
    _clientVersion = [@__kAPP_VER stringValue];
    //客户端类型代码
    _clientTypeCode = [@__kAPP_TYPECODE stringValue];
    //设备唯一标示(优先广告标示)
    _clientMachine = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    if(!_clientMachine || _clientMachine.length == 0){//无法获取广告标示时取idfv
        _clientMachine = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    //获取应用设置
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(app && app.appSettings){
        _productId = app.appSettings.productId;
    }
}


#pragma mark 序列化
-(NSDictionary *)serialize{
     return @{@"clientId" : (_clientId ? _clientId : @""),
              @"clientName" : (_clientName ? _clientName : @""),
              @"clientVersion" : (_clientVersion ? _clientVersion : @""),
              @"clientTypeCode" : (_clientTypeCode ? _clientTypeCode : @""),
              @"clientMachine" : (_clientMachine ? _clientMachine : @""),
              @"productId" : (_productId ? _productId : @"")};
}
@end
