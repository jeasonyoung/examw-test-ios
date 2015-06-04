//
//  MyRecordViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyRecordViewController.h"

#import "PaperRecordModel.h"
#import "PaperRecordModelCellFrame.h"
#import "PaperRecordModelTableViewCell.h"

#import "PaperService.h"

#import "MJRefresh.h"

#define __kMyRecordViewController_cellIdentifier @"_cellRecord"//
//试卷记录视图控制器成员变量
@interface MyRecordViewController (){
    //科目ID
    NSString *_subjectCode;
    //数据源
    NSMutableArray *_dataSource;
    //当前页码
    NSUInteger _pageIndex;
    //
    BOOL _isAddedRefresh;
    //
    PaperService *_service;
}
@end
//试卷记录视图控制器实现
@implementation MyRecordViewController

#pragma mark 初始化
-(instancetype)initWithSubjectCode:(NSString *)subjectCode{
    if(self = [super initWithStyle:UITableViewStylePlain]){
        _subjectCode = subjectCode;
        _isAddedRefresh = NO;
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化页码
    _pageIndex = 0;
    //加载数据
    [self loadDataWithPageIndex:_pageIndex];
}
//加载第一次数据
-(void)loadDataWithPageIndex:(NSUInteger)index{
    //异步线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"开始异步线程加载试卷记录数据...");
        //数据服务
        if(!_service){
            NSLog(@"初始化试卷数据服务...");
            _service = [[PaperService alloc] init];
        }
        //加载数据
        NSArray *models = [_service loadPaperRecordsWithSubjectCode:_subjectCode andPageIndex:index];
        NSUInteger count = 0;
        if(!models || (count = models.count) == 0){
            if(_pageIndex > 0)_pageIndex -= 1;//页码回退
            return;
        }
        //初始化数据源
        NSUInteger row = 0;
        if(!_dataSource){
            _dataSource = [NSMutableArray arrayWithCapacity:count];
        }else{
            row = _dataSource.count;
        }
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:count];
        for(NSUInteger i = 0; i < count; i++){
            PaperRecordModel *model = [models objectAtIndex:i];
            if(!model)continue;
            
            PaperRecordModelCellFrame *frame = [[PaperRecordModelCellFrame alloc] init];
            frame.model = model;
            [_dataSource addObject:frame];
            
            if(index > 0){
                [indexPaths addObject:[NSIndexPath indexPathForRow:(row + i) inSection:0]];
            }
        }
        //updateUI
        dispatch_async(dispatch_get_main_queue(), ^{
            if(index == 0){
                if(!_isAddedRefresh &&(_dataSource.count == _service.pageOfRows)){
                    _isAddedRefresh = YES;
                    //添加传统上拉
                    [self.tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
                }
                [self.tableView reloadData];
            }else if(indexPaths.count > 0){
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            }
        });
    });
}

//加载更多数据
-(void)loadMoreData{
    NSLog(@"加载更多数据...");
    _pageIndex += 1;
    [self loadDataWithPageIndex:_pageIndex];
}

#pragma mark UITableViewDataSource
//数据行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_dataSource){
        return _dataSource.count;
    }
    return 0;
}
//创建行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"创建行[%@]...", indexPath);
    PaperRecordModelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kMyRecordViewController_cellIdentifier];
    if(!cell){
        cell = [[PaperRecordModelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:__kMyRecordViewController_cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSLog(@"创建新行[%@]...",indexPath);
    }
    //加载数据
    [cell loadModelCellFrame:[_dataSource objectAtIndex:indexPath.row]];
    return cell;
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[_dataSource objectAtIndex:indexPath.row] cellHeight];
}
#pragma mark UITableViewDelegate
//删除行
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){//删除处理
        //异步线程处理
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"异步线程处理删除行[%@]...",indexPath);
            //1.从数据源中取出数据
            PaperRecordModelCellFrame *cellFrame = [_dataSource objectAtIndex:indexPath.row];
            if(!cellFrame || !cellFrame.model)return;
            //2.先数据库中删除
            if(_service){
                [_service deleteRecordWithPaperRecordId:cellFrame.model.Id];
            }
            //3.再在数据源中删除行
            [_dataSource removeObjectAtIndex:indexPath.row];
            //4.更新前台UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            });
        });
    }
}
//点击行事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击行:%@...", indexPath);
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
