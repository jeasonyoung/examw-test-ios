//
//  FavoritesViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "FavoritesViewController.h"
#import "PaperService.h"

#import "AppDelegate.h"
#import "AppSettings.h"

#import "PaperSegmentModel.h"
#import "PaperSegmentModelCellFrame.h"
#import "PaperSegmentTableViewCell.h"

#define __kFavoritesViewController_segErrorValue 0//错题
#define __kFavoritesViewController_segFavoriteValue 1//收藏

#define __kFavoritesViewController_cellIdentifer @"cellSeg"
//收藏和错题试图控制器成员
@interface FavoritesViewController (){
    NSString *_examCode;
    NSMutableArray *_dataSource;
}
@end
//收藏/错题视图控制器实现
@implementation FavoritesViewController

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super initWithStyle:UITableViewStylePlain]){
        AppSettings *settings = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).appSettings;
        if(settings){
            _examCode = [settings.examCode stringValue];
        }
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //加载Nav切换导航器
    [self setupNavSwitch];
    //加载数据
    [self loadDataWithSegValue:__kFavoritesViewController_segErrorValue];
}

//加载Nav切换导航器
-(void)setupNavSwitch{
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"错题",@"收藏"]];
    segment.frame = CGRectMake(0, 0, 200, 30);
    segment.selectedSegmentIndex = __kFavoritesViewController_segErrorValue;
    [segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segment;
}
//分段切换事件
-(void)segmentAction:(UISegmentedControl *)action{
    NSLog(@"index>>:%i", action.selectedSegmentIndex);
    [self loadDataWithSegValue:action.selectedSegmentIndex];
};

//加载数据
-(void)loadDataWithSegValue:(NSInteger)segValue{
    //异步线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //初始化数据服务
        static PaperService *service;
        if(!service){
            service = [[PaperService alloc] init];
        }
        if(!_dataSource){
            _dataSource = [NSMutableArray array];
        }else if(_dataSource.count > 0){//清除数据
            [_dataSource removeAllObjects];
        }
        NSLog(@"异步线程加载数据:[%d]...", (int)segValue);
        NSArray *arrays;
        switch (segValue) {
            case __kFavoritesViewController_segErrorValue:{//错题加载
                arrays = [service totalErrorRecordsWithExamCode:_examCode];
                break;
            }
            case __kFavoritesViewController_segFavoriteValue:{//收藏加载
                arrays = [service totalFavoriteRecordsWithExamCode:_examCode];
                break;
            }
        }
        if(arrays && arrays.count > 0){
            //数据转换
            for(NSDictionary *dict in arrays){
                if(!dict || dict.count == 0)continue;
                PaperSegmentModel *segModel = [[PaperSegmentModel alloc] initWithDict:dict];
                segModel.segValue = segValue;
                PaperSegmentModelCellFrame *cellFrame = [[PaperSegmentModelCellFrame alloc] init];
                cellFrame.model = segModel;
                [_dataSource addObject:cellFrame];
            }
        }
        //updateUI
        dispatch_async(dispatch_get_main_queue(), ^{
            //重新加载数据
            [self.tableView reloadData];
        });
    });
}

#pragma mark UITableViewDataSource
//数据行
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_dataSource){
        return _dataSource.count;
    }
    return 0;
}
//创建数据行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PaperSegmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kFavoritesViewController_cellIdentifer];
    if(!cell){
        cell = [[PaperSegmentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:__kFavoritesViewController_cellIdentifer];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [cell loadModelCellFrame:[_dataSource objectAtIndex:indexPath.row]];
    return cell;
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[_dataSource objectAtIndex:indexPath.row] cellHeight];
}
#pragma mark UITableViewDelegate
//选中行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"click:%@...", indexPath);
    PaperSegmentModelCellFrame *cellFrame = [_dataSource objectAtIndex:indexPath.row];
    if(cellFrame && cellFrame.model && cellFrame.model.total > 0){
        NSLog(@"subjectId======>%@...", cellFrame.model.subjectId);
        
    }
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(_dataSource && _dataSource.count > 0){
        [_dataSource removeAllObjects];
    }
}
@end
