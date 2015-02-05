//
//  LoginData.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "LoginData.h"

#define __k_login_data_parameters_account @"account"//账号
#define __k_login_data_parameters_password @"password"//密码
//登录数据实现类
@implementation LoginData
#pragma mark 重载序列化数据
-(NSDictionary *)serializeJSON{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super serializeJSON]];
    //[dict setObject:self.account forKey:__k_login_data_parameters_account];
    //[dict setObject:self.password forKey:__k_login_data_parameters_password];
    [dict addEntriesFromDictionary:@{__k_login_data_parameters_account:self.account,
                                     __k_login_data_parameters_password:self.password}];
    return [dict copy];
}
@end