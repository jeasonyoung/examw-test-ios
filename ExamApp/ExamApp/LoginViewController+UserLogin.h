//
//  LoginViewController+UserLogin.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "LoginViewController.h"
@class LoginData;
//用户登录验证
@interface LoginViewController (UserLogin)
//登录界面
-(void)alterLoginViewWithMessage:(NSString *)msg Account:(NSString *)account;
//用户验证
//-(void)authentication:(LoginData *)login;
@end
