//
//  MainViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MainViewController.h"
#import "BottomMenuModel.h"

//主界面视图控制器成员变量
@interface MainViewController ()<UITabBarControllerDelegate>{
    
}
@end
//主界面视图控制器
@implementation MainViewController

#pragma mark 静态成实例
+(instancetype)shareInstance{
    static MainViewController *mainController;
    if(!mainController){
        mainController = [[MainViewController alloc] init];
    }
    return mainController;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置代理
    self.delegate = self;
    //加载底部菜单数据
    [self loadBottomMenus];
}

//加载底部菜单数据
-(void)loadBottomMenus{
    //异步线程加载菜单数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"后台线程开始加载菜单数据...");
        NSArray *menus = [BottomMenuModel menusFromLocal];
        if(!menus || menus.count == 0){
            NSLog(@"未加载到菜单数据...");
            return;
        }
        NSLog(@"开始反射装载视图控制器...");
        //反射装载视图控制器
        NSMutableArray *controllers = [NSMutableArray arrayWithCapacity:menus.count];
        for(BottomMenuModel *model in menus){
            if(!model)continue;
            UIViewController *viewController = [model buildViewController];
            if(viewController){
                [controllers addObject:viewController];
            }
        }
        if(controllers.count == 0){
            NSLog(@"没有生成底部菜单...");
            return;
        }
        //反射完毕,更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"前台UI加载底部菜单...");
            [self setViewControllers:controllers animated:YES];
            self.selectedIndex = 0;
        });
    });
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
