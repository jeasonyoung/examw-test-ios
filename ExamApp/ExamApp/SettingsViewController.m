//
//  SettingsController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "SettingsViewController.h"
//设置页控制器成员变量
@interface SettingsViewController (){
    //导航控制器
    UINavigationController *_navController;
}
@end
//设置页控制器实现类
@implementation SettingsViewController
#pragma mark 初始化重载
-(id)init{
    if(self = [super init]){
        //初始化导航控制器，并将当前控制器设为根控制器
        _navController = [[UINavigationController alloc] initWithRootViewController:self];
    }
    return self;
}
#pragma mark 加载入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationItem.title = @"设置";
    //self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"settings====tabBar height ==> %f", self.tabBarController.tabBar.bounds.size.height);
    // Do any additional setup after loading the view.
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
