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
#import "ETAlert.h"

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
ETAlert *registerAlert;
//注册码处理。
-(void)registerWithAccount:(UserAccountData *)account{
    //初始化弹出框
    registerAlert = [[ETAlert alloc]initWithTitle:__kAccountViewController_register_title Message:nil];
    //添加输入框
    [registerAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = __kAccountViewController_register_msg;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.delegate = self;
        //添加通知，监听的注册码内容的变化
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(registerCodeFieldTextDidChangeNotification:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:textField];
    }];
    //添加确定按钮
    [registerAlert addConfirmActionWithTitle:__kAccountViewController_register_btnSubmit Handler:^(UIAlertAction *action) {
        [self saveRegisterCodeWithAccount:account];//保存注册码
    }];
    //添加取消按钮
    [registerAlert addCancelActionWithTitle:__kAccountViewController_register_btnCancel Handler:nil];
    //确定按钮不可用
    NSArray *actions = [registerAlert actions];
    if(actions && actions.count > 0){
        ((UIAlertAction *)actions[0]).enabled = NO;
    }
    //弹出弹出框
    [registerAlert showWithController:self];
}
//保存注册码
-(void)saveRegisterCodeWithAccount:(UserAccountData *)account{
    WaitForAnimation *regWait = [[WaitForAnimation alloc] initWithView:self.view
                                                             WaitTitle:__kAccountViewController_register_waitting];
    //开启等待动画
    [regWait show];
    //注册码处理
    if(account && registerAlert){
        NSArray *textFields = registerAlert.textFields;
        if(textFields && textFields.count > 0){
            //关闭等待动画
            [regWait hide];
            return;
        }
        //获取输入的注册码
        NSString *regCode = [((UITextField *)textFields[0]).text
                            stringByTrimmingCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
        //检查网络
        [HttpUtils netWorkStatus:^(BOOL statusValue) {
            if(!statusValue){
                //关闭等待动画
                [regWait hide];
                //显示提示信息
                [self showAlterWithTitle:__kAccountViewController_register_alterTitle
                                 Message:__kAccountViewController_register_alterError];
                return;
            }
            //注册码请求数据
            AppRegisterCode *appRegCode = [[AppRegisterCode alloc] initWithCode:regCode];
            AppClientSettings *appSettings = [AppClientSettings clientSettings];
            //网络处理
            [HttpUtils JSONDataDigestWithUrl:appSettings.appRegCodeValidUrl/*_kAppClientRegisterCodeUrl*/
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
                                             [account setValue:regCode forKey:__kAccountViewController_register_registerCode];
                                             //保存数据
                                             [account save];
                                         }else{
                                             //反馈错误
                                             [self showAlterWithTitle:__kAccountViewController_register_alterTitle
                                                              Message:callback.msg];
                                         }
                                         
                                     } Fail:^(NSString *err) {
                                         //关闭等待动画
                                         [regWait hide];
                                         //显示错误信息
                                         [self showAlterWithTitle:__kAccountViewController_register_alterTitle
                                                          Message:err];
                                     }];
        }];
    }else{
        //关闭等待动画
        [regWait hide];
    }
}
//显示提示信息
-(void)showAlterWithTitle:(NSString *)title Message:(NSString *)msg{
    [ETAlert alertWithTitle:title
                    Message:msg
                ButtonTitle:__kAccountViewController_register_btnSubmit
                 Controller:self];
}
//注册码内容变化通知处理
-(void)registerCodeFieldTextDidChangeNotification:(NSNotification *)note{
    UITextField *tf = note.object;
    if(registerAlert && tf){
        NSArray *actions = registerAlert.actions;
        if(actions && actions.count > 0){
            ((UIAlertAction *)actions[0]).enabled = tf.text.length > 0;
        }
    }
}
#pragma mark UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    //NSLog(@"textFieldDidEndEditing==>");
    [textField resignFirstResponder];
}
@end
