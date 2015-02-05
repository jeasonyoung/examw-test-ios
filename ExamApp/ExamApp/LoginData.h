//
//  LoginData.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppClient.h"
//登录数据
@interface LoginData : AppClient
//用户名
@property(nonatomic,copy)NSString *account;
//密码
@property(nonatomic,copy)NSString *password;
@end