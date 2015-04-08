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

#define __k_account_view_register_title @"软件注册码"//
#define __k_account_view_register_msg @"请输入软件注册码"//

#define __k_account_view_register_btn_cancel @"取消"//
#define __k_account_view_register_btn_submit @"确定"//

#define __k_account_view_register_alter_title @"提示"//
#define __k_account_view_register_alter_error @"无网络，请联网再试！"//

//注册码处理分类
@implementation AccountViewController (RegisterCode)
WaitForAnimation *_registerWaitHud;
UIAlertController *_registerAlterController,*_showAlterController;
//注册码处理。
-(void)registerWithAccount:(UserAccountData *)account{
    if(!_registerAlterController){//惰性加载
        _registerAlterController = [UIAlertController alertControllerWithTitle:__k_account_view_register_title
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        //添加输入框
        [_registerAlterController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = __k_account_view_register_msg;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.delegate = self;
            //添加通知，监听的注册码内容的变化
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(registerCodeFieldTextDidChangeNotification:)
                                                         name:UITextFieldTextDidChangeNotification
                                                       object:textField];
        }];
        //取消按钮
        UIAlertAction *btnCancel = [UIAlertAction actionWithTitle:__k_account_view_register_btn_cancel
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
                                                             [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
                                                              NSLog(@"注销...");
                                                          }];
        //确定按钮
        UIAlertAction *btnSubmit = [UIAlertAction actionWithTitle:__k_account_view_register_btn_submit
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              NSLog(@"确定...=>...");
                                                              [self saveRegisterCodeWithAccount:account];//保存注册码
                                                          }];
        btnSubmit.enabled = NO;
        //添加按钮
        [_registerAlterController addAction:btnCancel];
        [_registerAlterController addAction:btnSubmit];
    }
    //弹出界面
    [self presentViewController:_registerAlterController animated:YES completion:nil];
    
    NSLog(@"registerWithAccount=>%@", account);
}
//保存注册码
-(void)saveRegisterCodeWithAccount:(UserAccountData *)account{
    if(!_registerWaitHud){//初始化等待动画
        _registerWaitHud = [[WaitForAnimation alloc] initWithView:self.view WaitTitle:@"正在注册..."];
    }
    [_registerWaitHud show];//开启等待动画
    if(account && _registerAlterController){
       NSString *regCode = [((UITextField *)_registerAlterController.textFields[0]).text stringByTrimmingCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
        [HttpUtils netWorkStatus:^(BOOL statusValue) {
            if(!statusValue){
                //关闭等待动画
                [_registerWaitHud hide];
                //显示提示信息
                [self showAlterWithTitle:__k_account_view_register_alter_title
                                 Message:__k_account_view_register_alter_error];
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
                                         //获取反馈
                                         JSONCallback *callback = [[JSONCallback alloc] initWithDictionary:json];
                                         if(callback.success){
                                             //重置注册码数据
                                             [account setValue:regCode forKey:@"registerCode"];
                                             //保存数据
                                             [account save];
                                         }else{
                                             //反馈错误
                                             [self showAlterWithTitle:__k_account_view_register_alter_title
                                                              Message:callback.msg];
                                         }
                                         //关闭等待动画
                                         [_registerWaitHud hide];
                                     } Fail:^(NSString *err) {
                                         //关闭等待动画
                                         [_registerWaitHud hide];
                                         //显示错误信息
                                         [self showAlterWithTitle:__k_account_view_register_alter_title
                                                          Message:err];
                                     }];
        }];
    }else{
        //关闭等待动画
        [_registerWaitHud hide];
    }
}
//显示提示信息
-(void)showAlterWithTitle:(NSString *)title Message:(NSString *)msg{
    if(!_showAlterController){
        _showAlterController = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *btnSumbit = [UIAlertAction actionWithTitle:__k_account_view_register_btn_submit
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
                                                              NSLog(@"alter_title");
                                                              [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
                                                          }];
        [_showAlterController addAction:btnSumbit];
    }
    [_showAlterController setTitle:title];//设置标题
    [_showAlterController setMessage:msg];//设置提示内容
    //弹出提示框
    [self presentViewController:_showAlterController animated:YES completion:nil];
}

//注册码内容变化通知处理
-(void)registerCodeFieldTextDidChangeNotification:(NSNotification *)note{
    UITextField *tf = note.object;
    if(tf && _registerAlterController){
        NSArray *actions = _registerAlterController.actions;
        if(actions.count > 0){
            ((UIAlertAction *)actions[1]).enabled = tf.text.length > 0;
        }
    }
}
#pragma mark UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing==>");
    [textField resignFirstResponder];
}

@end
