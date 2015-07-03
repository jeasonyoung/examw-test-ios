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

#import "EffectsUtils.h"
#import "PaperDetailsViewController.h"

#define __kPaperInfoViewController_cellIdentifier @"_cellPapers"//行缓存

//真题视图控制器成员变量
@interface PaperInfoViewController (){
    NSString *_subjectCode;
    NSUInteger _type;
    //试卷服务
    PaperService *_service;
    //试卷数据源
    NSMutableArray *_dataSource;
    //父控制器
    UIViewController *_parent;
    BOOL _isReload;
}
//页码
@property(nonatomic,assign)NSUInteger pageIndex;

@end

@implementation PaperInfoViewController

#pragma mark 初始化
-(instancetype)initWithType:(NSUInteger)type andSubjectCode:(NSString *)subjectCode parentViewController:(UIViewController *)parent{
    if(self = [super initWithStyle:UITableViewStylePlain]){
        _subjectCode = subjectCode;
        _type = type;
        _parent = parent;
    }
    return self;
}

#pragma mark 静态初始化
+(instancetype)infoControllerWithType:(NSUInteger)type andSubjectCode:(NSString *)subjectCode
                 parentViewController:(UIViewController *)parent{
    NSLog(@"静态初始化...");
    return [[PaperInfoViewController alloc] initWithType:type andSubjectCode:subjectCode parentViewController:parent];
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化重新加载
    _isReload = NO;
    //初始化数据源
    _dataSource = [NSMutableArray arrayWithCapacity:_service.pageOfRows];
    //初始化页码
    _pageIndex = 0;
    //加载初始化数据
    [self loadData];
}
//加载初始化数据
-(void)loadData{
    //异步线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"异步线程加载指定类型[%d]页页码[%d]数据...",(int)_type, (int)_pageIndex);
        //初始化服务
        if(!_service){
            _service = [[PaperService alloc] init];
        }
        //加载数据
        NSArray *arrays = [_service findPapersInfoWithPaperType:_type andSubjectCode:_subjectCode andPageIndex:_pageIndex];
        if(!arrays || arrays.count == 0){//没有加载到数据
            if(_pageIndex > 0){
                _pageIndex -= 1;
                //更新UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    //显示没有加载到更多数据
                    [self.tableView.footer noticeNoMoreData];
                });
            }
            return;
        }
        //数据转换
        NSUInteger pos = _dataSource.count;
        NSMutableArray *indexPathArrays = [NSMutableArray arrayWithCapacity:arrays.count];
        for(NSUInteger i = 0; i < arrays.count; i++){
            PaperInfoModelCellFrame *cellFrame = [[PaperInfoModelCellFrame alloc] init];
            cellFrame.model = [arrays objectAtIndex:i];
            [_dataSource addObject:cellFrame];
            if(pos > 0 && _pageIndex > 0){
                [indexPathArrays addObject:[NSIndexPath indexPathForRow:(pos + i) inSection:0]];
            }
        }
        //更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            //刷新TableView数据
            if(indexPathArrays.count > 0){
                [self.tableView insertRowsAtIndexPaths:indexPathArrays withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView.footer endRefreshing];
            }else{
                [self.tableView reloadData];
            }
            //加载的数据等于分页数据量，添加上拉加载数据
            if(arrays.count >= _service.pageOfRows){
                __weak PaperInfoViewController *weakSelf = self;
                [self.tableView addLegendFooterWithRefreshingBlock:^{
                    weakSelf.pageIndex += 1;
                    NSLog(@"上拉刷新[%d]...", (int)weakSelf.pageIndex);
                    [weakSelf loadData];
                }];
            }
        });
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
        [EffectsUtils animationCubeWithView:_parent.navigationController.view delegate:self];
        //跳转
        PaperDetailsViewController *detailsController = [[PaperDetailsViewController alloc]initWithPaperInfo:cellFrame.model];
        detailsController.navigationItem.backBarButtonItem = backBtnItem;
        [_parent.navigationController pushViewController:detailsController animated:YES];
    }
}

#pragma mark View可见
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(_isReload){
        _isReload = NO;
        [_dataSource removeAllObjects];
        [self loadData];
    }
}

#pragma mark View不可见
-(void)viewWillDisappear:(BOOL)animated{
    _isReload = YES;
    [super viewWillDisappear:animated];
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
