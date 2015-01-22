//
//  MainViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
#import "MainViewController.h"
#import "HomeViewController.h"
#import "SettingsViewController.h"
//主视图控制器成员变量
@interface MainViewController()<UITabBarControllerDelegate>{
    
}
@end
//主视图控制器实现类
@implementation MainViewController
#pragma mark 切换视图控制器
-(void)gotoControllerWithParent:(UIViewController *)parent animated:(BOOL)isAnimate{
    if(parent != nil){
        //self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        [parent presentViewController:self animated:YES completion:^{
            NSLog(@" === === completion == ==");
        }];
    }
}
#pragma mark 内容加载
- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    NSString *topTitle = @"产品名称";
    //主页控制器
    HomeViewController *home = [[HomeViewController alloc] init];
    UITabBarItem *homeBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"tab_home_normal.png"] selectedImage:[UIImage imageNamed:@"tab_home_selected.png"]];
    home.tabBarItem = homeBarItem;
    home.navigationItem.title = topTitle;
    //设置控制器
    SettingsViewController *settings = [[SettingsViewController alloc] init];
    UITabBarItem *settingsBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"tab_settings_normal.png"] selectedImage:[UIImage imageNamed:@"tab_settings_selected.png"]];
    settings.tabBarItem =  settingsBarItem;
    settings.navigationItem.title = topTitle;
    //添加到TabBarController控制器中
    self.viewControllers = @[home.navigationController, settings.navigationController];
    
    NSLog(@"TabBarController ====");
}
#pragma mark 内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITabBarControllerDelegate
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    NSLog(@"didSelectViewController - %d", (int)tabBarController.selectedIndex);
}
@end
