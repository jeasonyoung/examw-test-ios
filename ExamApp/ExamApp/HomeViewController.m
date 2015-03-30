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
#import "WrongSubjectViewController.h"
#import "WebViewController.h"

#import "AppConstant.h"
#import "HomeData.h"

#define __kHomeViewController_Top 4 //顶部间距
#define __kHomeViewController_Left 4 //左边间距
#define __kHomeViewController_Right 4 //右边间距
#define __kHomeViewController_Bottom 4//底部间距
#define __kHomeViewController_Margin 2//

#define __k_UserViewPanel_current @"未登录"//默认当前用户
//主页控制器成员变量
@interface HomeViewController ()<ETUserViewDelegate,ETHomePanelViewDelegate>{
    ETUserView *_userView;
}
@end
//主页控制器实现类
@implementation HomeViewController
#pragma mark 加载入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化
    CGRect frame = [self loadVisibleViewFrame];
    frame.origin.x = __kHomeViewController_Left;
    frame.origin.y += __kHomeViewController_Top;
    frame.size.width -= (__kHomeViewController_Left + __kHomeViewController_Right);
    frame.size.height -= __kHomeViewController_Bottom;
    //创建用户信息面板
    NSNumber *y = [NSNumber numberWithFloat:0];
    [self createUserViewPanelWithFrame:frame OutY:&y];
    //创建主界面面板
    [self createHomeViewPanelWithFrame:frame OutY:&y];
    //NSLog(@"home====");
}
#pragma mark 创建用户信息面板
-(void)createUserViewPanelWithFrame:(CGRect)frame OutY:(NSNumber**)outY{
    _userView = [[ETUserView alloc] initWithFrame:frame];
    _userView.delegate = self;//设置代理对象
    [_userView createPanel];//创建面板
    [self.view addSubview:_userView];
    //
    *outY = [NSNumber numberWithFloat:CGRectGetMaxY(_userView.frame)];
}
#pragma mark 用户信息面板代理方法
#pragma mark 倒计时目标日期
-(NSDate *)userViewForExamDate{
    return [HomeData loadExamDate];
}
#pragma mark 当前用户名
-(NSString *)userViewForCurrentUser{
    UserAccountData *current = [UserAccountData currentUser];
    return ([current userIsValid] ? current.account : __k_UserViewPanel_current);
}
#pragma mark 创建九宫格主界面
-(void)createHomeViewPanelWithFrame:(CGRect)frame OutY:(NSNumber **)outY{
    frame.origin.y = (*outY).floatValue + __kHomeViewController_Margin;
    if(_userView){
        frame.size.height -= CGRectGetHeight(_userView.frame) + __kHomeViewController_Margin + __kHomeViewController_Top + __kHomeViewController_Bottom;
    }
    ETHomePanelView *homePanel = [[ETHomePanelView alloc]initWithFrame:frame];
    homePanel.delegate = self;//设置代理
    [homePanel createPanel];//创建面板
    [self.view addSubview:homePanel];
}
#pragma mark ETHomePanelViewDelegate
//九宫格事件代理
-(void)homePanelViewButtonClick:(ETHomePanelView *)homePanelView withTitle:(NSString *)title withValue:(NSString *)value{
    NSLog(@"homePanelView => %@,  value = %@", homePanelView, value);
    UIViewController *controller;
    if([@"everyday" isEqualToString:value]){//1.每日知识
        controller = [[WebViewController alloc]initWithURL:_kAppClientHomeUrl];
    }else if([@"practice" isEqualToString:value]){//2.章节练习
        
    }else if([@"collect" isEqualToString:value]){//3.我的收藏
        controller = [[FavoriteSubjectViewController alloc]init];
    }else if([@"renewal" isEqualToString:value]){//4.错题重做
        controller = [[WrongSubjectViewController alloc]init];
    }else if([@"imitate" isEqualToString:value]){//5.模拟考场
        controller = [[ImitateSubjectViewController alloc] init];
    }else if([@"notes" isEqualToString:value]){//6.我的笔记
        
    }else if([@"forum" isEqualToString:value]){//7.论坛交流
        controller = [[WebViewController alloc]initWithURL:_kAppClientBBSUrl];
    }else if([@"record" isEqualToString:value]){//8.学习记录
        controller = [[LearnRecordViewController alloc] init];
    }else if([@"guide" isEqualToString:value]){//9.考试指南
        controller = [[WebViewController alloc]initWithURL:_kAppClientGuideUrl];
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
#pragma mark 视图将显示
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(_userView){
        [_userView updateDownTime];
    }
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end