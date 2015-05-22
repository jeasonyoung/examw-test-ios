//
//  MainViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MainViewController.h"

#import "AppDelegate.h"
#import "AppSettings.h"
//主界面视图控制器成员变量
@interface MainViewController (){
    
}
@end
//主界面视图控制器
@implementation MainViewController

#pragma mark 静态成实例
+(instancetype)shareInstance{
    static MainViewController *instance;
    if(!instance){
        instance = [[MainViewController alloc]init];
    }
    return instance;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    [self loadMainTitle];
    
    // Do any additional setup after loading the view.
}

//设置主界面
-(void)loadMainTitle{
    //多线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *examName;
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        if(app && app.appSettings){
            examName = app.appSettings.examName;
        }
        if(examName && examName.length > 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.title = examName;
                NSLog(@"主线程加载成功....");
            });
        }
    });
}



#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
