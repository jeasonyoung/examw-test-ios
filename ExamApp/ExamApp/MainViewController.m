//
//  MainViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
#import "MainViewController.h"
#import "ETNavigationController.h"
#import "HomeViewController.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"
//主视图控制器成员变量
@interface MainViewController()<UITabBarControllerDelegate>{
    
}
@end
//主视图控制器实现类
@implementation MainViewController
#pragma mark 切换视图控制器
-(void)gotoController{
    //获取应用代理
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //将当前控制器设置为根控制器
    app.window.rootViewController = self;
    //显示当前
    [app.window makeKeyAndVisible];
}
#pragma mark 内容加载
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置代理
    self.delegate = self;
    //主页控制器
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    [self addChildViewController:homeVC
                           title:@"首页"
                  tabNormalImage:@"tab_home_normal.png"
               tabHighlightImage:@"tab_home_selected.png"];
    //设置控制器
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    [self addChildViewController:settingsVC
                           title:@"设置"
                  tabNormalImage:@"tab_settings_normal.png"
               tabHighlightImage:@"tab_settings_selected.png"];
}
-(void)addChildViewController:(UIViewController *)childController title:(NSString *)title tabNormalImage:(NSString *)normalImageName tabHighlightImage:(NSString *) highlightImageName{
    //添加为tabbar控制的子控制器
    ETNavigationController *nav = [[ETNavigationController alloc] initWithRootViewController:childController];
    //设置背景色
    childController.view.backgroundColor = [UIColor clearColor];
    //设置标题
    //childController.title = title;
    //设置Nav标题
    childController.navigationItem.title = title;
    //设置tabBar图标
    childController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                               image:[UIImage imageNamed:normalImageName]
                                                       selectedImage:[UIImage imageNamed:highlightImageName]];
    
    //设置图标
    //childController.tabBarItem.image = [UIImage imageNamed:normalImageName];
    //设置选中图标
    //childController.tabBarItem.selectedImage = [UIImage imageNamed:highlightImageName];
    
    [self addChildViewController:nav];
}
#pragma mark 内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITabBarControllerDelegate
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    //添加切换动画
    CATransition *animation = [CATransition animation];
    animation.duration = 0.9f;
    animation.type = kCATransitionFade;
    animation.subtype = kCATransitionFromRight;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.view.layer addAnimation:animation forKey:@"switchView"];
    
    //NSLog(@"didSelectViewController - %d", (int)tabBarController.selectedIndex);
}
@end
