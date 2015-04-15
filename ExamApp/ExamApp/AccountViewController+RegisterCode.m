//
//  AccountViewController+RegisterCode.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/8.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AccountViewController+RegisterCode.h"
#import "UserAccountData.h"
#import "HttpUtils.h"
#import "AppRegisterCode.h"
#import "JSONCallback.h"
#import "WaitForAnimation.h"

#import "AppClientSettings.h"

#define __kAccountViewController_register_title @"软件注册码"//
#define __kAccountViewController_register_msg @"请输入软件注册码"//

#define __kAccountViewController_register_btnSubmit @"确定"//
#define __kAccountViewController_register_btnCancel @"取消"//

#define __kAccountViewController_register_waitting @"正在注册..."//

#define __kAccountViewController_register_alterTitle @"提示"//
#define __kAccountViewController_register_alterError @"无网络，请联网再试！"//

#define __kAccountViewController_register_registerCode @"registerCode"

//注册码处理分类
@implementation AccountViewController (RegisterCode)
UserAccountData *_account;
//注册码处理。
-(void)registerWithAccount:(UserAccountData *)account{
    _account = account;
    //初始化弹出框
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:__kAccountViewController_register_title
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:__kAccountViewController_register_btnCancel
                                         otherButtonTitles:__kAccountViewController_register_btnSubmit, nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    //输入框设置
    UITextField *textField = [alert textFieldAtIndex:0];
    if(textField){
        textField.placeholder = __kAccountViewController_register_msg;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.delegate = self;
    }
    //弹出
    [alert show];
}
#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"buttonIndex=>%d",buttonIndex);
    if(!_account)return;
    //获取输入框
    UITextField *tf = [alertView textFieldAtIndex:0];
    if(!tf)return;
    //获取输入的注册码
    NSString *regCode = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(!regCode || regCode.length == 0)return;
    //初始化等待动画
    WaitForAnimation *regWait = [[WaitForAnimation alloc] initWithView:self.view
                                                             WaitTitle:__kAccountViewController_register_waitting];
    //开启等待动画
    [regWait show];
    //检查网络
    [HttpUtils netWorkStatus:^(BOOL statusValue){
        if(!statusValue){
            //关闭等待动画
            [regWait hide];
            //显示提示信息
            [self showAlterWithTitle:__kAccountViewController_register_alterTitle
                             Message:__kAccountViewController_register_alterError];
            //
            return;
        }
        //注册码请求数据
        AppRegisterCode *appRegCode = [[AppRegisterCode alloc] initWithCode:regCode];
        appRegCode.userId = _account.accountId;
        AppClientSettings *appSettings = [AppClientSettings clientSettings];
        //网络处理
        [HttpUtils JSONDataDigestWithUrl:appSettings.appRegCodeValidUrl
                                  Method:HttpUtilsMethodPOST
                              Parameters:[appRegCode serializeJSON]
                                Username:appSettings.digestUsername
                                Password:appSettings.digestPassword
                                 Success:^(NSDictionary *json) {
                                     //关闭等待动画
                                     [regWait hide];
                                     //获取反馈
                                     JSONCallback *callback = [[JSONCallback alloc] initWithDictionary:json];
                                     if(callback.success){
                                         //重置注册码数据
                                         [_account setValue:regCode forKey:__kAccountViewController_register_registerCode];
                                         //保存数据
                                         [_account save];
                                     }else{
                                         //反馈错误
                                         [self showAlterWithTitle:__kAccountViewController_register_alterTitle Message:callback.msg];
                                     }
                                 } Fail:^(NSString *err) {
                                     //关闭等待动画
                                     [regWait hide];
                                     //显示错误信息
                                     [self showAlterWithTitle:__kAccountViewController_register_alterTitle Message:err];
                                 }];
    }];
}
//显示提示信息
-(void)showAlterWithTitle:(NSString *)title Message:(NSString *)msg{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title
                                                   message:msg
                                                  delegate:nil
                                         cancelButtonTitle:__kAccountViewController_register_btnSubmit
                                         otherButtonTitles:nil, nil];
    [alert show];
}
#pragma mark UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    //NSLog(@"textFieldDidEndEditing==>");
    [textField resignFirstResponder];
}
@end
