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

#import "ZWIntroductionViewController.h"

#import "SwitchViewController.h"
#import "MainViewController.h"

#import "UploadDataService.h"

//入口代理成员变量
@interface AppDelegate ()

//
@property(nonatomic,strong) ZWIntroductionViewController *introductionView;

@end
//入口代理实现
@implementation AppDelegate

#pragma mark app开始运行时调用
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //捕获异常
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    //初始化主窗体
    _window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    //设置主窗体背景色
    _window.backgroundColor = [UIColor whiteColor];
    //启动显示
    [_window makeKeyAndVisible];
    
    //Added Introduction View Controller
    NSArray *backgroundImages = @[@"guide_1.png",@"guide_2.png",@"guide_3.png"];
    self.introductionView = [[ZWIntroductionViewController alloc] initWithCoverImageNames:backgroundImages
                                                                     backgroundImageNames:backgroundImages];
    [_window addSubview:self.introductionView.view];
    
    __weak AppDelegate *weakSelf = self;
    _introductionView.didSelectedEnter = ^(){
        [weakSelf.introductionView.view removeFromSuperview];
        weakSelf.introductionView = nil;
        
        //加载根控制器
        [weakSelf resetRootController];
    };
    //
    return YES;
}

//异常处理
void uncaughtExceptionHandler(NSException *exception){
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

#pragma mark 切换当前用户
-(void)changedCurrentUser:(UserAccount *)userAccount{
    NSLog(@"切换当前用户=>%@", userAccount);
    _currentUser = userAccount;
    if(userAccount){
        //异步线程保存数据
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if(userAccount){
                NSLog(@"异步线程持久化当前用户数据:%@...", userAccount);
                [userAccount saveForCurrent];
            }
        });
    }
}

#pragma mark 更新设置
-(void)updateSettings:(AppSettings *)appSettings{
    NSLog(@"更新设置:%@...",appSettings);
    if(appSettings){
        _appSettings = appSettings;
        //异步线程保存数据
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if(appSettings){
                NSLog(@"异步线程保存设置更新:%@...", appSettings);
                [appSettings saveToDefaults];
            }
        });
    }
}


#pragma mark 重置主控制器
-(void)resetRootController{
    NSLog(@"准备加载根控制器...");
    if(!_window) return;
    //异步线程加载配置数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //加载配置
        if(!_appSettings){
            _appSettings = [AppSettings settingsDefaults];
        }
        //加载当前用户数据
        if(!_currentUser){
            _currentUser = [UserAccount current];
        }
        //主线程设置控制器
        dispatch_async(dispatch_get_main_queue(), ^{
            //定义根控制器
            UIViewController *root;
            //是否加载产品选择主界面
            if(![_appSettings verification]){//未有完整配置(新安装)
                root = [SwitchViewController shareInstance];
            }else{//加载主界面
                root = [MainViewController shareInstance];
            }
            //加载主界面
            if(root){
                NSLog(@"将加载根控制器:%@", root);
                //设置根控制器
                _window.rootViewController = root;
            }
        });
    });
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
    //进入后台模式时上传同步数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            if(![self currentUser]){
                NSLog(@"未登录不上传数据!");
                return;
            }
            NSLog(@"进入后台模式时上传同步数据...");
            UploadDataService *uploadService = [[UploadDataService alloc] init];
            [uploadService upload];
        }
        @catch (NSException *exception) {
            NSLog(@"上传数据服务时发生异常:%@", exception);
        }
    });
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
