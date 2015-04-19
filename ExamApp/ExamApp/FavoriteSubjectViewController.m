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

#import "ExamSection.h"
#import "SubjectCell.h"

#import "FavoriteViewController.h"

#define __kFavoriteSubjectViewController_title @"我的收藏"
#define __kFavoriteSubjectViewController_waiting @"加载中..."

#define __kFavoriteSubjectViewController_more @"加载更多..."

#define __kFavoriteSubjectViewController_cellIdentifier @"row_cell"//
#define __kFavoriteSubjectViewController_moreIdentifier @"row_more"//

#define __kFavoriteSubjectViewController_cellDetail @"已收藏%d题"

#define __kFavoriteSubjectViewController_fristPageIndex 1//
//收藏科目列表成员变量
@interface FavoriteSubjectViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    FavoriteService *_service;
    NSArray *_examSectionCache;
    NSMutableDictionary *_subjectFavoriteCache,*_currentPageIndexCache;
    WaitForAnimation *_wattingAnimation;
}
@end
//收藏科目列表实现
@implementation FavoriteSubjectViewController
#pragma mark UI加载入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //标题
    self.title = __kFavoriteSubjectViewController_title;
    //初始化服务
    _service = [[FavoriteService alloc]init];
    //加载全部的考试集合
    _examSectionCache = [_service loadExams];
    //初始化缓存
    _subjectFavoriteCache = [NSMutableDictionary dictionaryWithCapacity:_service.rowsOfPage];
    _currentPageIndexCache = [NSMutableDictionary dictionary];
    //添加列表
    _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    //初始化等待动画
    _wattingAnimation = [[WaitForAnimation alloc]initWithView:self.view WaitTitle:__kFavoriteSubjectViewController_waiting];
}

#pragma mark UITableViewDataSource
//分组总数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_examSectionCache){
        return _examSectionCache.count;
    }
    return 0;
}
//每个分组的数据量
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_examSectionCache && section < _examSectionCache.count){
        ExamSection *examSection = [_examSectionCache objectAtIndex:section];
        if(examSection && _service){
            NSNumber *sectionKey = [NSNumber numberWithInteger:section];
            //获取科目收藏的缓存
            NSMutableArray *sourcesArrays = [_subjectFavoriteCache objectForKey:sectionKey];
            if(!sourcesArrays || sourcesArrays.count == 0){//缓存不存在则构建
                sourcesArrays = [NSMutableArray arrayWithCapacity:_service.rowsOfPage];
                //设置Section的当前页码
                [_currentPageIndexCache setObject:[NSNumber numberWithInteger:__kFavoriteSubjectViewController_fristPageIndex]
                                           forKey:sectionKey];
                //从数据库加载数据
                NSArray *arrays = [_service loadSubjectsWithExamCode:examSection.code
                                                               Index:__kFavoriteSubjectViewController_fristPageIndex];
                if(arrays && arrays.count > 0){
                    [sourcesArrays addObjectsFromArray:arrays];
                    [_subjectFavoriteCache setObject:sourcesArrays forKey:sectionKey];
                }
            }
            return sourcesArrays.count + 1;
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
    if(!_subjectFavoriteCache || _subjectFavoriteCache.count == 0)return nil;
    NSNumber *sectionKey = [NSNumber numberWithInteger:indexPath.section];
    NSArray *favoritesCache = [_subjectFavoriteCache objectForKey:sectionKey];
    if(favoritesCache && favoritesCache.count > 0){
        //加载更多
        if(indexPath.row == favoritesCache.count){
            UITableViewCell *moreCell = [tableView dequeueReusableCellWithIdentifier:__kFavoriteSubjectViewController_moreIdentifier];
            if(!moreCell){
                moreCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:__kFavoriteSubjectViewController_moreIdentifier];
                moreCell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
                moreCell.textLabel.textColor = [UIColor darkGrayColor];
                moreCell.textLabel.textAlignment = NSTextAlignmentCenter;
            }
            moreCell.textLabel.text = (indexPath.row < _service.rowsOfPage ? @"" : __kFavoriteSubjectViewController_more);
            return moreCell;
        }
        //越界
        if(indexPath.row > favoritesCache.count) return nil;
        //加载内容
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kFavoriteSubjectViewController_cellIdentifier];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                         reuseIdentifier:__kFavoriteSubjectViewController_cellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        SubjectCell *data = [favoritesCache objectAtIndex:indexPath.row];
        if(data){
            cell.textLabel.text = data.name;
            cell.detailTextLabel.text = [NSString stringWithFormat:__kFavoriteSubjectViewController_cellDetail,(data.total ? data.total.intValue : 0)];
        }
        return cell;
    }
    return nil;
}
#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!_subjectFavoriteCache || _subjectFavoriteCache.count == 0)return;
    NSNumber *sectionKey = [NSNumber numberWithInteger:indexPath.section];
    NSArray *favoritesCache = [_subjectFavoriteCache objectForKey:sectionKey];
    if(!favoritesCache || favoritesCache.count == 0)return;
    //加载更多数据
    if(indexPath.row == favoritesCache.count){
        if(indexPath.row < _service.rowsOfPage)return;
        //开启等待动画
        [_wattingAnimation show];
        //修改文字
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.text = __kFavoriteSubjectViewController_waiting;
        //后台线程处理
        [self performSelectorInBackground:@selector(loadMoreDataWithSection:) withObject:sectionKey];
        //关闭等待动画
        [_wattingAnimation hide];
        //取消选中
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    //选中科目
    SubjectCell *data = [favoritesCache objectAtIndex:indexPath.row];
    if(!data || !data.code || data.code.length == 0)return;
    if(!data.total || data.total.integerValue == 0)return;
    FavoriteViewController *fvc = [[FavoriteViewController alloc]initWithSubjectCode:data.code];
    fvc.hidesBottomBarWhenPushed = NO;
    [self.navigationController pushViewController:fvc animated:NO];
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
    if(!_subjectFavoriteCache || !parameters || parameters.count < 2)return;
    NSNumber *sectionKey = [parameters objectAtIndex:0];
    NSArray *moreArrays = [parameters objectAtIndex:1];
    if(!sectionKey || !moreArrays || moreArrays.count == 0)return;
    //获取科目收藏的缓存
    NSMutableArray *sourcesArrays = [_subjectFavoriteCache objectForKey:sectionKey];
    if(!sourcesArrays)return;
    NSInteger pos = sourcesArrays.count;
    //追加到缓存
    [sourcesArrays addObjectsFromArray:moreArrays];
    //更新缓存
    [_subjectFavoriteCache setObject:sourcesArrays forKey:sectionKey];
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
    if(_subjectFavoriteCache)[_subjectFavoriteCache removeAllObjects];
}
#pragma mark 内存回收
-(void)dealloc{
   if(_examSectionCache) _examSectionCache = nil;
    if(_subjectFavoriteCache)[_subjectFavoriteCache removeAllObjects];
}
@end
