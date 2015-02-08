//
//  LoginViewController+Register.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "LoginViewController.h"
@class RegisterData;
//用户注册
@interface LoginViewController (Register)<UITextFieldDelegate>
//安装注册面板
-(void)setupRegisterPanel;
//注册数据
-(void)registerWithUser:(RegisterData *)user;
@end
