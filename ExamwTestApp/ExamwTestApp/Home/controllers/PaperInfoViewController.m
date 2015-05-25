//
//  PaperRealViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperInfoViewController.h"
#import "PaperService.h"

#import "PaperInfoModelCellFrame.h"
#import "PaperInfoModel.h"
#import "PaperInfoTableViewCell.h"

#import "PaperModel.h"

#import "MJRefresh.h"

#import "AnimationUtils.h"
#import "PaperDetailsViewController.h"

#define __kPaperInfoViewController_cellIdentifier @"_cellPapers"//行缓存

//真题视图控制器成员变量
@interface PaperInfoViewController (){
    //当前页码
    NSUInteger _pageIndex,_type;;
    //试卷服务
    PaperService *_service;
    //试卷数据源
    NSMutableArray *_dataSource;
    //父控制器
    UIViewController *_parent;
}
@end

@implementation PaperInfoViewController

#pragma mark 初始化
-(instancetype)initWithType:(NSUInteger)type parentViewController:(UIViewController *)parent{
    if(self = [super initWithStyle:UITableViewStylePlain]){
        _type = type;
        _parent = parent;
    }
    return self;
}

#pragma mark 静态初始化
+(instancetype)infoControllerWithType:(NSUInteger)type parentViewController:(UIViewController *)parent{
    NSLog(@"静态初始化...");
    return [[PaperInfoViewController alloc] initWithType:type parentViewController:parent];
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化服务
    _service = [[PaperService alloc] init];
    //初始化数据源
    _dataSource = [NSMutableArray arrayWithCapacity:_service.pageOfRows];
    //初始化页码
    _pageIndex = 0;
    //加载初始化数据
    [self loadFirstData];
}
//加载初始化数据
-(void)loadFirstData{
    //异步加载第一页数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSArray *arrays = nil;
        //加载更多的数据
        void(^loadMoreData)() = ^(){
            NSLog(@"准备开始异步加载上拉刷新数据...");
            arrays = [_service findPapersInfoWithPaperType:(NSUInteger)_type andPageIndex:_pageIndex];
            if(!arrays || arrays.count == 0){
                if(_pageIndex > 0){
                    _pageIndex -= 1;
                    //更新前台UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView.footer noticeNoMoreData];
                    });
                }
                return;
            }
            //数据转换
            for(PaperInfoModel *model in arrays){
                if(model){
                    PaperInfoModelCellFrame *cellFrame = [[PaperInfoModelCellFrame alloc] init];
                    cellFrame.model = model;
                    [_dataSource addObject:cellFrame];
                }
            }
            //更新前台UI刷新数据
            dispatch_async(dispatch_get_main_queue(), ^{
                //刷新TableView数据
                [self.tableView reloadData];
                //
                if(_pageIndex > 0){
                    [self.tableView.footer endRefreshing];
                }
                //加载的数据等于分页数据量，添加上拉加载数据
                if(arrays.count == [_service pageOfRows]){
                     _pageIndex += 1;
                    [self.tableView addLegendFooterWithRefreshingBlock:loadMoreData];
                }
            });
        };
        //调用程序块
        loadMoreData();
    });
}
#pragma mark tableViewDataSource
//数据总数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_dataSource){
        return _dataSource.count;
    }
    return 0;
}
//绘制行数据
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"绘制行=>%@...", indexPath);
    PaperInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kPaperInfoViewController_cellIdentifier];
    if(!cell){
        cell = [[PaperInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:__kPaperInfoViewController_cellIdentifier];
        NSLog(@"创建新行=>%@",indexPath);
    }
    //加载数据
    [cell loadModelCellFrame:(PaperInfoModelCellFrame *)[_dataSource objectAtIndex:indexPath.row]];
    return cell;
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //行高
    return [[_dataSource objectAtIndex:indexPath.row] cellHeight];
}
#pragma mark TableView Delegate
//选中
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"选中行:%@",indexPath);
    PaperInfoModelCellFrame *cellFrame = [_dataSource objectAtIndex:indexPath.row];
    if(!cellFrame){
        NSLog(@"获取选中行的Cell Frame的数据失败!");
        return;
    }
    if(_parent){
        //设置返回按钮
        UIBarButtonItem *backBtnItem = [[UIBarButtonItem alloc] init];
        backBtnItem.title = [PaperModel nameWithPaperType:_type];
        _parent.navigationItem.backBarButtonItem = backBtnItem;
        //设置动画
        [AnimationUtils mediaTimingEaseInEaseOutWithView:_parent.navigationController.view delegate:self];
        //跳转
        PaperDetailsViewController *detailsController = [[PaperDetailsViewController alloc]initWithPaperInfo:cellFrame.model];
        detailsController.navigationItem.backBarButtonItem = backBtnItem;
        [_parent.navigationController pushViewController:detailsController animated:YES];
    }
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"内存告警...");
    if(_dataSource && _dataSource.count > 0){
        [_dataSource removeAllObjects];
    }
}

@end
