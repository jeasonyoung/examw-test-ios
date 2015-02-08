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

#define __k_login_auth_alter_title @"用户登录"//登录窗口
#define __k_login_auth_alter_account @"用户名"//
#define __k_login_auth_alter_account_len 4//用户名长度（4-20）
#define __k_login_auth_alter_password @"密码"//
#define __k_login_auth_alter_btn_login_title @"登录"//登录标题
#define __k_login_auth_alter_btn_register_title @"注册"//注册标题
#define __k_login_auth_alter_error_account @"请输入用户名！"//
#define __k_login_auth_alter_error_password @"请输入密码"//

#define __k_login_auth_net_error @"网络故障 "//
#define __k_login_auth_net_account_error @"用户名不存在！"//联网验证
#define __k_login_auth_net_password_error @"密码不正确！"
#define __k_login_auth_local_account_error @"用户名不存在，请联网后再试！"//本地验证
#define __k_login_auth_local_password_error @"密码不正确，请联网后再试"

//用户登录验证实现类
@implementation LoginViewController (UserLogin)

MBProgressHUD *_authenWaitHud;
UIAlertController *_alterController;

#pragma mark 登录界面
-(void)alterLoginViewWithMessage:(NSString *)msg Account:(NSString *)account{
    _alterController = [UIAlertController alertControllerWithTitle:__k_login_auth_alter_title
                                                           message:msg
                                                    preferredStyle:UIAlertControllerStyleAlert];
    //用户名
    [_alterController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = __k_login_auth_alter_account;
        //添加通知，监听的用户名内容的变化
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(accountTextFieldTextDidChangeNotification:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:textField];
        if(account && account.length > 0){ textField.text = account; }
     }];
    //密码
    [_alterController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = __k_login_auth_alter_password;
        textField.secureTextEntry = YES;
    }];
    //注册按钮
    UIAlertAction *btnRegister = [UIAlertAction actionWithTitle:__k_login_auth_alter_btn_register_title
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction *action) {//注册
                                                                //移除用户名输入框的监听
                                                                [self removeAccountTextFieldObserver];
                                                                [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
                                                                NSLog(@"注册...");
                                                         }];
    //登录按钮
    UIAlertAction *btnLogin = [UIAlertAction actionWithTitle:__k_login_auth_alter_btn_login_title
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action){//登录
                                                            //启动等待动画
                                                            if(!_authenWaitHud){//惰性加载
                                                                _authenWaitHud = [[MBProgressHUD alloc] init];
                                                                _authenWaitHud.labelText = @"正在登录...";
                                                                _authenWaitHud.dimBackground = YES;//使背景成黑灰色，让MBProgressHUD成高亮显示
                                                                _authenWaitHud.square = YES;//设置显示框的高度和宽度一样
                                                                //_authenWaitHud.mode = MBProgressHUDModeAnnularDeterminate;
                                                                [self.view addSubview:_authenWaitHud];
                                                            }
                                                            [_authenWaitHud show:YES];
                                                            //移除用户名输入框的监听
                                                            [self removeAccountTextFieldObserver];
                                                            //登录验证
                                                            UITextField *tfAccount = [_alterController.textFields objectAtIndex:0],
                                                                        *tfPassword = [_alterController.textFields objectAtIndex:1];
                                                            LoginData *login = [[LoginData alloc] init];
                                                            login.account = [tfAccount.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                                            login.password = [tfPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                                            if(login.account.length == 0){//账号为空
                                                                //关闭等待动画
                                                                [_authenWaitHud hide:YES];
                                                                //弹出登录框
                                                                [self alterLoginViewWithMessage:__k_login_auth_alter_error_account Account:nil];
                                                                return;
                                                            }
                                                            if(login.password.length == 0){//密码为空
                                                                //关闭等待动画
                                                                [_authenWaitHud hide:YES];
                                                                //弹出登录框
                                                                [self alterLoginViewWithMessage:__k_login_auth_alter_error_password Account:login.account];
                                                                return;
                                                            }
                                                            //验证
                                                            [self authentication:login];
                                                        }];
    btnLogin.enabled = (account && account.length > 0);
    //添加到alert
    [_alterController addAction:btnRegister];
    [_alterController addAction:btnLogin];
    //弹出
    [self presentViewController:_alterController animated:YES completion:nil];
}
//处理监听用户名内容的变化
-(void)accountTextFieldTextDidChangeNotification:(NSNotification *)notification{
    UITextField *tf = notification.object;
    if(tf && _alterController){//用户名长度
        NSArray *actions = _alterController.actions;
        if(actions.count > 0){
            ((UIAlertAction *)[actions objectAtIndex:1]).enabled = tf.text.length >= __k_login_auth_alter_account_len;
        }
    }
}
//移除用户名输入框的监听
-(void)removeAccountTextFieldObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:nil];
}
#pragma mark 用户验证
-(void)authentication:(LoginData *)login{
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
                                     userAccount.version = _kAppClientVersion;
                                     //保存为当前用户
                                     [userAccount saveForCurrent];
                                     //关闭等待动画
                                     [_authenWaitHud hide:YES];
                                     //跳转到入口控制器
                                     [self goToMainViewController];
                                 }else{//验证失败
                                     [_authenWaitHud hide:YES];//关闭等待动画
                                     //[self createAlterLoginViewWithMessage:callback.msg Account:login.account];
                                     [self alterLoginViewWithMessage:callback.msg Account:login.account];
                                 }
                                }
                                Fail:^(NSString *error) {//网络故障
                                    NSLog(@"发生网络故障=>%@",error);
                                    [_authenWaitHud hide:YES];//关闭等待动画
                                    [self alterLoginViewWithMessage:[NSString stringWithFormat:@"%@%@",__k_login_auth_net_error,error]
                                                                  Account:login.account];//弹出登录
                                }];
}
//本地验证
-(void)localAuthentication:(LoginData *)login{
    //加载本地存储的用户信息
    UserAccountData *userAccount = [UserAccountData userWithAcount:login.account];
    if(!userAccount){//用户名不存在
        [_authenWaitHud hide:YES];//关闭等待动画
        [self alterLoginViewWithMessage:__k_login_auth_local_account_error Account:login.account];//弹出登录
        return;
    }
    if(![userAccount.password isEqualToString:login.password]){//密码错误
        [_authenWaitHud hide:YES];//关闭等待动画
        [self alterLoginViewWithMessage:__k_login_auth_local_password_error Account:login.account];//弹出登录
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
