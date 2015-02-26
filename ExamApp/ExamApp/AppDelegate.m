//
//  AppDelegate.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AppDelegate.h"
#import "LaunchViewController.h"
//应用代理成员
@interface AppDelegate (){
}
@end
//应用代理实现类
@implementation AppDelegate
//app开始运行时调用
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //初始化Window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //设置Widow的背景颜色
    self.window.backgroundColor = [UIColor whiteColor];
    //设置Window的根控制器
    self.window.rootViewController = [[LaunchViewController alloc] init];
    //启动显示
    [self.window makeKeyAndVisible];
    return YES;
}
//app将进入非激活状态
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
//app恢复激活状态。
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
//app进入后台模式
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
//app将进入前台模式
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
//app将关闭
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    //[self saveContext];
}
@end