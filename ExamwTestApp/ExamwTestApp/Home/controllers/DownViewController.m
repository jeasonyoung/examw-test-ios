//
//  DownViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "DownViewController.h"
#import "TitleModel.h"
#import "TitleModelCellFrame.h"
#import "TitleTableViewCell.h"

#import "EffectsUtils.h"
#import "UIColor+Hex.h"

#import "AppDelegate.h"
#import "UserAccount.h"

#import "MyUserLoginViewController.h"
#import "MyProductRegViewController.h"

#import "MBProgressHUD.h"
#import "AppConstants.h"

#import "SwitchService.h"

#define __kDownViewController_title @"下载试卷"//

#define __kDownViewController_panelHeight 40//面板高度

#define __kDownViewController_btnTop 5//顶部间隔
#define __kDownViewController_btnLeft 15//顶部间隔
#define __kDownViewController_btnRight 15//顶部间隔
#define __kDownViewController_btnHeight 30//按钮高度
#define __kDownViewController_btnbgColor 0xFF0000//

#define __kDownViewController_cellIdentifer @"cell"//
//下载视图控制器成员变量
@interface DownViewController (){
    BOOL _isReload;
    NSMutableArray *_dataSource;
    UIColor *_btnColor;
    MBProgressHUD *_waitHud;
    UIAlertView *_alertView;
}
@end
//下载视图控制器实现
@implementation DownViewController

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super initWithStyle:UITableViewStyleGrouped]){
        _isReload = NO;
        _btnColor = [UIColor colorWithHex:__kDownViewController_btnbgColor];
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.title = __kDownViewController_title;
    //设置分隔符
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //加载数据
    [self loadData];
    //加载底部同步按钮
    [self loadFooterView];
}

//加载数据
-(void)loadData{
    //异步线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //初始化数据源
        _dataSource = [NSMutableArray array];
        
        //1.提示
        [_dataSource addObject:[self addTitle:@"提示:"]];
        //2.内容
        [_dataSource addObject:[self addTitle:@" 下载最新发布的试卷，使用者须登录并进行产品注册码的绑定."]];
        
        //updateUI
        dispatch_async(dispatch_get_main_queue(), ^{
            //刷新数据列表
            [self.tableView reloadData];
        });
    });
}

//安装数据内容模型
-(TitleModelCellFrame *)addTitle:(NSString *)title{
    TitleModelCellFrame *frame = [[TitleModelCellFrame alloc] init];
    frame.model = [[TitleModel alloc] initWithTitle:title];
    return frame;
}

//加载底部同步按钮
-(void)loadFooterView{
    CGFloat maxWidth = CGRectGetWidth(self.tableView.bounds) - __kDownViewController_btnRight;
    CGFloat x = __kDownViewController_btnLeft, y = __kDownViewController_btnTop;
    //
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maxWidth + __kDownViewController_btnRight, __kDownViewController_panelHeight)];
    //按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(x, y, maxWidth - x, __kDownViewController_btnHeight);
    [btn setTitle:@"下载最新试卷" forState:UIControlStateNormal];
    [btn setTitleColor:_btnColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnDownloadClick:) forControlEvents:UIControlEventTouchUpInside];
    [EffectsUtils addBoundsRadiusWithView:btn BorderColor:_btnColor BackgroundColor:nil];
    [self.tableView.tableFooterView addSubview:btn];
}

//下载按钮事件处理
-(void)btnDownloadClick:(UIButton *)sender{
    NSLog(@"下载按钮事件处理...");
    //等待动画
    _waitHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _waitHud.color = [UIColor colorWithHex:WAIT_HUD_COLOR];
    //异步线程处理
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        if(app && app.currentUser){//已登录
            //检查注册码
            NSString *regCode = app.currentUser.regCode;
            if(regCode && regCode.length > 0){//注册码存在
                SwitchService *service = [[SwitchService alloc] init];
                [service syncDownloadWithIgnoreRegCode:NO resultHandler:^(BOOL result, NSString *err) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //关闭等待动画
                        if(_waitHud){[_waitHud hide:YES];}
                        if(result){//下载成功
                            if(app){ [app resetRootController];}
                        }else{//下载失败
                            //初始化弹出框
                            _alertView = [[UIAlertView alloc] initWithTitle:@"下载失败" message:err delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                            //弹出
                            [_alertView show];
                        }
                    });
                }];
            }else{//注册码不存在
                //控制器跳转到注册码控制器
                dispatch_async(dispatch_get_main_queue(), ^{
                    //关闭等待动画
                    if(_waitHud){[_waitHud hide:YES];}
                    //注册码控制器
                    MyProductRegViewController *regController = [[MyProductRegViewController alloc] init];
                    regController.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:regController animated:YES];
                });
            }
        }else{
            //控制器跳转到登录UI
            dispatch_async(dispatch_get_main_queue(), ^{
                //关闭等待动画
                if(_waitHud){[_waitHud hide:YES];}
                //登录视图控制器
                MyUserLoginViewController *loginController = [[MyUserLoginViewController alloc] init];
                loginController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:loginController animated:YES];
            });
        }
    });
}

#pragma mark UITableViewDataSource
//数据行
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_dataSource){
        return _dataSource.count;
    }
    return 0;
}
//创建行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kDownViewController_cellIdentifer];
    if(!cell){
        cell = [[TitleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:__kDownViewController_cellIdentifer];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //加载数据
    [cell loadModelCellFrame:[_dataSource objectAtIndex:indexPath.row]];
    //返回行
    return cell;
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[_dataSource objectAtIndex:indexPath.row] cellHeight];
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
