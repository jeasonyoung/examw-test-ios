//
//  ChoiceProductsViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/4/8.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ChoiceProductsViewController.h"
#import "AppClientSettings.h"
#import "AppDelegate.h"
#import "JSONCallback.h"
#import "WaitForAnimation.h"
#import "HttpUtils.h"
#import "MainViewController.h"

#import "ProductData.h"
#import "ProductDataCellFrame.h"
#import "ProductTableViewCell.h"
#import "DataSyncService.h"

#define __kChoiceProductsViewController_title @"选择产品"
#define __kChoiceProductsViewController_waitting @"加载数据..."
#define __kChoiceProductsViewController_syncWaitting @"正在同步..."
#define __kChoiceProductsViewController_errTitle @"发生异常"

#define __kChoiceProductsViewController_btnSubmit @"确定"
#define __kChoiceProductsViewController_btnCancel @"取消"

#define __kChoiceProductsViewController_identity @"_ChoiceProductsViewController_cell"
#define __kChoiceProductsViewController_defultRowHeight 70//
//选择产品视图控制器成员变量
@interface ChoiceProductsViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>{
    //应用客户端设置
    AppClientSettings *_appSettings;
    //数据缓存
    NSMutableArray *_dataCache;
    //数据显示
    UITableView *_tableView;
}
@end
//选择产品视图控制器实现
@implementation ChoiceProductsViewController
#pragma mark 重构初始化
-(instancetype)init{
    if(self = [super init]){
        _appSettings = [AppClientSettings clientSettings];
    }
    return self;
}
#pragma mark 切换视图控制器
-(void)gotoController{
    //产品注册已选择
    if(_appSettings.appClientProductID && _appSettings.appClientProductID.length > 0){
        MainViewController *mvc = [[MainViewController alloc]init];
        [mvc gotoController];
        return;
    }
    //设置自定义转场动画
    CATransition *trans = [self createCustomTransitionAnimation];
    if(trans){
        [self.view.layer addAnimation:trans forKey:@"ChoiceProductsViewController_trans"];
    }
    //获取应用代理
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    if(app){
        //将当前控制器设置为根控制器
        app.window.rootViewController = self;
        //显示当前
        [app.window makeKeyAndVisible];
    }
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.title = __kChoiceProductsViewController_title;
    
    //添加数据显示列表
    _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    //加载远程数据
    [self loadRemoteData];
}
//加载远程数据
-(void)loadRemoteData{
    //初始化等待动画
    WaitForAnimation *waitAnimation = [[WaitForAnimation alloc]initWithView:self.view
                                                                  WaitTitle:__kChoiceProductsViewController_waitting];
    //开启等待动画
    [waitAnimation show];
    //检查网络
    [HttpUtils netWorkStatus:^(BOOL statusValue) {
        if(!statusValue){
            //关闭等待动画
            [waitAnimation hide];
        }else{
            [HttpUtils JSONDataDigestWithUrl:_appSettings.syncProductsUrl
                                      Method:HttpUtilsMethodGET
                                  Parameters:nil
                                    Username:_appSettings.digestUsername
                                    Password:_appSettings.digestPassword
                                     Success:^(NSDictionary *dict) {//数据反馈
                                         //关闭等待动画
                                         [waitAnimation hide];
                                         //获取反馈
                                         JSONCallback *callback = [[JSONCallback alloc]initWithDictionary:dict];
                                         if(callback.success){
                                             
                                             if(callback.data && [callback.data isKindOfClass:[NSArray class]]){
                                                 //数据转换
                                                 [self transToProductsWithArrays:((NSArray *)callback.data)];
                                             }
                                             
                                         }else{//服务器错误
                                             [self showAlterWithTitle:__kChoiceProductsViewController_errTitle
                                                              Message:callback.msg];
                                         }
                                        }
                                        Fail:^(NSString *err) {//网络异常
                                            NSLog(@"ChoiceProductsViewController=>loadRemoteData:%@",err);
                                            //关闭等待动画
                                            [waitAnimation hide];
                                            //
                                            [self showAlterWithTitle:__kChoiceProductsViewController_errTitle
                                                             Message:err];
                                        }];
        }
    }];
}
//加载数据
-(void)transToProductsWithArrays:(NSArray *)arrays{
    _dataCache = [NSMutableArray array];
    if(arrays && arrays.count > 0){
        //循环创建
        for(NSDictionary *dict in arrays){
            if(!dict || dict.count == 0)continue;
            ProductDataCellFrame *cellData = [[ProductDataCellFrame alloc]init];
            cellData.data = [[ProductData alloc]initWithDict:dict];
            [_dataCache addObject:cellData];
        }
        //
        if(_dataCache.count > 0 && _tableView){
            [_tableView reloadData];
        }
    }
}
//显示弹出信息
-(void)showAlterWithTitle:(NSString *)title Message:(NSString *)msg{
    if(msg && msg.length > 0){
        UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:title
                                                           message:msg
                                                          delegate:nil
                                                 cancelButtonTitle:__kChoiceProductsViewController_btnSubmit
                                                 otherButtonTitles:nil, nil];
        [alterView show];
    }
}
#pragma mark UITableViewDataSource
//分组总数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return __kChoiceProductsViewController_title;
}
//数据总数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_dataCache){
        return _dataCache.count;
    }
    return 0;
}
//显示每个数据
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_dataCache && indexPath.row < _dataCache.count){
        ProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kChoiceProductsViewController_identity];
        if(!cell){
            cell = [[ProductTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:__kChoiceProductsViewController_identity];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        //加载数据
        [cell loadDataWithProduct:[_dataCache objectAtIndex:indexPath.row]];
        return cell;
    }
    return nil;
}
#pragma mark UITableViewDelegate
//加载每行数据高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_dataCache && indexPath.row < _dataCache.count){
        return [[_dataCache objectAtIndex:indexPath.row] rowHeight];
    }
    return __kChoiceProductsViewController_defultRowHeight;
}
//选中行数据
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_dataCache && indexPath.row < _dataCache.count){
        ProductDataCellFrame *cellData = (ProductDataCellFrame *)[_dataCache objectAtIndex:indexPath.row];
        if(!cellData) return;
        //初始化弹出框
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:__kChoiceProductsViewController_title
                                                       message:cellData.product
                                                      delegate:self
                                             cancelButtonTitle:__kChoiceProductsViewController_btnCancel
                                             otherButtonTitles:__kChoiceProductsViewController_btnSubmit, nil];
        alert.tag = indexPath.row;
        [alert show];
    }
}
#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0)return;
    if(_appSettings && _dataCache && _dataCache.count > alertView.tag){
        NSLog(@"buttonIndex=>%d",(int)buttonIndex);
        ProductDataCellFrame *cellData = (ProductDataCellFrame *)[_dataCache objectAtIndex:alertView.tag];
        if(cellData && cellData.data){
            ProductData *product = cellData.data;
            //更新保存产品数据
            [_appSettings updateWithProductID:product.code andProductName:product.name];
            //调用同步数据
            [self startSyncData];
        }
    }
}
//开始同步数据
-(void)startSyncData{
    //初始化等待动画
    WaitForAnimation *syncWaitfor = [[WaitForAnimation alloc]initWithView:self.view
                                                                WaitTitle:__kChoiceProductsViewController_syncWaitting];
    //启动等待动画
    [syncWaitfor show];
    //开始同步数据
    DataSyncService *syncService = [[DataSyncService alloc] init];
    syncService.ignoreCode = YES;
    [syncService sync:^(NSString *err){
        //关闭等待动画
        [syncWaitfor hide];
        //显示弹出框
        if(err && err.length > 0){
            [self showAlterWithTitle:__kChoiceProductsViewController_errTitle Message:err];
        }else{//同步完成后的跳转
            [self gotoController];
        }
    }];
}
//创建自定义转场动画
-(CATransition *)createCustomTransitionAnimation{
    //设置动画效果
    CATransition *animation = [CATransition animation];
    animation.duration = 0.9f;
    animation.type = kCATransitionFade;
    animation.subtype = kCATransitionFromRight;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animation;
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];    
}
@end
