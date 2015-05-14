//
//  AppDelegate.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import "AppDelegate.h"
#import "DetailViewController.h"
//入口代理成员变量
@interface AppDelegate(){
    
}
@end
//入口代理实现
@implementation AppDelegate

#pragma mark app开始运行时调用
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //加载配置
    _appSettings = [AppSettings settingsDefaults];
    
    //初始化主窗体
    _window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    //设置主窗体背景色
    _window.backgroundColor = [UIColor whiteColor];
    
    UIViewController *root;
    //是否加载产品选择主界面
    if(![_appSettings verification]){//未有完整配置(新安装)
        root = nil;
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
