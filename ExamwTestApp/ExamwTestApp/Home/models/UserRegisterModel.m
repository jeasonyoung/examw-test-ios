//
//  MyUserRegisterModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "UserRegisterModel.h"
#import "AppConstants.h"

#define __kUserRegisterModel_keys_account @"account"//用户名
#define __kUserRegisterModel_keys_password @"password"//密码
#define __kUserRegisterModel_keys_username @"username"//真实姓名
#define __kUserRegisterModel_keys_email @"email"//电子邮箱
#define __kUserRegisterModel_keys_phone @"phone"//手机号
#define __kUserRegisterModel_keys_channel @"channel"//频道

//用户注册数据模型实现
@implementation UserRegisterModel

#pragma mark 重载序列化
-(NSDictionary *)serialize{
    NSDictionary *registers = @{__kUserRegisterModel_keys_account:(_account ? _account : @""),
                                __kUserRegisterModel_keys_password:(_password ? _password : @""),
                                __kUserRegisterModel_keys_username:(_username ? _username : @""),
                                __kUserRegisterModel_keys_email:(_email ? _email : @""),
                                __kUserRegisterModel_keys_phone:(_phone ? _phone : @""),
                                __kUserRegisterModel_keys_channel:__kAPP_API_CHANNEL};
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
    [dict addEntriesFromDictionary:registers];
    NSLog(@"用户注册数据JSON:%@",dict);
    return dict;
}

@end
