//
//  BaseViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "BaseViewController.h"
//视图控制器基类成员变量
@interface BaseViewController (){
    
}
@end
//视图控制器基类成员变量实现类
@implementation BaseViewController
#pragma mark 加载入口
- (void)viewDidLoad {
    [super viewDidLoad];
    _hiddenTabBar = NO;
}
#pragma mark 加载底部高度
-(CGFloat)loadBottomHeight{
    if(!_hiddenTabBar){
        return [super loadBottomHeight];
    }
    return 0;
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark 启动时隐藏底部的状态栏
-(void)viewWillAppear:(BOOL)animated{
    if(self.tabBarController != nil && _hiddenTabBar){
        self.tabBarController.tabBar.hidden = YES;
    }
}
#pragma mark 关闭时显示底部的状态栏
-(void) viewWillDisappear:(BOOL)animated{
    if(self.tabBarController != nil && _hiddenTabBar){
        self.tabBarController.tabBar.hidden = NO;
    }
}
@end
