//
//  LearnRecordViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "LearnRecordViewController.h"

#import "LearnRecordService.h"
#import "WaitForAnimation.h"

#import "LearnRecord.h"
#import "LearnRecordCellData.h"

#import "LearnTableViewCell.h"

#import "PaperDetailViewController.h"

#define __kLearnRecordViewController_title @"学习记录"
#define __kLearnRecordViewController_waiting @"加载数据..."

#define __kLearnRecordViewController_more @"加载更多..."

#define __kLearnRecordViewController_cellIdentifier @"row_cell"//
#define __kLearnRecordViewController_moreIdentifier @"row_more"//

#define __kLearnRecordViewController_moreCellHeight 30//

//学习记录视图控制器成员变量
@interface LearnRecordViewController ()<UITableViewDataSource,UITableViewDelegate>{
    LearnRecordService *_service;
    NSInteger _currentPageIndex;
    UITableView *_tableView;
    WaitForAnimation *_waitingAnimation;
    NSMutableArray *_cellDataCache;
}
@end
//学习记录视图控制器实现
@implementation LearnRecordViewController
#pragma mark UI加载
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化当前页码
    _currentPageIndex = 1;
    //设置标题
    self.title = __kLearnRecordViewController_title;
    
    //初始化服务
    _service = [[LearnRecordService alloc]init];
    
    //添加列表
    _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    //第一次加载数据
    //初始化等待动画
    _waitingAnimation = [[WaitForAnimation alloc]initWithView:self.view WaitTitle:__kLearnRecordViewController_waiting];
    [_waitingAnimation show];
    NSArray *arrays = [self loadDataAndTransWidthIndex:_currentPageIndex];
    if(arrays && arrays.count > 0){
        _cellDataCache = [NSMutableArray arrayWithArray:arrays];
        if(_cellDataCache && _cellDataCache.count > 0){
            [_tableView reloadData];
        }
    }
    //关闭等待动画
    [_waitingAnimation hide];
}

//加载数据并进行转换
-(NSArray *)loadDataAndTransWidthIndex:(NSInteger)index{
    if(_service){
        if(index < 1) index = 1;
        NSArray *sources = [_service loadRecordsWithPageIndex:index];
        if(sources && sources.count > 0){
            NSMutableArray *arrrays = [NSMutableArray array];
            for(LearnRecord *record in sources){
                if(!record)continue;
                LearnRecordCellData *cellData = [[LearnRecordCellData alloc]init];
                cellData.record = record;
                [arrrays addObject:cellData];
            }
            return arrrays;
        }
    }
    return nil;
}


#pragma mark UITableViewDataSource
//数据总数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSUInteger rows = 0;
    if(_cellDataCache && (rows = _cellDataCache.count) > 0){
        return (rows == _service.rowsOfPage) ? rows + 1 : rows;
    }
    return rows;
}
//加载数据
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //加载更多
    if(indexPath.row == _cellDataCache.count){
        UITableViewCell *moreCell = [tableView dequeueReusableCellWithIdentifier:__kLearnRecordViewController_moreIdentifier];
        if(!moreCell){
            moreCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:__kLearnRecordViewController_moreIdentifier];
            moreCell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
            moreCell.textLabel.textColor = [UIColor darkGrayColor];
            moreCell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
        moreCell.textLabel.text = __kLearnRecordViewController_more;
        return moreCell;
    }
    //越界
    if(indexPath.row > _cellDataCache.count) return nil;
    //加载内容
    LearnTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kLearnRecordViewController_cellIdentifier];
    if(!cell){
        cell = [[LearnTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:__kLearnRecordViewController_cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    //装载数据
    [cell loadData:(LearnRecordCellData *)[_cellDataCache objectAtIndex:indexPath.row]];
    return cell;
}
#pragma mark UITableViewDelegate
//获取Cell高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row < _cellDataCache.count){
       return [[_cellDataCache objectAtIndex:indexPath.row] rowHeight];
    }
    return __kLearnRecordViewController_moreCellHeight;
}
//选中事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!_cellDataCache || _cellDataCache.count == 0)return;
    //加载数据
    if(indexPath.row == _cellDataCache.count){
        //开启等待动画
        [_waitingAnimation show];
        //加载数据
        UITableViewCell *moreCell = [tableView cellForRowAtIndexPath:indexPath];
        moreCell.textLabel.text = __kLearnRecordViewController_waiting;
        [self performSelectorInBackground:@selector(loadMoreData) withObject:nil];
        //关闭等待动画
        [_waitingAnimation hide];
        //取消选中
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    //越界
    if(indexPath.row > _cellDataCache.count) return;
    //加载数据
    LearnRecordCellData *cellData = (LearnRecordCellData *)[_cellDataCache objectAtIndex:indexPath.row];
    if(!cellData)return;
    LearnRecord *record = cellData.record;
    if(!record)return;
    //跳转
    PaperDetailViewController *pdvc = [[PaperDetailViewController alloc]initWithPaperCode:record.paperCode
                                                                       andPaperRecordCode:record.code];
    pdvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:pdvc animated:NO];
}
//加载更多数据
-(void)loadMoreData{
    _currentPageIndex++;
    NSArray *moreArrays = [self loadDataAndTransWidthIndex:_currentPageIndex];
    [self performSelectorOnMainThread:@selector(appendCacheAndTableCellWithArrays:) withObject:moreArrays waitUntilDone:NO];
}
//添加数据到缓存和TableView
-(void)appendCacheAndTableCellWithArrays:(NSArray *)arrays{
    if(!_cellDataCache || !arrays || arrays.count == 0)return;
    //追加到缓存
    [_cellDataCache addObjectsFromArray:arrays];
    //加载数据
    [_tableView reloadData];
}
//删除事件处理
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if((indexPath.row < _cellDataCache.count) && (editingStyle == UITableViewCellEditingStyleDelete)){
        //开启等待动画
        [_waitingAnimation show];
        //加载数据
        LearnRecordCellData *cellData = (LearnRecordCellData *)[_cellDataCache objectAtIndex:indexPath.row];
        if(!cellData || !cellData.record){
            //关闭等待动画
            [_waitingAnimation hide];
            return;
        }
        //删除数据库
        [_service deleteWithPaperRecordCode:cellData.record.code];
        //删除缓存
        [_cellDataCache removeObjectAtIndex:indexPath.row];
        //重新加载数据
        [tableView reloadData];
        //取消选中
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        //关闭等待动画
        [_waitingAnimation hide];
    }
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
