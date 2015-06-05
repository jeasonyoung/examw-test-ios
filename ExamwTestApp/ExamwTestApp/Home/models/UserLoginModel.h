//
//  UserLoginModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppClient.h"
//用户登录数据模型
@interface UserLoginModel : AppClient

//用户名
@property(nonatomic,copy)NSString *account;
//密码
@property(nonatomic,copy)NSString *password;

//初始化
-(instancetype)initWIthAccount:(NSString *)account password:(NSString *)pwd;

@end
