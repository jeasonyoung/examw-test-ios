//
//  PaperListViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/1.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperListViewController.h"
#import "UIViewController+VisibleView.h"
#import "NSString+Date.h"

#import "PaperReview.h"

#import "PaperData.h"
#import "PaperService.h"
#import "WaitForAnimation.h"

#import "PaperDetailViewController.h"

#define __kPaperListViewController_Top 5//顶部间隔
#define __kPaperListViewController_left 20//左边间隔
#define __kPaperListViewController_right 20//右边间隔

#define __kPaperListViewController_marginMin 2//控件之间的最小间距
#define __kPaperListViewController_segmentHeight 30//高度

#define __kPaperListViewController_fontSize 13//字体大小

#define __kPaperListViewController_title @"试卷详情"
#define __kPaperListViewController_waiting @"加载数据..."

#define __kPaperListViewController_more @"加载更多..."

#define __kPaperListViewController_cellIdentifier @"row_cell"//
#define __kPaperListViewController_moreIdentifier @"row_more"//

#define __kPaperListViewController_detail @"试题:%d  发布时间:%@"//
#define __kPaperListViewController_dateFormatter @"yyyy-MM-dd"//

//试卷列表视图控制器成员变量
@interface PaperListViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSString *_subjectCode;
    NSInteger _currentPaperTypeValue,_currentPageIndex;
    
    UITableView *_tableView;
    UISegmentedControl *_segment;
    
    PaperService *_service;
    NSMutableArray *_papersCache;
    WaitForAnimation *_wattingAnimation;
}
@end
//试卷列表视图控制器实现
@implementation PaperListViewController
#pragma mark 初始化
-(instancetype)initWithSubjectCode:(NSString *)subjectCode{
    if(self = [super init]){
        //设置科目代码
        _subjectCode = subjectCode;
        //设置题型
        _currentPaperTypeValue = 0;
    }
    return self;
}
#pragma mark 加载组件
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.title = __kPaperListViewController_title;
    //设置当前页码
    _currentPageIndex = 1;
    //初始化服务
    _service = [[PaperService alloc] init];
    //初始化缓存
    _papersCache = [NSMutableArray arrayWithCapacity:_service.rowsOfPage];
    
    //添加分段控制器
    [self setupSegmentControls];
    //添加列表
    [self setupTableViews];
    //初次加载数据
    NSArray *arrays = [_service loadPapersWithSubjectCode:_subjectCode PaperTypeValue:_currentPaperTypeValue Index:_currentPageIndex];
    if(arrays && arrays.count > 0){
        [_papersCache addObjectsFromArray:arrays];
    }
    //初始化动画
    _wattingAnimation = [[WaitForAnimation alloc]initWithView:self.view WaitTitle:__kPaperListViewController_waiting];
}
//安装分段控制器
-(void)setupSegmentControls{
    NSArray *typeArrays = @[[PaperReview paperTypeName:PaperTypeReal],[PaperReview paperTypeName:PaperTypeSimu],
                            [PaperReview paperTypeName:PaperTypeForecas],[PaperReview paperTypeName:PaperTypePractice]];
    
    CGRect tempFrame = [self loadVisibleViewFrame];
    tempFrame.origin.x = __kPaperListViewController_left;
    tempFrame.origin.y += __kPaperListViewController_Top;
    tempFrame.size.height = __kPaperListViewController_segmentHeight;
    tempFrame.size.width -= (__kPaperListViewController_left + __kPaperListViewController_right);
    
    _segment = [[UISegmentedControl alloc]initWithItems:typeArrays];
    _segment.frame = tempFrame;
    _segment.selectedSegmentIndex = 0;
    //添加事件处理
    [_segment addTarget:self action:@selector(segmentActionClick:) forControlEvents:UIControlEventValueChanged];
    //添加到容器
    [self.view addSubview:_segment];
}
//分段器选中事件处理
-(void)segmentActionClick:(UISegmentedControl *)sender{
    if(sender && _tableView){
        //加载数据动画
        [_wattingAnimation show];
        
        _currentPageIndex = 1;
        _currentPaperTypeValue = sender.selectedSegmentIndex + 1;
        //重载数据
        _papersCache = (NSMutableArray *)[_service loadPapersWithSubjectCode:_subjectCode
                                                              PaperTypeValue:_currentPaperTypeValue
                                                                       Index:_currentPageIndex];
        //关闭动画
        [_wattingAnimation hide];
        
        [_tableView reloadData];
    }
}
//添加tableview
-(void)setupTableViews{
    CGRect tempFrame = self.view.frame;
    tempFrame.origin.y = CGRectGetMaxY(_segment.frame) + __kPaperListViewController_marginMin;
    tempFrame.size.height -= tempFrame.origin.y;
    
    _tableView = [[UITableView alloc]initWithFrame:tempFrame style:UITableViewStylePlain];
    //_tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}
#pragma mark tableView_dataSource
//数据总数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_papersCache && _papersCache.count > 0){
        return _papersCache.count + 1;
    }
    return 0;
}
//每条数据展示
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!_papersCache || _papersCache.count == 0)return nil;
    //加载更多
    if(indexPath.row == _papersCache.count){
        UITableViewCell *moreCell = [tableView dequeueReusableCellWithIdentifier:__kPaperListViewController_moreIdentifier];
        if(!moreCell){
            moreCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:__kPaperListViewController_moreIdentifier];
            moreCell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
            moreCell.textLabel.textColor = [UIColor darkGrayColor];
            moreCell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
        moreCell.textLabel.text = (indexPath.row < _service.rowsOfPage ? @"" : __kPaperListViewController_more);
        return moreCell;
    }
    //越界
    if(indexPath.row > _papersCache.count) return nil;
    //查询数据
    PaperData *data = [_papersCache objectAtIndex:indexPath.row];
    if(!data)return nil;
    //加载内容
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kPaperListViewController_cellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:__kPaperListViewController_cellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:__kPaperListViewController_fontSize];
        
        cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        cell.detailTextLabel.textColor = [UIColor darkTextColor];
    }
    //设置
    cell.textLabel.text = data.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:__kPaperListViewController_detail,(int)data.total,
                                 [NSString stringFromDate:data.createTime withDateFormat:__kPaperListViewController_dateFormatter]];
    return cell;
}
#pragma mark tableView_delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!_papersCache || _papersCache.count == 0)return;
    //加载更多数据
    if(indexPath.row == _papersCache.count){
        if(indexPath.row < _service.rowsOfPage)return;
        //开启等待动画
        [_wattingAnimation show];
        //修改文字
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.text = __kPaperListViewController_waiting;
        //后台线程处理
        [self performSelectorInBackground:@selector(loadMoreData) withObject:nil];
        //关闭等待动画
        [_wattingAnimation hide];
        //取消选中
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    //查询数据
    PaperData *data = [_papersCache objectAtIndex:indexPath.row];
    if(!data)return;
    PaperDetailViewController *pdc = [[PaperDetailViewController alloc] initWithPaperCode:data.code];
    pdc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:pdc animated:NO];
}
//加载更多数据
-(void)loadMoreData{
    if(!_service)return;
    _currentPageIndex++;
    NSArray *moreArrays = [_service loadPapersWithSubjectCode:_subjectCode PaperTypeValue:_currentPaperTypeValue Index:_currentPageIndex];
    if(moreArrays && moreArrays.count > 0){
        //前台线程追加数据
        [self performSelectorOnMainThread:@selector(appendCacheUpdateWithData:) withObject:moreArrays waitUntilDone:NO];
    }
}
//追加数据
-(void)appendCacheUpdateWithData:(NSArray *)arrays{
    if(!_papersCache || !arrays || arrays.count == 0)return;
    NSInteger pos = _papersCache.count;
    //追加到缓存
    [_papersCache addObjectsFromArray:arrays];
    //更新TableView
    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:_service.rowsOfPage];
    for(NSInteger i = 0; i < arrays.count; i++){
        [insertIndexPaths addObject:[NSIndexPath indexPathForRow:(pos + i) inSection:0]];
    }
    [_tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
}

#pragma mark 内存
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(_papersCache)[_papersCache removeAllObjects];
}
@end
