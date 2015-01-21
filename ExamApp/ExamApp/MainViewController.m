//
//  MainViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
#import "MainViewController.h"
//主菜单控制器成员变量
@interface MainViewController (){
    //导航控制器
    UINavigationController *_navController;
}
@end
//主菜单控制器实现类
@implementation MainViewController
#pragma mark 初始化
-(id)init{
    if(self = [super init]){
        _navController = [[UINavigationController alloc] initWithRootViewController:self];//初始化导航控制器
    }
    return self;
}
#pragma mark 切换视图控制器
-(void)gotoControllerWithParent:(UIViewController *)parent animated:(BOOL)isAnimate{
    if(parent != nil){
        //_navController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        [parent presentViewController:_navController animated:YES completion:^{
            NSLog(@" === === completion == ==");
        }];
    }
}
#pragma mark 内容加载
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"考试产品名称";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _navController.navigationBarHidden = NO;
}
#pragma mark 内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
