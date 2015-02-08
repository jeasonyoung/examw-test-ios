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

#define __k_account_view_logout_alter_title @"确认"//弹出框标题
#define __k_account_view_logout_alter_message @"您是否确认注销?"//弹出框消息
#define __k_account_view_logout_alter_cancel_title @"取消"//取消按钮标题
#define __k_account_view_logout_alter_ok_title @"确认"//确认按钮标题
//用户注销处理实现类
@implementation AccountViewController (Logout)
//弹出框
UIAlertController *_logoutAlterController;
#pragma mark 用户注销
-(void)logoutWithAccount:(UserAccountData *)account{
    if(!_logoutAlterController){//惰性加载
        _logoutAlterController = [UIAlertController alertControllerWithTitle:__k_account_view_logout_alter_title
                                                                     message:__k_account_view_logout_alter_message
                                                              preferredStyle:UIAlertControllerStyleAlert];
        
        //取消按钮
        UIAlertAction *btnCancel = [UIAlertAction actionWithTitle:__k_account_view_logout_alter_cancel_title
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
                                                              //取消
                                                              [self logoutAlterCancel:action];
                                                          }];
        //确定按钮
        UIAlertAction *btnOK = [UIAlertAction actionWithTitle:__k_account_view_logout_alter_title
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          //确定
                                                          [self logoutAlterSumbit:action Account:account];
                                                        }];
        //添加到控制器
        //添加取消按钮
        [_logoutAlterController addAction:btnCancel];
        //添加确定按钮
        [_logoutAlterController addAction:btnOK];
    }
    //弹出控制器
    [self presentViewController:_logoutAlterController animated:YES completion:nil];
}
//取消用户注销
-(void)logoutAlterCancel:(UIAlertAction *)sender{
    //弹出框消失
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"取消注销...");
}
//确定用户注销
-(void)logoutAlterSumbit:(UIAlertAction *)sender Account:(UserAccountData *)account{
    //清空当前用户信息
    [account clean];
    //弹出框消失
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    //重新加载主界面
    [[[MainViewController alloc] init] gotoController];
}
@end
