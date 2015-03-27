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
#import "DefaultViewController.h"
#import "UserAccountData.h"

#import "ImitateSubjectViewController.h"
#import "FavoriteSubjectViewController.h"
#import "LearnRecordViewController.h"

#define __k_UserViewPanel_Top 4 //用户信息面板与顶部的间隔
#define __k_UserViewPanel_Left 2 //用户信息面板与左边边界的间隔
#define __k_UserViewPanel_Right 2 //用户信息面板与右边边界的间隔

#define __k_UserViewPanel_current @"未登录"//默认当前用户
//主页控制器成员变量
@interface HomeViewController ()<ETUserViewDelegate,ETHomePanelViewDelegate>

@end
//主页控制器实现类
@implementation HomeViewController
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
    CGRect tempFrame = [self loadVisibleViewFrame];
    tempFrame.origin.x = __k_UserViewPanel_Left;
    tempFrame.origin.y += __k_UserViewPanel_Top;
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
#pragma mark 当前用户名
-(NSString *)userNameInUserView:(ETUserView *)userView{
    UserAccountData *current = [UserAccountData currentUser];
    return ([current userIsValid] ? current.account : __k_UserViewPanel_current);
}
#pragma mark 创建九宫格主界面
-(void)createHomeViewPanelWithY:(CGFloat)y{
    CGRect tempFrame = self.view.frame;
    CGFloat bottomHeight = [self loadBottomHeight] + __k_UserViewPanel_Top;
    tempFrame.origin.x = __k_UserViewPanel_Left;
    tempFrame.origin.y = y + __k_UserViewPanel_Top;
    tempFrame.size.width -= (__k_UserViewPanel_Left + __k_UserViewPanel_Right);
    tempFrame.size.height -= (tempFrame.origin.y + bottomHeight);
    
    ETHomePanelView *home = [[ETHomePanelView alloc] initWithFrame:tempFrame];
    home.delegate = self;//设置代理
    [home createPanel];//创建面板
    [self.view addSubview:home];
}
#pragma mark 九宫格事件代理
-(void)homePanelViewButtonClick:(ETHomePanelView *)homePanelView withTitle:(NSString *)title withValue:(NSString *)value{
    NSLog(@"homePanelView => %@,  value = %@", homePanelView, value);
    UIViewController *controller;
    if([@"everyday" isEqualToString:value]){//1.每日知识
        
    }else if([@"practice" isEqualToString:value]){//2.章节练习
        
    }else if([@"collect" isEqualToString:value]){//3.我的收藏
        controller = [[FavoriteSubjectViewController alloc]init];
    }else if([@"renewal" isEqualToString:value]){//4.错题重做
        
    }else if([@"imitate" isEqualToString:value]){//5.模拟考场
        controller = [[ImitateSubjectViewController alloc] init];
    }else if([@"notes" isEqualToString:value]){//6.我的笔记
        
    }else if([@"forum" isEqualToString:value]){//7.论坛交流
        
    }else if([@"record" isEqualToString:value]){//8.学习记录
        controller = [[LearnRecordViewController alloc] init];
    }else if([@"guide" isEqualToString:value]){//9.考试指南
        
    }
    
    if(controller == nil){
        controller = [[DefaultViewController alloc] init];
    }
    if(controller && self.navigationController){
        controller.navigationItem.title = title;
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:NO];
    }
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end