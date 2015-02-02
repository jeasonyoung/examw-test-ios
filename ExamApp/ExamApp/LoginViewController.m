//
//  LoginViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/2.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import "LoginViewController.h"
#import "SettingsViewController.h"

#define __k_login_view_title @"用户登录"//登录窗口
#define __k_login_view_btn_login_title @"登录"//登录标题
#define __k_login_view_btn_register_title @"注册"//注册标题
//登录视图控制器成员变量
@interface LoginViewController ()<UIAlertViewDelegate>

@end
//登录视图控制器实现类
@implementation LoginViewController
#pragma mark 函数入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //添加左边的取消按钮
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(selectLeftAction:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    //登录界面
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:__k_login_view_title
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:__k_login_view_btn_login_title
                                              otherButtonTitles:__k_login_view_btn_register_title, nil];
    alterView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    //显示登录界面
    [alterView show];
}
#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"clickedButtonAtIndex => %d", (int)buttonIndex);
    switch((int)buttonIndex){
        case 0:{
            NSLog(@"登录...");
            UITextField *tfAccount = [alertView textFieldAtIndex:0],*tfPassword = [alertView textFieldAtIndex:1];
            NSLog(@"tfAccount=>%@",tfAccount);
            NSLog(@"tfPassword=>%@",tfPassword);
            
            [self goToRootViewController];
            break;
        }
        case 1:{
            
            NSLog(@"注册...");
            break;
        }
    }
}
//取消按钮事件
-(void)selectLeftAction:(id)sender{
    NSLog(@"xxx");
    [self goToRootViewController];
}
//调整的根视图
-(void)goToRootViewController{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end