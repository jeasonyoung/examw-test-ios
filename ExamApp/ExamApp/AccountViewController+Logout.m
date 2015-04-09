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
#import "ETAlert.h"

#define __k_account_view_logout_alter_title @"确认"//弹出框标题
#define __k_account_view_logout_alter_message @"您是否确认注销?"//弹出框消息
#define __k_account_view_logout_alter_btnCancel @"取消"//取消按钮标题
#define __k_account_view_logout_alter_btnSubmit @"确认"//确认按钮标题
//用户注销处理实现类
@implementation AccountViewController (Logout)
#pragma mark 用户注销
-(void)logoutWithAccount:(UserAccountData *)account{
    //初始化弹出框
    ETAlert *alert = [[ETAlert alloc]initWithTitle:__k_account_view_logout_alter_title
                                           Message:__k_account_view_logout_alter_message];
    //添加确定按钮
    [alert addConfirmActionWithTitle:__k_account_view_logout_alter_btnSubmit Handler:^(UIAlertAction *action) {
        //清空当前用户信息
        [account clean];
        //重新加载主界面
        [[[MainViewController alloc] init] gotoController];
    }];
    //添加取消按钮
    [alert addCancelActionWithTitle:__k_account_view_logout_alter_btnCancel Handler:nil];
    //弹出弹出框
    [alert showWithController:self];
}
@end
