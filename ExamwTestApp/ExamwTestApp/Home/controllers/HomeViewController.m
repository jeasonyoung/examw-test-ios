//
//  HomeViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "HomeViewController.h"

#import "DAPagesContainer.h"
#import "UIColor+Hex.h"

#import "PaperRealViewController.h"
#import "PaperSimuViewController.h"
#import "PaperForecasViewController.h"

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
    //隐藏导航条
    self.navigationController.navigationBarHidden = YES;
    //初始化可滚动导航条
    [self setupPagesContainers];
}

//初始化可滚动导航条
-(void)setupPagesContainers{
    NSLog(@"初始化可滚动导航条...");
    _pagesContainer = [[DAPagesContainer alloc]init];
    [_pagesContainer willMoveToParentViewController:self];
    //_pagesContainer.topBarBackgroundColor = [UIColor colorWithHex:0x696969];
    _pagesContainer.view.frame = self.view.bounds;
    _pagesContainer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_pagesContainer.view];
    [_pagesContainer didMoveToParentViewController:self];
    
    //真题
    PaperRealViewController *realController = [[PaperRealViewController alloc] init];
    realController.view.tag = PaperTypeReal;
    realController.title = [PaperModel nameWithPaperType:PaperTypeReal]; //@"真题";
    
    //模拟题
    PaperSimuViewController *simuController = [[PaperSimuViewController alloc] init];
    simuController.view.tag = PaperTypeSimu;
    simuController.title = [PaperModel nameWithPaperType:PaperTypeSimu];//@"模拟题";
    
    //预测题
    PaperForecasViewController *forecasController = [[PaperForecasViewController alloc] init];
    forecasController.view.tag = PaperTypeForecas;
    forecasController.title = [PaperModel nameWithPaperType:PaperTypeForecas];//@"预测题";
    
    _pagesContainer.viewControllers = @[realController,simuController,forecasController];
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
