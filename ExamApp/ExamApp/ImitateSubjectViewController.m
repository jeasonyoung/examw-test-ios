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

#define __k_imitateSubjectView_title @"选择科目"
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
    self.title = __k_imitateSubjectView_title;
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
    return [_service loadAllExamTotal];
}
//显示每个分组的数据
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_service loadSubjectTotalWithExamIndex:section];
}
//显示分组名称
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_service loadExamTitleWithIndex:section];
}
//具体数据
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cell_identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_identifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    SubjectData *subject = [_service loadSubjectWithExamIndex:indexPath.section andSubjectRow:indexPath.row];
    if(subject){
        cell.textLabel.text = subject.name;
    }
    return cell;
}
#pragma mark tableView代理
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.0f;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"click:%ld,%ld",indexPath.section, indexPath.row);
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
