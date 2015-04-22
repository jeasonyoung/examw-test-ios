//
//  ImitateSubjectViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ImitateSubjectViewController.h"
//#import "SubjectData.h"
#import "ImitateSubjectService.h"
#import "WaitForAnimation.h"

#import "ExamSection.h"
#import "SubjectCell.h"

#import "PaperListViewController.h"

#define __kImitateSubjectViewController_title @"选择科目"
#define __kImitateSubjectViewController_waiting @"加载中..."

//#define __kImitateSubjectViewController_more @"加载更多..."

#define __kImitateSubjectViewController_cellIdentifier @"row_cell"//
//#define __kImitateSubjectViewController_moreIdentifier @"row_more"//

#define __kImitateSubjectViewController_cellDetail @"试题%d套"

#define __kImitateSubjectViewController_fristPageIndex 1//第一页
//模拟考场科目视图控制器成员变量。
@interface ImitateSubjectViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    ImitateSubjectService *_service;
    NSArray *_examSectionCache;
    NSMutableDictionary *_subjectPapersCache,*_currentPageIndexCache;
    //WaitForAnimation *_wattingAnimation;
}
@end
//模拟考场科目视图控制器实现类。
@implementation ImitateSubjectViewController
//加载数据
- (void)viewDidLoad {
    [super viewDidLoad];
    //标题
    self.title = __kImitateSubjectViewController_title;
    //初始化服务类
    _service = [[ImitateSubjectService alloc] init];
    //加载全部的考试集合
    _examSectionCache = [_service loadExams];
    //初始化缓存
    _subjectPapersCache = [NSMutableDictionary dictionaryWithCapacity:_service.rowsOfPage];
    _currentPageIndexCache = [NSMutableDictionary dictionary];
    //添加列表
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    //初始化等待动画
    //_wattingAnimation = [[WaitForAnimation alloc]initWithView:self.view WaitTitle:__kImitateSubjectViewController_waiting];
}
#pragma mark tableView数据
//分组总数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_examSectionCache){
        return _examSectionCache.count;
    }
    return 0;
}
//显示每个分组的数据
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_examSectionCache && section < _examSectionCache.count){
        ExamSection *examSection = [_examSectionCache objectAtIndex:section];
        if(examSection && _service){
            NSNumber *sectionKey = [NSNumber numberWithInteger:section];
            //获取科目错题的缓存
            NSMutableArray *papersArrays = [_subjectPapersCache objectForKey:sectionKey];
            if(!papersArrays || papersArrays.count == 0){//缓存不存在则构建
                papersArrays = [NSMutableArray arrayWithCapacity:_service.rowsOfPage];
                //设置Section的当前页码
                [_currentPageIndexCache setObject:[NSNumber numberWithInteger:__kImitateSubjectViewController_fristPageIndex]
                                           forKey:sectionKey];
                //从数据库加载数据
                NSArray *arrays = [_service loadSubjectsWithExamCode:examSection.code
                                                               Index:__kImitateSubjectViewController_fristPageIndex];
                if(arrays && arrays.count > 0){
                    [papersArrays addObjectsFromArray:arrays];
                    [_subjectPapersCache setObject:papersArrays forKey:sectionKey];
                }
            }
            return papersArrays.count;
        }
    }
    return 0;
}
//显示分组名称
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(_examSectionCache && section < _examSectionCache.count){
        ExamSection *examSection = [_examSectionCache objectAtIndex:section];
        if(examSection)return examSection.name;
    }
    return nil;
}
//具体数据
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!_subjectPapersCache || _subjectPapersCache.count == 0)return nil;
    NSNumber *sectionKey = [NSNumber numberWithInteger:indexPath.section];
    NSArray *papersCache = [_subjectPapersCache objectForKey:sectionKey];
    if(papersCache && papersCache.count > 0){
        //加载更多
        if(indexPath.row > 0 && _currentPageIndexCache){
            NSNumber *pageIndex = [_currentPageIndexCache objectForKey:sectionKey];
            if((indexPath.row + 1)/_service.rowsOfPage >= pageIndex.integerValue){
                //后台线程处理
                [self performSelectorInBackground:@selector(loadMoreDataWithSection:) withObject:sectionKey];
            }
        }
        //加载内容
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kImitateSubjectViewController_cellIdentifier];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                         reuseIdentifier:__kImitateSubjectViewController_cellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        SubjectCell *data = [papersCache objectAtIndex:indexPath.row];
        if(data){
            cell.textLabel.text = data.name;
            cell.detailTextLabel.text = [NSString stringWithFormat:__kImitateSubjectViewController_cellDetail,(data.total ? data.total.intValue : 0)];
        }
        return cell;
    }
    return nil;
}
#pragma mark tableView代理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!_subjectPapersCache || _subjectPapersCache.count == 0)return;
    NSNumber *sectionKey = [NSNumber numberWithInteger:indexPath.section];
    NSArray *papersCache = [_subjectPapersCache objectForKey:sectionKey];
    if(!papersCache || papersCache.count == 0)return;
    //选中科目
    SubjectCell *data = [papersCache objectAtIndex:indexPath.row];
    if(!data || !data.code || data.code.length == 0)return;
    PaperListViewController *plc = [[PaperListViewController alloc]initWithSubjectCode:data.code];
    plc.hidesBottomBarWhenPushed = NO;
    [self.navigationController pushViewController:plc animated:NO];
}
//加载更多数据
-(void)loadMoreDataWithSection:(NSNumber *)section{
    if(!section || _examSectionCache || !_service)return;
    ExamSection *examSection = [_examSectionCache objectAtIndex:section.integerValue];
    if(examSection)return;
    NSInteger index = 0;
    NSNumber *pageIndex = [_currentPageIndexCache objectForKey:section];
    if(pageIndex)index = pageIndex.integerValue;
    index++;
    NSArray *moreArrays = [_service loadSubjectsWithExamCode:examSection.code Index:index];
    if(moreArrays && moreArrays.count > 0){
        [_currentPageIndexCache setObject:[NSNumber numberWithInteger:index] forKey:section];
        //前台线程追加数据
        [self performSelectorOnMainThread:@selector(appendCacheUpdate:) withObject:@[section,moreArrays] waitUntilDone:NO];
    }
}
//追加数据
-(void)appendCacheUpdate:(NSArray *)parameters{
    if(!_subjectPapersCache || !parameters || parameters.count < 2)return;
    NSNumber *sectionKey = [parameters objectAtIndex:0];
    NSArray *moreArrays = [parameters objectAtIndex:1];
    if(!sectionKey || !moreArrays || moreArrays.count == 0)return;
    //获取科目收藏的缓存
    NSMutableArray *sourcesArrays = [_subjectPapersCache objectForKey:sectionKey];
    if(!sourcesArrays)return;
    NSInteger pos = sourcesArrays.count;
    //追加到缓存
    [sourcesArrays addObjectsFromArray:moreArrays];
    //更新缓存
    [_subjectPapersCache setObject:sourcesArrays forKey:sectionKey];
    //更新TableView
    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:_service.rowsOfPage];
    for(NSInteger i = 0; i < moreArrays.count; i++){
        [insertIndexPaths addObject:[NSIndexPath indexPathForRow:(pos + i) inSection:sectionKey.integerValue]];
    }
    [_tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(_subjectPapersCache)[_subjectPapersCache removeAllObjects];
}
#pragma mark 内存回收
-(void)dealloc{
    if(_examSectionCache) _examSectionCache = nil;
    if(_subjectPapersCache)[_subjectPapersCache removeAllObjects];
}
@end
