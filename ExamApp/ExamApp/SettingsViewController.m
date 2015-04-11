//
//  SettingsController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIViewController+VisibleView.h"

#import "SettingData.h"

#import "DefaultViewController.h"//默认控制器
#import "ScreenViewController.h"//屏幕亮度控制器
#import "FeedbackViewController.h"//意见反馈控制器
#import "ProtocolViewController.h"//隐私协议控制器
#import "AboutViewController.h"//关于应用控制器
#import "AccountViewController.h"//当前账号控制器
#import "DateViewController.h"//考试日期设置控制器
#import "ChoiceProductsViewController.h"//选择产品

#import "ETAlert.h"
#import "WaitForAnimation.h"
#import "DataSyncService.h"

#define __kSettingsViewController_syncTitle @"同步确认"
#define __kSettingsViewController_syncMsg @"是否确定从服务器同步数据?"
#define __kSettingsViewController_syncBtnSubmit @"确定"
#define __kSettingsViewController_syncBtnCancel @"取消"
#define __kSettingsViewController_syncWaitting @"正在同步数据，请稍后..."
#define __kSettingsViewController_syncSuccess @"同步成功!"
#define __kSettingsViewController_syncFailure @"同步失败!"

//设置页控制器成员变量
@interface SettingsViewController ()<UITableViewDataSource,UITableViewDelegate>{
    //设置分组数据
    NSDictionary *_groups;
    //同步数据等待动画
    //WaitForAnimation *_syncWaiting;
}
@end
//设置页控制器实现类
@implementation SettingsViewController
#pragma mark 加载入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //加载设置数据集合
    _groups = [SettingData settingDataGroups];
    //加载TabView控件
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
}
//加载数据
-(SettingData *)loadSettingDataWithIndexPath:(NSIndexPath *)indexPath{
    NSArray *array = [SettingData settingDataWithGroups:_groups forGroup:(int)indexPath.section];
    if(array == nil || array.count == 0) return nil;
    return [array objectAtIndex:indexPath.row];
}

#pragma mark UITableViewDataSource
#pragma mark 数据分组
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _groups.count;
}
#pragma mark 每组数据条数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = [SettingData settingDataWithGroups:_groups forGroup:(int)section];
    if(array == nil) return 0;
    return array.count;
}
#pragma mark 显示数据列
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SettingData *data = [self loadSettingDataWithIndexPath:indexPath];
    if(data == nil) return nil;
    
    static NSString *cell_ident = @"cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cell_ident];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell_ident];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //NSLog(@"create UITableViewCell ....section=%d,row= %d", (int)indexPath.section, (int)indexPath.row);
    }
    cell.textLabel.text = data.title;
    cell.detailTextLabel.text = data.data;
    //NSLog(@"cell text - %@", data.title);
    
    return cell;
}
#pragma mark UITableViewDelegate
#pragma mark 分组header的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return (section == 0) ? 3 : 5;
}
#pragma mark 选中的数据
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SettingData *data = [self loadSettingDataWithIndexPath:indexPath];
    NSString *value = data.key;
    UIViewController *controller;
    if([@"date" isEqualToString:value]){//1.考试日期设置
        controller = [[DateViewController alloc]init];
    }else if([@"product" isEqualToString:value]){//变更产品
        controller = [[ChoiceProductsViewController alloc]init];
    }else if([@"sync" isEqualToString:value]){//2.同步与更新
        [self syncDataAlter];
        return;
    }/*else if([@"share" isEqualToString:value]){//3.分享好友
        
    }*/else if([@"screen" isEqualToString:value]){//4.屏幕亮度
        controller = [[ScreenViewController alloc] init];
    }else if([@"website" isEqualToString:value]){//5.访问主站
        [self createWebsiteControllerWithTitle:data.title Url:data.data];
        return;
    }/*else if([@"clean" isEqualToString:value]){//6.清除缓存
      
    }*/else if([@"feedback" isEqualToString:value]){//7.意见反馈
        controller = [[FeedbackViewController alloc] init];
    }else if([@"protocol" isEqualToString:value]){//8.隐私协议
        controller = [[ProtocolViewController alloc] init];
    }else if([@"about" isEqualToString:value]){//9.关于应用
        controller = [[AboutViewController alloc] init];
    }else if([@"account" isEqualToString:value]){//10.当前账号
        controller = [[AccountViewController alloc] init];
    }
    if(controller == nil){
        controller = [[DefaultViewController alloc] init];
    }
    if(controller && self.navigationController){
        controller.navigationItem.title = data.title;
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:NO];
    }
}
#pragma mark 访问主站
-(void)createWebsiteControllerWithTitle:(NSString *)title Url:(NSString *)url{
    if(url  == nil || url.length == 0){
         UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:title message:@"站点地址不存在！" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alterView show];
        return;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}
#pragma mark 同步数据
-(void)syncDataAlter{
    //初始化弹出框
    ETAlert *alert = [[ETAlert alloc] initWithTitle:__kSettingsViewController_syncTitle
                                            Message:__kSettingsViewController_syncMsg];
    //添加确定按钮
    [alert addConfirmActionWithTitle:__kSettingsViewController_syncBtnSubmit
                             Handler:^(UIAlertAction *action) {
                                 //初始化等待动画
                                 WaitForAnimation *waitForAni = [[WaitForAnimation alloc]initWithView:self.view
                                                                                    WaitTitle:__kSettingsViewController_syncWaitting];
                                 //开启等待动画
                                 [waitForAni show];
                                 //开始同步
                                 [[[DataSyncService alloc]init]sync:^(NSString *err) {
                                     //关闭等待动画
                                     [waitForAni hide];
                                     //显示同步结果
                                     [ETAlert alertWithTitle:(err?__kSettingsViewController_syncFailure: __kSettingsViewController_syncSuccess)
                                                     Message:err
                                                 ButtonTitle:__kSettingsViewController_syncBtnSubmit
                                                  Controller:self];
                                 }];
                             }];
    //添加取消按钮
    [alert addCancelActionWithTitle:__kSettingsViewController_syncBtnCancel Handler:nil];
    //显示弹出框
    [alert showWithController:self];
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
