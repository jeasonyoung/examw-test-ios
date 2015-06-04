//
//  MyUserRegisterModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppClient.h"
//用户注册数据模型
@interface UserRegisterModel : AppClient

//用户名
@property(nonatomic,copy)NSString *account;
//密码
@property(nonatomic,copy)NSString *password;
//重复密码
@property(nonatomic,copy)NSString *repassword;
//真实姓名
@property(nonatomic,copy)NSString *username;
//电子邮箱
@property(nonatomic,copy)NSString *email;
//手机号码
@property(nonatomic,copy)NSString *phone;
@end
