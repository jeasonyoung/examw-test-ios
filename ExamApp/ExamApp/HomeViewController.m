//
//  HomeController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "HomeViewController.h"
//主页控制器成员变量
@interface HomeViewController ()
{
    //导航控制器
    UINavigationController *_navController;
}
@end
//主页控制器实现类
@implementation HomeViewController
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
    //self.navigationItem.title = @"主页";
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"home====");
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end