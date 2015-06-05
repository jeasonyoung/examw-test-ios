//
//  MyUserLoginViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyUserLoginViewController.h"
//用户登录视图控制器成员变量
@interface MyUserLoginViewController (){
    NSString *_account;
}
@end
//用户登录视图控制器实现
@implementation MyUserLoginViewController

#pragma mark 初始化
-(instancetype)initWithAccount:(NSString *)account{
    if(self = [super initWithStyle:UITableViewStyleGrouped]){
        _account = account;
    }
    return self;
}

#pragma mark 重载初始化
-(instancetype)init{
    return [self initWithAccount:nil];
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
