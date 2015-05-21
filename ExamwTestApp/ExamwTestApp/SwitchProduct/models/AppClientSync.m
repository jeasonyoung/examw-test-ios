//
//  AppClientSync.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AppClientSync.h"
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>

#import "AppConstants.h"
#import "AppSettings.h"
#import "AppDelegate.h"

//客户端同步请求数据模型实现
@implementation AppClientSync

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
    _clientName = __kAPP_NAME;
    //客户端软件版本
    _clientVersion = [@__kAPP_VER stringValue];
    //客户端类型代码
    _clientTypeCode = [@__kAPP_TYPECODE stringValue];
    //设备唯一标示(优先广告标示)
    _clientMachine = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    if(!_clientMachine || _clientMachine.length == 0){//无法获取广告标示时取idfv
        _clientMachine = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    //是否忽略注册码
    _ignoreCode = NO;
    //获取应用设置
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(app && app.appSettings){
        _productId = app.appSettings.productId;
    }
}

#pragma mark 序列化
-(NSDictionary *)serialize{
    NSDictionary *dict = @{@"clientId" : (_clientId ? _clientId : @""),
                           @"clientName" : (_clientName ? _clientName : @""),
                           @"clientVersion" : (_clientVersion ? _clientVersion : @""),
                           @"clientTypeCode" : (_clientTypeCode ? _clientTypeCode : @""),
                           @"clientMachine" : (_clientMachine ? _clientMachine : @""),
                           @"productId" : (_productId ? _productId : @""),
                           @"code" : (_code ? _code : @""),
                           @"ignoreCode" : [NSNumber numberWithBool:_ignoreCode],
                           @"startTime" : (_startTime ? _startTime : @"")};
    
    NSLog(@"序列化客户端配置信息[%@]...",dict);
    return dict;
}

@end
