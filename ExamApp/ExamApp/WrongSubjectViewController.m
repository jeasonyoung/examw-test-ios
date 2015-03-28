//
//  WrongSubjectViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "WrongSubjectViewController.h"

#import "WaitForAnimation.h"
#import "SubjectData.h"

#import "WrongItemRecordService.h"

#import "WrongViewController.h"

#define __kWrongSubjectViewController_title @"错题重做"
#define __kWrongSubjectViewController_waiting @"加载中..."
#define __kWrongSubjectViewController_cellIdentifier @"cell_identifier"
#define __kWrongSubjectViewController_cellDetail @"做错%ld题次"
//错题重做科目视图控制器成员变量
@interface WrongSubjectViewController ()<UITableViewDataSource,UITableViewDelegate>{
    WrongItemRecordService *_service;
    NSMutableDictionary *_wrongSubjectCache;
}
@end
//错题重做科目视图控制器实现
@implementation WrongSubjectViewController
#pragma mark UI加载入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化缓存
    _wrongSubjectCache = [NSMutableDictionary dictionary];
    //初始化数据服务
    _service = [[WrongItemRecordService alloc]init];
    //添加列表
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
}

#pragma mark UITableViewDataSource
//分组总数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_service loadAllExamTotal];
}
//每个分组数量
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_service loadSubjectTotalWithExamIndex:section];
}
//显示分组名称
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_service loadExamTitleWithSection:section];
}
//显示每个数据
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __block UITableViewCell *cell;
    [WaitForAnimation animationWithView:self.view WaitTitle:__kWrongSubjectViewController_waiting Block:^{
        cell = [tableView dequeueReusableCellWithIdentifier:__kWrongSubjectViewController_cellIdentifier];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                         reuseIdentifier:__kWrongSubjectViewController_cellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = cell.detailTextLabel.text = @"";
        [_service loadSubjectWithExamAtSection:indexPath.section
                                        andRow:indexPath.row
                                          Data:^(SubjectData *subject, NSInteger wrongs) {
                                              //添加到缓存
                                              [_wrongSubjectCache setObject:@[[NSNumber numberWithInteger:wrongs],subject.code]
                                                                     forKey:[NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.row]];
                                              cell.textLabel.text = subject.name;
                                              cell.detailTextLabel.text = [NSString stringWithFormat:__kWrongSubjectViewController_cellDetail,(long)wrongs];
                                          }];
    }];
    return cell;
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!_wrongSubjectCache)return;
    NSArray *array = [_wrongSubjectCache objectForKey:[NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.row]];
    if(!array || array.count == 0)return;
    NSNumber *wrongs = [array objectAtIndex:0];
    NSString *subjectCode = [array objectAtIndex:1];
    if(wrongs && wrongs.integerValue > 0 && subjectCode && subjectCode.length > 0){
        //NSLog(@"%@,%@",wrongs,subjectCode);
        WrongViewController *wvc = [[WrongViewController alloc]initWithSubjectCode:subjectCode];
        wvc.hidesBottomBarWhenPushed = NO;
        [self.navigationController pushViewController:wvc animated:NO];
    }
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(_wrongSubjectCache && _wrongSubjectCache.count){
        [_wrongSubjectCache removeAllObjects];
    }
}
@end
