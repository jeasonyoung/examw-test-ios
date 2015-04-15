//
//  LoginViewController+UserLogin.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import "LoginViewController+UserLogin.h"

#import "HttpUtils.h"
#import "LoginData.h"
#import "UserAccountData.h"
#import "JSONCallback.h"
#import "ChoiceProductsViewController.h"
#import "WaitForAnimation.h"
//#import "ETAlert.h"

#define __kLoginViewController_login_alterTitle @"用户登录"//登录窗口
#define __kLoginViewController_login_accountHolder @"用户名"//
#define __kLoginViewController_login_accountMinLen 4//用户名长度（4-20）
#define __kLoginViewController_login_passwordHolder @"密码"//

#define __kLoginViewController_login_btnLogin @"登录"//登录标题
#define __kLoginViewController_login_btnRegister @"注册"//注册标题

#define __kLoginViewController_login_waitting @"正在登录..."

#define __kLoginViewController_login_errorAccount @"请输入用户名"//
#define __kLoginViewController_login_errorPassword @"请输入密码"//

#define __kLoginViewController_login_errorNet @"网络故障: "//

#define __kLoginViewController_login_errorLocalAccount @"用户名不存在，请联网后再试"
#define __kLoginViewController_login_errorLocalPassword @"密码不正确，请联网后再试"


//用户登录验证实现类
@implementation LoginViewController (UserLogin)
//登录框
//ETAlert *loginAlert;
#pragma mark 登录界面
-(void)alterLoginViewWithMessage:(NSString *)msg Account:(NSString *)account{
    //初始化登陆框
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:__kLoginViewController_login_alterTitle
                                                   message:msg
                                                  delegate:self
                                         cancelButtonTitle:__kLoginViewController_login_btnRegister
                                         otherButtonTitles:__kLoginViewController_login_btnLogin, nil];
    //设置输入框
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    //设置用户名输入框
    UITextField *tfUser = [alert textFieldAtIndex:0];
    if(tfUser){
        tfUser.placeholder = __kLoginViewController_login_accountHolder;
        if(account && account.length > 0){
            tfUser.text = account;
        }
    }
    //设置密码输入框
    UITextField *tfPwd = [alert textFieldAtIndex:1];
    if(tfPwd){
        tfPwd.placeholder = __kLoginViewController_login_passwordHolder;
    }
    //弹出
    [alert show];
}
#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"buttonIndex=>%d",buttonIndex);
    if(buttonIndex == 0)return;
    //获取账号密码
    UITextField *tfUser = [alertView textFieldAtIndex:0],
    *tfPwd = [alertView textFieldAtIndex:1];
    //账号
    if(!tfUser || tfUser.text.length == 0){
        //弹出登录框
        [self alterLoginViewWithMessage:__kLoginViewController_login_errorAccount Account:nil];
        return;
    }
    //密码
    if(!tfPwd || tfPwd.text.length == 0){
        //弹出登录框
        [self alterLoginViewWithMessage:__kLoginViewController_login_errorPassword Account:tfUser.text];
        return;
    }
    //if(!tfUser || tfUser.text.length == 0 || !tfPwd || tfPwd.text.length == 0)return;
    //初始化登录等待动画
    WaitForAnimation *loginWait = [[WaitForAnimation alloc]initWithView:self.view WaitTitle:__kLoginViewController_login_waitting];
    //开启等待动画
    [loginWait show];
    //初始化账户对象
    LoginData *login = [[LoginData alloc] init];
    //获取账号
    login.account = [tfUser.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //获取密码
    login.password = [tfPwd.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //用户名为空
    if(!login.account || login.account.length == 0){
        //关闭等待动画
        [loginWait hide];
        //弹出登录框
        [self alterLoginViewWithMessage:__kLoginViewController_login_errorAccount Account:nil];
        return;
    }
    //密码为空
    if(!login.password || login.password.length == 0){
        //关闭等待动画
        [loginWait hide];
        //弹出登录框
        [self alterLoginViewWithMessage:__kLoginViewController_login_errorPassword Account:login.account];
        return;
    }
    //验证
    [self authentication:login WaitAnimation:loginWait];
}
#pragma mark 用户验证
-(void)authentication:(LoginData *)login WaitAnimation:(WaitForAnimation *)loginWait{
    //检测网络
    [HttpUtils netWorkStatus:^(BOOL statusValue) {
        if(statusValue){
            NSLog(@"netWorkStatus:有网络");
            //有网络时
            [self networkAuthentication:login WaitAnimation:loginWait];
        }else{
            NSLog(@"netWorkStatus:无网络");
            //没有网络时
            [self localAuthentication:login WaitAnimation:loginWait];
        }
    }];
}
//网络验证用户
-(void)networkAuthentication:(LoginData *)login WaitAnimation:(WaitForAnimation *)loginWait{
    AppClientSettings *appSettings = [AppClientSettings clientSettings];
    //调用网络
    [HttpUtils JSONDataDigestWithUrl:appSettings.loginPostUrl//_kAppClientUserLoginUrl
                              Method:HttpUtilsMethodPOST
                          Parameters:[login serializeJSON]
                            Username:appSettings.digestUsername//_kAppClientUserName
                            Password:appSettings.digestPassword//_kAppClientPassword
                             Success:^(NSDictionary *json) {//网络交互成功
                                 //关闭等待动画
                                 if(loginWait){
                                     [loginWait hide];
                                 }
                                 //解析反馈数据
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
                                     userAccount.version = appSettings.appClientVersion;//_kAppClientVersion;
                                     //保存为当前用户
                                     [userAccount saveForCurrent];
                                     
                                     //跳转到入口控制器
                                     [self goToMainViewController];
                                 }else{//验证失败
                                     [self alterLoginViewWithMessage:callback.msg Account:login.account];
                                 }
                                }
                                Fail:^(NSString *error) {//网络故障
                                    //NSLog(@"发生网络故障=>%@",error);
                                    //关闭等待动画
                                    if(loginWait){
                                        [loginWait hide];
                                    }
                                    //登录框
                                    [self alterLoginViewWithMessage:[NSString stringWithFormat:@"%@%@",__kLoginViewController_login_errorNet,error]
                                                                  Account:login.account];//弹出登录
                                }];
}
//本地验证
-(void)localAuthentication:(LoginData *)login WaitAnimation:(WaitForAnimation *)loginWait{
    //加载本地存储的用户信息
    UserAccountData *userAccount = [UserAccountData userWithAcount:login.account];
    //用户名不存在
    if(!userAccount){
        //关闭等待动画
        if(loginWait){
            [loginWait hide];
        }
        //弹出登录
        [self alterLoginViewWithMessage:__kLoginViewController_login_errorLocalAccount Account:login.account];
        return;
    }
    //密码错误
    if(![userAccount.password isEqualToString:login.password]){
        //关闭等待动画
        if(loginWait){
            [loginWait hide];
        }
        //弹出登录
        [self alterLoginViewWithMessage:__kLoginViewController_login_errorLocalPassword Account:login.account];
        return;
    }
    //验证通过
    //保存为当前用户
    [userAccount saveForCurrent];
    //关闭等待动画
    if(loginWait){
        [loginWait hide];
    }
    //跳转到入口控制器
    [self goToMainViewController];
}
//跳转到入口控制器
-(void)goToMainViewController{
    //[[[MainViewController alloc] init] gotoController];
    [[[ChoiceProductsViewController alloc]init]gotoController];
}
@end
