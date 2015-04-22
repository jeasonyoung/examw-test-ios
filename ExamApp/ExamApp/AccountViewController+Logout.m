//
//  AccountViewController+Logout.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/8.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AccountViewController+Logout.h"
#import "UserAccountData.h"
#import "MainViewController.h"

#define __kAccountViewController_logout_title @"确认"//弹出框标题
#define __kAccountViewController_logout_message @"您是否确认注销?"//弹出框消息
#define __kAccountViewController_logout_btnCancel @"取消"//取消按钮标题
#define __kAccountViewController_logout_btnSubmit @"确认"//确认按钮标题
//用户注销处理实现类
@implementation AccountViewController (Logout)
#pragma mark 用户注销
-(void)logoutWithAccount:(UserAccountData *)account{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:__kAccountViewController_logout_title
                                                   message:__kAccountViewController_logout_message
                                                  delegate:nil
                                         cancelButtonTitle:__kAccountViewController_logout_btnCancel
                                         otherButtonTitles:__kAccountViewController_logout_btnSubmit, nil];
    [alert show];
}
@end
