//
//  UserLoginModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "UserLoginModel.h"

#define __kUserLoginModel_keys_account @"account"//账号
#define __kUserLoginModel_keys_password @"password"//密码
//用户登录数据模型实现
@implementation UserLoginModel

#pragma mark 初始化
-(instancetype)initWIthAccount:(NSString *)account password:(NSString *)pwd{
    if(self = [super init]){
        _account = account;
        _password = pwd;
    }
    return self;
}

#pragma mark 重载序列化
-(NSDictionary *)serialize{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
    [dict addEntriesFromDictionary:@{__kUserLoginModel_keys_account:(_account ? _account : @""),
                                     __kUserLoginModel_keys_password:(_password ? _password : @"")}];
    NSLog(@"登录数据模型JSON:%@",dict);
    return dict;
}

@end
