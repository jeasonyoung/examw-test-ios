//
//  ProductRegisterModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ProductRegisterModel.h"
#import "AppDelegate.h"
#import "UserAccount.h"

#define __kProductRegisterModel_keys_code @"code"
#define __kProductRegisterModel_keys_userId @"userId"

//应用产品注册数据模型(用于到服务器端验证)实现
@implementation ProductRegisterModel

#pragma mark 初始化
-(instancetype)initWithCode:(NSString *)code{
    if(self = [super init]){
        _code = code;
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if(app && app.currentUser){
            _userId = app.currentUser.userId;
        }
    }
    return self;
}

#pragma 重载初始化
-(instancetype)init{
    return [self initWithCode:nil];
}

#pragma mark 重载序列化
-(NSDictionary *)serialize{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
    [dict addEntriesFromDictionary:@{__kProductRegisterModel_keys_userId:(_userId ? _userId : @""),
                                     __kProductRegisterModel_keys_code:(_code ? _code : @"")}];
    NSLog(@"产品注册JSON:%@", dict);
    return dict;
}

@end
