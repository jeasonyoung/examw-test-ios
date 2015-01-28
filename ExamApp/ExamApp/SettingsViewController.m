//
//  SettingsController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingData.h"
#import "UIViewController+VisibleView.h"
#import "DefaultViewController.h"

#import "ScreenViewController.h"
//设置页控制器成员变量
@interface SettingsViewController ()<UITableViewDataSource,UITableViewDelegate>{
    //设置分组数据
    NSDictionary *_groups;
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
        
    }else if([@"sync" isEqualToString:value]){//2.同步与更新
        
    }else if([@"share" isEqualToString:value]){//3.分享好友
        
    }else if([@"screen" isEqualToString:value]){//4.屏幕亮度
        controller = [[ScreenViewController alloc] initWithSetting:data];
    }else if([@"website" isEqualToString:value]){//5.访问主站
        if(data.data == nil || data.data.length == 0){
            UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:data.title message:@"站点地址不存在！" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alterView show];
        }else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:data.data]];
        }
        return;
    }else if([@"clean" isEqualToString:value]){//6.清除缓存
        
        
        
    }else if([@"feedback" isEqualToString:value]){//7.意见反馈
        
    }else if([@"protocol" isEqualToString:value]){//8.隐私协议
        
    }else if([@"about" isEqualToString:value]){//9.关于应用
        
    }else if([@"account" isEqualToString:value]){//10.当前账号
        
    }
    
    if(controller == nil){
        controller = [[DefaultViewController alloc] init];
    }
    if(controller && self.navigationController){
        controller.navigationItem.title = data.title;
        //设置动画效果
        CATransition *animation = [CATransition animation];
        animation.delegate = self;
        animation.duration = 0.5;
        animation.type = kCATransitionPush;
        animation.subtype = kCATransitionFromRight;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.navigationController.view.layer addAnimation:animation forKey:nil];
        
        [self.navigationController pushViewController:controller animated:NO];
    }
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
