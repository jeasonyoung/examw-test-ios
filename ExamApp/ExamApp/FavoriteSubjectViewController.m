//
//  FavoriteSubjectViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/20.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "FavoriteSubjectViewController.h"

#import "SubjectData.h"
#import "FavoriteService.h"
#import "WaitForAnimation.h"

#define __kFavoriteSubjectViewController_title @"我的收藏"
#define __kFavoriteSubjectViewController_waiting @"加载中..."
#define __kFavoriteSubjectViewController_cellIdentifier @"cell_identifier"
#define __kFavoriteSubjectViewController_cellDetail @"已收藏%ld题"
//收藏科目列表成员变量
@interface FavoriteSubjectViewController ()<UITableViewDataSource,UITableViewDelegate>{
    FavoriteService *_service;
    NSMutableDictionary *_cache;
}
@end
//收藏科目列表实现
@implementation FavoriteSubjectViewController
#pragma mark UI加载入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化缓存
    _cache = [NSMutableDictionary dictionary];
    //标题
    self.title = __kFavoriteSubjectViewController_title;
    //初始化服务
    _service = [[FavoriteService alloc]init];
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
//每个分组的数据量
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_service loadSubjectTotalWithExamIndex:section];
}
//显示分组名称
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_service loadExamTitleWithIndex:section];
}
//显示每个数据
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __block UITableViewCell *cell;
    [WaitForAnimation animationWithView:self.view WaitTitle:__kFavoriteSubjectViewController_waiting Block:^{
        cell = [tableView dequeueReusableCellWithIdentifier:__kFavoriteSubjectViewController_cellIdentifier];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                         reuseIdentifier:__kFavoriteSubjectViewController_cellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = cell.detailTextLabel.text = @"";
        [_service loadWithExamWithIndex:indexPath.section
                          andSubjectRow:indexPath.row
                                  Block:^(SubjectData *subject, NSInteger favorites) {
                                      //添加到缓存
                                      [_cache setObject:@[[NSNumber numberWithInteger:favorites],subject.code]
                                                 forKey:[NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.row]];
                                      
                                      cell.textLabel.text = subject.name;
                                      cell.detailTextLabel.text = [NSString stringWithFormat:__kFavoriteSubjectViewController_cellDetail,(long)favorites];
                                  }];
    }];
    return cell;
}
#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *array = [_cache objectForKey:[NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.row]];
    if(!array || array.count == 0)return;
    NSNumber *favorites = [array objectAtIndex:0];
    NSString *subjectCode = [array objectAtIndex:1];
    if(favorites && favorites.integerValue > 0 && subjectCode && subjectCode.length > 0){
        NSLog(@"%d,%d=>%@", indexPath.section,indexPath.row,array);
        
    }
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(_cache){
        [_cache removeAllObjects];
    }
}
#pragma mark 内存回收
-(void)dealloc{
    if(_cache){
        [_cache removeAllObjects];
    }
}
@end
