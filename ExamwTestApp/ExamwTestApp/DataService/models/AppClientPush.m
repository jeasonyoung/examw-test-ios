//
//  AppClientPush.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AppClientPush.h"
#import "AppDelegate.h"
#import "UserAccount.h"

//客户端数据推送实现
@implementation AppClientPush

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        //初始化赋值
        [self setupInitcomponent];
    }
    return self;
}

#pragma mark 初始化
-(instancetype)initWithRecords:(NSArray *)records{
    if((self = [super init]) && records && records.count > 0){
        //初始化赋值
        [self setupInitcomponent];
    }
    return self;
}

//初始化组件
-(void)setupInitcomponent{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    if(app && app.currentUser){//用户是否登录
        UserAccount *ua = app.currentUser;
        //注册码
        _code = ua.regCode;
        //当前用户ID
        _userId = ua.userId;
    }
}

#pragma mark 重载序列化
-(NSDictionary *)serialize{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
    //添加注册码/当前用户
    [dict addEntriesFromDictionary:@{@"code":(_code ? _code : @""),
                                     @"userId":(_userId ? _userId : @"")}];
    NSMutableArray *recordArrays;
    if(_records && _records.count > 0){
        recordArrays = [NSMutableArray arrayWithCapacity:_records.count];
        //循环序列化
        for(id record in _records){
            if(!record || (record == [NSNull null])) continue;
            if([record conformsToProtocol:@protocol(JSONSerialize)]){
                NSDictionary *recordDict = [record serialize];
                if(recordDict && recordDict.count > 0){
                    [recordArrays addObject:recordDict];
                }
            }
        }
    }
    //添加上传记录
    [dict setObject:((recordArrays && recordArrays.count > 0) ? recordArrays : @[]) forKey:@"records"];
    //返回
    return dict;
}
@end
