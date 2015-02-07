//
//  LoginViewController+UserLogin.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "LoginViewController+UserLogin.h"
#import <MBProgressHUD/MBProgressHUD.h>

#import "HttpUtils.h"
#import "LoginData.h"
#import "UserAccountData.h"
#import "JSONCallback.h"
#import "MainViewController.h"

#define __k_login_auth_net_error @"网络故障 "//
#define __k_login_auth_net_account_error @"用户名不存在！"//联网验证
#define __k_login_auth_net_password_error @"密码不正确！"
#define __k_login_auth_local_account_error @"用户名不存在，请联网后再试！"//本地验证
#define __k_login_auth_local_password_error @"密码不正确，请联网后再试"

//用户登录验证实现类
@implementation LoginViewController (UserLogin)
MBProgressHUD *_authenWaitHud;
#pragma mark 用户验证
-(void)authentication:(LoginData *)login{
    //启动等待动画
    if(!_authenWaitHud){//惰性加载
        _authenWaitHud = [[MBProgressHUD alloc] init];
    }
    _authenWaitHud.labelText = @"正在登录...";
    _authenWaitHud.dimBackground = YES;//使背景成黑灰色，让MBProgressHUD成高亮显示
    _authenWaitHud.square = YES;//设置显示框的高度和宽度一样
    //_authenWaitHud.mode = MBProgressHUDModeAnnularDeterminate;
    [self.view addSubview:_authenWaitHud];
    [_authenWaitHud show:YES];
    //检测网络
    [HttpUtils netWorkStatus:^(BOOL statusValue) {
        if(statusValue){
            NSLog(@"netWorkStatus:有网络");
            //有网络时
            [self networkAuthentication:login];
        }else{
            NSLog(@"netWorkStatus:无网络");
            //没有网络时
            [self localAuthentication:login];
        }
    }];
}
//网络验证用户
-(void)networkAuthentication:(LoginData *)login{
    //调用网络
    [HttpUtils JSONDataDigestWithUrl:_kAppClientUserLoginUrl
                              Method:HttpUtilsMethodPOST
                          Parameters:[login serializeJSON]
                            Username:_kAppClientUserName
                            Password:_kAppClientPassword
                             Success:^(NSDictionary *json) {//网络交互成功
                                 JSONCallback *callback = [[JSONCallback alloc] initWithDictionary:json];
                                 if(callback.success){//验证成功
                                     //加载本地存储的用户信息
                                     UserAccountData *userAccount = [UserAccountData userWithAcount:login.account];
                                     if(!userAccount){
                                         userAccount = [[UserAccountData alloc] init];
                                     }
                                     //设置字段
                                     userAccount.account = login.account;
                                     userAccount.password = login.password;
                                     if(callback.data){
                                          userAccount.accountId = callback.data;
                                     }
                                     //保存为当前用户
                                     [userAccount saveForCurrent];
                                     //关闭等待动画
                                     [_authenWaitHud hide:YES];
                                     //跳转到入口控制器
                                     [self goToMainViewController];
                                 }else{//验证失败
                                     [_authenWaitHud hide:YES];//关闭等待动画
                                     [self createAlterLoginViewWithMessage:callback.msg Account:login.account];
                                 }
                                }
                                Fail:^(NSString *error) {//网络故障
                                    NSLog(@"发生网络故障=>%@",error);
                                    [_authenWaitHud hide:YES];//关闭等待动画
                                    [self createAlterLoginViewWithMessage:[NSString stringWithFormat:@"%@%@",__k_login_auth_net_error,error]
                                                                  Account:login.account];//弹出登录
                                }];
}
//本地验证
-(void)localAuthentication:(LoginData *)login{
    //加载本地存储的用户信息
    UserAccountData *userAccount = [UserAccountData userWithAcount:login.account];
    if(!userAccount){//用户名不存在
        [_authenWaitHud hide:YES];//关闭等待动画
        [self createAlterLoginViewWithMessage:__k_login_auth_local_account_error Account:login.account];//弹出登录
        return;
    }
    if(![userAccount.password isEqualToString:login.password]){//密码错误
        [_authenWaitHud hide:YES];//关闭等待动画
        [self createAlterLoginViewWithMessage:__k_login_auth_local_password_error Account:login.account];//弹出登录
        return;
    }
    //验证通过
    //保存为当前用户
    [userAccount saveForCurrent];
    //关闭等待动画
    [_authenWaitHud hide:YES];
    //跳转到入口控制器
    [self goToMainViewController];
}
//跳转到入口控制器
-(void)goToMainViewController{
    [[[MainViewController alloc] init] gotoController];
}
@end
