//
//  AppClientSync.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AppClientSync.h"
#import "AppDelegate.h"
#import "UserAccount.h"

//客户端同步请求数据模型实现
@implementation AppClientSync

#pragma mark 初始化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if(self = [super init]){
        [self setupSettings];
    }
    return self;
}

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        [self setupSettings];
    }
    return self;
}

//初始化组件
-(void)setupSettings{
    //是否忽略注册码
    _ignoreCode = NO;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(app && app.currentUser){
        _code = app.currentUser.regCode;
    }
}

#pragma mark 序列化
-(NSDictionary *)serialize{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
    //注册码
    [dict setObject:(_code ? _code : @"") forKey:@"code"];
    //忽略注册码
    [dict setObject:[NSNumber numberWithBool:_ignoreCode] forKey:@"ignoreCode"];
    //起始时间
    [dict setObject:(_startTime ? _startTime : @"") forKey:@"startTime"];
    
    NSLog(@"序列化客户端配置信息[%@]...",dict);
    
    return dict;
}

@end
