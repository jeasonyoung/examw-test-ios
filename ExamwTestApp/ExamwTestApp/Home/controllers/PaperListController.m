//
//  HomeViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperListController.h"

#import "AppConstants.h"

#import "DAPagesContainer.h"
#import "UIColor+Hex.h"
#import "MBProgressHUD.h"

#import "PaperInfoViewController.h"

#import "PaperModel.h"
#import "PaperService.h"
//首页视图控制器成员变量
@interface PaperListController (){
    DAPagesContainer *_pagesContainer;
    MBProgressHUD *_waitHud;
    BOOL _isReload;
}
@end

//首页视图控制器实现
@implementation PaperListController

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置不重新加载
    _isReload = NO;
    //bar头颜色设置
    UIColor *color = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = color;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : color}];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHex:GLOBAL_REDCOLOR_HEX];
    
    //初始化可滚动导航条
    [self setupPagesContainers];
    //加载数据
    [self loadData];
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
}

//加载数据
-(void)loadData{
    NSLog(@"异步线程加载数据...");
    //添加等待动画
    _waitHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _waitHud.color = [UIColor colorWithHex:WAIT_HUD_COLOR];
    //异步加载试卷类型数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //初始化服务
        static PaperService *_service;
        if(!_service){
            _service = [[PaperService alloc] init];
            NSLog(@"初始化数据服务...");
        }
        //加载试卷类型
        NSArray *arrays = [_service findPaperTypes];
        //updateUI
        dispatch_async(dispatch_get_main_queue(), ^{
            //试卷类型
            if(arrays && arrays.count > 0){
                NSMutableArray *controllers = [NSMutableArray arrayWithCapacity:arrays.count];
                for(NSNumber *typeNum in arrays){
                    if(!typeNum)continue;
                    PaperType paperTypeValue = (PaperType)typeNum.integerValue;
                    PaperInfoViewController *infoController = [PaperInfoViewController infoControllerWithType:paperTypeValue parentViewController:self];
                    infoController.title = [PaperModel nameWithPaperType:paperTypeValue];
                    [controllers addObject:infoController];
                }
                //添加控制器
                if(controllers.count > 0){
                    _pagesContainer.viewControllers = [controllers copy];
                }
            }
            //关闭等待动画
            if(_waitHud){[_waitHud hide:YES];}
        });
    });
}

#pragma mark 重载视图将载入
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"视图将载入...");
    //隐藏导航条
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController setToolbarHidden:YES];
    if(_isReload){
        _isReload = NO;
        NSLog(@"重新加载数据...");
        [self loadData];
    }
}
#pragma mark 重载视图将卸载
-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"视图将卸载...");
    //设置重新加载数据
    _isReload = YES;
    //隐藏导航条
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
