//
//  ImitateSubjectViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ImitateSubjectViewController.h"
#import "SubjectData.h"
#import "ImitateSubjectService.h"
#import "WaitForAnimation.h"

#import "PaperListViewController.h"

#define __k_imitatesubjectview_title @"选择科目"
#define __k_imitatesubjectview_waiting @"正在加载数据..."
#define __k_imitatesubjectview_cell_identifier @"cell_identifier"

//模拟考场科目视图控制器成员变量。
@interface ImitateSubjectViewController ()<UITableViewDelegate,UITableViewDataSource>{
    ImitateSubjectService *_service;
}
@end
//模拟考场科目视图控制器实现类。
@implementation ImitateSubjectViewController
//加载数据
- (void)viewDidLoad {
    [super viewDidLoad];
    //标题处理
    self.title = __k_imitatesubjectview_title;
    //初始化服务类
    _service = [[ImitateSubjectService alloc] init];
    //添加列表
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}
#pragma mark tableView数据
//分组总数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    __block NSInteger sections = 0;
    [WaitForAnimation animationWithView:self.view WaitTitle:__k_imitatesubjectview_waiting Block:^{
         sections = [_service loadAllExamTotal];
    }];
    return sections;
}
//显示每个分组的数据
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    __block NSInteger rows = 0;
    [WaitForAnimation animationWithView:self.view WaitTitle:__k_imitatesubjectview_waiting Block:^{
        rows = [_service loadSubjectTotalWithExamIndex:section];
    }];
    return rows;
}
//显示分组名称
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    __block NSString *title;
    [WaitForAnimation animationWithView:self.view WaitTitle:__k_imitatesubjectview_waiting Block:^{
        title = [_service loadExamTitleWithIndex:section];
    }];
    return title;
}
//具体数据
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __block UITableViewCell *cell;
    [WaitForAnimation animationWithView:self.view WaitTitle:__k_imitatesubjectview_waiting Block:^{
        cell = [tableView dequeueReusableCellWithIdentifier:__k_imitatesubjectview_cell_identifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:__k_imitatesubjectview_cell_identifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        SubjectData *subject = [_service loadSubjectWithExamIndex:indexPath.section andSubjectRow:indexPath.row];
        if(subject){
            cell.textLabel.text = subject.name;
        }
    }];
    return cell;
}
#pragma mark tableView代理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SubjectData *subject = [_service loadSubjectWithExamIndex:indexPath.section andSubjectRow:indexPath.row];
    //NSLog(@"click:%ld,%ld => %@",indexPath.section, indexPath.row, [subject serializeJSON]);
    PaperListViewController *plc = [[PaperListViewController alloc] initWithSubjectCode:subject.code];
    plc.title = subject.name;
    [self.navigationController pushViewController:plc animated:NO];
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
