//
//  WrongSubjectViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "WrongSubjectViewController.h"

#import "WaitForAnimation.h"

#import "ExamSection.h"
#import "SubjectCell.h"
//#import "SubjectData.h"

#import "WrongItemRecordService.h"

#import "WrongViewController.h"

#define __kWrongSubjectViewController_title @"错题重做"

#define __kWrongSubjectViewController_waiting @"加载中..."

#define __kWrongSubjectViewController_more @"加载更多..."

#define __kWrongSubjectViewController_cellIdentifier @"row_cell"//
#define __kWrongSubjectViewController_moreIdentifier @"row_more"//

#define __kWrongSubjectViewController_cellDetail @"做错%d题次"

#define __kWrongSubjectViewController_fristPageIndex 1//
//错题重做科目视图控制器成员变量
@interface WrongSubjectViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    WrongItemRecordService *_service;
    NSArray *_examSectionCache;
    NSMutableDictionary *_subjectWrongCache,*_currentPageIndexCache;
    WaitForAnimation *_wattingAnimation;
}
@end
//错题重做科目视图控制器实现
@implementation WrongSubjectViewController
#pragma mark UI加载入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //标题
    self.title = __kWrongSubjectViewController_title;
    //初始化数据服务
    _service = [[WrongItemRecordService alloc]init];
    //加载全部的考试集合
    _examSectionCache = [_service loadExams];
    //初始化缓存
    _subjectWrongCache = [NSMutableDictionary dictionaryWithCapacity:_service.rowsOfPage];
    _currentPageIndexCache = [NSMutableDictionary dictionary];
    //添加列表
    _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    //初始化等待动画
    _wattingAnimation = [[WaitForAnimation alloc]initWithView:self.view WaitTitle:__kWrongSubjectViewController_waiting];
}

#pragma mark UITableViewDataSource
//分组总数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_examSectionCache){
        return _examSectionCache.count;
    }
    return 0;
}
//每个分组数量
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_examSectionCache && section < _examSectionCache.count){
        ExamSection *examSection = [_examSectionCache objectAtIndex:section];
        if(examSection && _service){
            NSNumber *sectionKey = [NSNumber numberWithInteger:section];
            //获取科目错题的缓存
            NSMutableArray *wrongArrays = [_subjectWrongCache objectForKey:sectionKey];
            if(!wrongArrays || wrongArrays.count == 0){//缓存不存在则构建
                wrongArrays = [NSMutableArray arrayWithCapacity:_service.rowsOfPage];
                //设置Section的当前页码
                [_currentPageIndexCache setObject:[NSNumber numberWithInteger:__kWrongSubjectViewController_fristPageIndex]
                                           forKey:sectionKey];
                //从数据库加载数据
                NSArray *arrays = [_service loadSubjectsWithExamCode:examSection.code
                                                               Index:__kWrongSubjectViewController_fristPageIndex];
                if(arrays && arrays.count > 0){
                    [wrongArrays addObjectsFromArray:arrays];
                    [_subjectWrongCache setObject:wrongArrays forKey:sectionKey];
                }
            }
            return wrongArrays.count + 1;
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
//显示每个数据
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!_subjectWrongCache || _subjectWrongCache.count == 0)return nil;
    NSNumber *sectionKey = [NSNumber numberWithInteger:indexPath.section];
    NSArray *wrongsCache = [_subjectWrongCache objectForKey:sectionKey];
    if(wrongsCache && wrongsCache.count > 0){
        //加载更多
        if(indexPath.row == wrongsCache.count){
            UITableViewCell *moreCell = [tableView dequeueReusableCellWithIdentifier:__kWrongSubjectViewController_moreIdentifier];
            if(!moreCell){
                moreCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:__kWrongSubjectViewController_moreIdentifier];
                moreCell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
                moreCell.textLabel.textColor = [UIColor darkGrayColor];
                moreCell.textLabel.textAlignment = NSTextAlignmentCenter;
            }
            moreCell.textLabel.text = (indexPath.row < _service.rowsOfPage ? @"" : __kWrongSubjectViewController_more);
            return moreCell;
        }
        //越界
        if(indexPath.row > wrongsCache.count) return nil;
        //加载内容
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kWrongSubjectViewController_cellIdentifier];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                         reuseIdentifier:__kWrongSubjectViewController_cellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        SubjectCell *data = [wrongsCache objectAtIndex:indexPath.row];
        if(data){
            cell.textLabel.text = data.name;
            cell.detailTextLabel.text = [NSString stringWithFormat:__kWrongSubjectViewController_cellDetail,(data.total ? data.total.intValue : 0)];
        }
        return cell;
    }
    return nil;
}
#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!_subjectWrongCache || _subjectWrongCache.count == 0)return;
    NSNumber *sectionKey = [NSNumber numberWithInteger:indexPath.section];
    NSArray *wrongsCache = [_subjectWrongCache objectForKey:sectionKey];
    if(!wrongsCache || wrongsCache.count == 0)return;
    //加载更多数据
    if(indexPath.row == wrongsCache.count){
        if(indexPath.row < _service.rowsOfPage)return;
        //开启等待动画
        [_wattingAnimation show];
        //修改文字
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.text = __kWrongSubjectViewController_waiting;
        //后台线程处理
        [self performSelectorInBackground:@selector(loadMoreDataWithSection:) withObject:sectionKey];
        //关闭等待动画
        [_wattingAnimation hide];
        //取消选中
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    //选中科目
    SubjectCell *data = [wrongsCache objectAtIndex:indexPath.row];
    if(!data || !data.code || data.code.length == 0)return;
    WrongViewController *wvc = [[WrongViewController alloc]initWithSubjectCode:data.code];
    wvc.hidesBottomBarWhenPushed = NO;
    [self.navigationController pushViewController:wvc animated:NO];
}
//加载更多数据
-(void)loadMoreDataWithSection:(NSNumber *)section{
    if(!section || !_service) return;
    ExamSection *examSection = [_examSectionCache objectAtIndex:section.integerValue];
    if(!examSection)return;
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
    if(!_subjectWrongCache || !parameters || parameters.count < 2)return;
    NSNumber *sectionKey = [parameters objectAtIndex:0];
    NSArray *moreArrays = [parameters objectAtIndex:1];
    if(!sectionKey || !moreArrays || moreArrays.count == 0)return;
    //获取科目收藏的缓存
    NSMutableArray *sourcesArrays = [_subjectWrongCache objectForKey:sectionKey];
    if(!sourcesArrays)return;
    NSInteger pos = sourcesArrays.count;
    //追加到缓存
    [sourcesArrays addObjectsFromArray:moreArrays];
    //更新缓存
    [_subjectWrongCache setObject:sourcesArrays forKey:sectionKey];
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
    if(_subjectWrongCache)[_subjectWrongCache removeAllObjects];
}
#pragma mark 内存回收
-(void)dealloc{
    if(_examSectionCache)_examSectionCache = nil;
    if(_subjectWrongCache)[_subjectWrongCache removeAllObjects];
}
@end
