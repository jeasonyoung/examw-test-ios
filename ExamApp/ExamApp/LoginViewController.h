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
//创建登录界面
-(void)createAlterLoginViewWithMessage:(NSString *)msg Account:(NSString *)account;
//跳转到根视图控制器
-(void)goToRootViewController;
@end