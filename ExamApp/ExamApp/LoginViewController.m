//
//  LoginViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/2.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import "LoginViewController.h"
#import "LoginViewController+UserLogin.h"
#import "LoginViewController+Register.h"
#import "SettingsViewController.h"

#import "NSString+Size.h"
#define __k_login_view_title @"学员注册"//
//登录视图控制器成员变量
@interface LoginViewController (){
}
@end
//登录视图控制器实现类
@implementation LoginViewController
#pragma mark 函数入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //添加左边的取消按钮
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goToRootViewController)];
    self.navigationItem.leftBarButtonItem = leftButton;
    //登录框
    [self createLoginAlterWithAccount:nil];
    //添加注册UI
    self.navigationItem.title = __k_login_view_title;
    //显示注册界面
    [self setupRegisterPanel];
}
#pragma mark 创建登录界面
-(void)createLoginAlterWithAccount:(NSString *)account{
    [self alterLoginViewWithMessage:nil Account:account];
}
#pragma mark 跳转到根视图控制器.
-(void)goToRootViewController{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark 移除消息监听
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end