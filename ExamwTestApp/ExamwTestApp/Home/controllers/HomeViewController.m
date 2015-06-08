//
//  HomeViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "HomeViewController.h"

#import "AppConstants.h"

#import "DAPagesContainer.h"
#import "UIColor+Hex.h"

#import "PaperInfoViewController.h"

#import "PaperModel.h"

//首页视图控制器成员变量
@interface HomeViewController (){
    DAPagesContainer *_pagesContainer;
}
@end

//首页视图控制器实现
@implementation HomeViewController

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化可滚动导航条
    [self setupPagesContainers];
    
    //bar头颜色设置
    UIColor *color = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = color;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : color}];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHex:GLOBAL_REDCOLOR_HEX];
}

//初始化可滚动导航条
-(void)setupPagesContainers{
    NSLog(@"初始化可滚动导航条...");
    _pagesContainer = [[DAPagesContainer alloc]init];
    [_pagesContainer willMoveToParentViewController:self];
    _pagesContainer.topBarBackgroundColor = [UIColor colorWithHex:GLOBAL_REDCOLOR_HEX];
    _pagesContainer.view.frame = self.view.bounds;
    _pagesContainer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_pagesContainer.view];
    [_pagesContainer didMoveToParentViewController:self];
    
    //真题
    PaperInfoViewController *realController = [PaperInfoViewController infoControllerWithType:PaperTypeReal
                                                                         parentViewController:self];
    realController.title = [PaperModel nameWithPaperType:PaperTypeReal];
    
    //模拟题
    PaperInfoViewController *simuController = [PaperInfoViewController infoControllerWithType:PaperTypeSimu
                                                                         parentViewController:self];
    simuController.title = [PaperModel nameWithPaperType:PaperTypeSimu];

    //预测题
    PaperInfoViewController *forecasController = [PaperInfoViewController infoControllerWithType:PaperTypeForecas
                                                                            parentViewController:self];
    forecasController.title = [PaperModel nameWithPaperType:PaperTypeForecas];
    
    _pagesContainer.viewControllers = @[simuController,realController,forecasController];
    //_pagesContainer.selectedIndex = 1;
}

#pragma mark 重载视图将载入
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"视图将载入...");
    //隐藏导航条
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController setToolbarHidden:YES];
}
#pragma mark 重载视图将卸载
-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"视图将卸载...");
    //隐藏导航条
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
