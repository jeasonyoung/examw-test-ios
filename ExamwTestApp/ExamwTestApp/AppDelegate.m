//
//  AppDelegate.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import "AppDelegate.h"
//
#import "AppSettings.h"
#import "UserAccount.h"

#import "SwitchViewController.h"

#import "DetailViewController.h"
//入口代理成员变量
@interface AppDelegate(){
   
}
@end
//入口代理实现
@implementation AppDelegate

#pragma mark app开始运行时调用
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //开启线程加载数据
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //加载当前用户
        _currentUser = [UserAccount current];
    });
    
    //初始化主窗体
    _window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    //设置主窗体背景色
    _window.backgroundColor = [UIColor whiteColor];
    
    UIViewController *root;
    //加载配置
    _appSettings = [AppSettings settingsDefaults];
    //是否加载产品选择主界面
    if(![_appSettings verification]){//未有完整配置(新安装)
        root = [SwitchViewController shareInstance];
    }else{//有完整
        root = [[DetailViewController alloc]init];
    }
    //加载主界面
    if(root){
        _window.rootViewController = root;
        //启动显示
        [_window makeKeyAndVisible];
    }
    return YES;
}

#pragma mark 切换当前用户
-(void)changedCurrentUser:(UserAccount *)userAccount{
    NSLog(@"切换当前用户=>%@", userAccount);
    _currentUser = userAccount;
}

#pragma mark 屏幕旋转支持处理
-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    //固定竖屏
    return  UIInterfaceOrientationMaskPortrait;
}

#pragma mark app将进入非激活状态
- (void)applicationWillResignActive:(UIApplication *)application {

}
#pragma mark app将进入后台模式
- (void)applicationDidEnterBackground:(UIApplication *)application {

}
#pragma mark app将进入前台模式
- (void)applicationWillEnterForeground:(UIApplication *)application {

}
#pragma mark app恢复激活状态
- (void)applicationDidBecomeActive:(UIApplication *)application {

}
#pragma mark app将关闭
- (void)applicationWillTerminate:(UIApplication *)application {

}
@end
