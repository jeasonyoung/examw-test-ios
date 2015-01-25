//
//  HomeController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import "HomeViewController.h"
#import "NSString+Date.h"
#import "UIColor+Hex.h"
#import "ETUserView.h"
#import "ETHomePanelView.h"

#define __k_UserViewPanel_Top 4 //用户信息面板与顶部的间隔
#define __k_UserViewPanel_Left 2 //用户信息面板与左边边界的间隔
#define __k_UserViewPanel_Right 2 //用户信息面板与右边边界的间隔
//主页控制器成员变量
@interface HomeViewController ()<ETUserViewDelegate>
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
    //创建用户信息面板
    CGFloat y = [self createUserViewPanel];
    //创建主界面面板
    [self createHomeViewPanelWithY:y];
    
    NSLog(@"home====");
}
#pragma mark 创建用户信息面板
-(CGFloat)createUserViewPanel{
    CGRect tempFrame = self.view.frame;
    CGFloat nav_height = self.navigationController.navigationBar.bounds.size.height;
    if(!self.prefersStatusBarHidden){
        nav_height += 20;
    }
    tempFrame.origin.x = __k_UserViewPanel_Left;
    tempFrame.origin.y = nav_height + __k_UserViewPanel_Top;
    tempFrame.size.width -= (__k_UserViewPanel_Left + __k_UserViewPanel_Right);
    ETUserView *userView = [[ETUserView alloc] initWithFrame:tempFrame];
    userView.delegate = self;//设置代理对象
    [userView createPanel];//创建面板
    [self.view addSubview:userView];
    
    //获取用户面板Frame
    tempFrame = userView.frame;
    return tempFrame.origin.y + tempFrame.size.height;
}
#pragma mark 用户信息面板代理方法
#pragma mark 倒计时目标日期
-(NSDate *)countDownTargetDateInUserView:(ETUserView *)userView{
    return [@"2015-01-26" toDateWithFormat:@"yyyy-MM-dd"];
}

#pragma mark 创建主界面
-(void)createHomeViewPanelWithY:(CGFloat)y{
    CGRect tempFrame = self.view.frame;
    CGFloat bottomHeight = 48 + __k_UserViewPanel_Top;
    tempFrame.origin.x = __k_UserViewPanel_Left;
    tempFrame.origin.y = y + __k_UserViewPanel_Top;
    tempFrame.size.width -= (__k_UserViewPanel_Left + __k_UserViewPanel_Right);
    tempFrame.size.height -= (tempFrame.origin.y + bottomHeight);
    
    ETHomePanelView *home = [[ETHomePanelView alloc] initWithFrame:tempFrame];
    //home.delegate = self;//设置代理
    [home createPanel];//创建面板
    [self.view addSubview:home];
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end