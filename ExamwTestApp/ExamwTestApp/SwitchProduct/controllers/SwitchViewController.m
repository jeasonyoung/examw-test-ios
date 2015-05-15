//
//  SwitchViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/15.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "SwitchViewController.h"
#import "CategoryViewController.h"

//切换产品导航控制器成员变量
@interface SwitchViewController ()

@end
//切换产品导航控制器实现
@implementation SwitchViewController

#pragma mark 静态实例化
+(instancetype)shareInstance{
    static SwitchViewController *controller;
    if(!controller){
        UIViewController *root = [[CategoryViewController alloc]init];
        controller = [[self alloc]initWithRootViewController:root];
    }
    return controller;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //去除左右向导按钮
    self.navigationController.navigationItem.leftBarButtonItem = nil;
    self.navigationController.navigationItem.rightBarButtonItem = nil;
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
