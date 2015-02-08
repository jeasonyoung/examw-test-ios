//
//  LoginViewController.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/2.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
//登录视图控制器
@interface LoginViewController : UIViewController
//创建登录框
-(void)createLoginAlterWithAccount:(NSString *)account;
//跳转到根视图控制器
-(void)goToRootViewController;
@end