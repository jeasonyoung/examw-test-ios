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

#import "PaperItemModel.h"
#import "AnswerCardSectionModel.h"
#import "AnswerCardModel.h"

#import "PaperViewController.h"

#define __kFavoritesViewController_segErrorValue 0//错题
#define __kFavoritesViewController_segFavoriteValue 1//收藏

#define __kFavoritesViewController_cellIdentifer @"cellSeg"
//收藏和错题试图控制器成员
@interface FavoritesViewController ()<PaperViewControllerDelegate>{
    NSString *_examCode,*_subjectId;
    NSInteger _segValue;
    
    PaperService *_service;
    NSMutableArray *_dataSource;
    
    BOOL _isReLoad;
    
    NSArray *_itemsArrays,*_segmentArrays;
}
@end
//收藏/错题视图控制器实现
@implementation FavoritesViewController

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super initWithStyle:UITableViewStyleGrouped]){
        _isReLoad = NO;
        //初始化分段
        _segmentArrays = @[@"错题",@"收藏"];
        //初始化考试代码
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
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:_segmentArrays];
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
        _service = [[PaperService alloc] init];
        //初始化数据源
        _dataSource = [NSMutableArray array];
        NSLog(@"异步线程加载数据:[%d]...", (int)segValue);
        NSArray *arrays;
        switch (segValue) {
            case __kFavoritesViewController_segErrorValue:{//错题加载
                arrays = [_service totalErrorRecordsWithExamCode:_examCode];
                break;
            }
            case __kFavoritesViewController_segFavoriteValue:{//收藏加载
                arrays = [_service totalFavoriteRecordsWithExamCode:_examCode];
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
        _segValue = cellFrame.model.segValue;
        _subjectId = cellFrame.model.subjectId;
        
        NSLog(@"subjectId===%d===>%@...", (int)_segValue, _subjectId);
        
        PaperViewController *controller = [[PaperViewController alloc] initWithDisplayAnswer:YES];
        controller.title = [_segmentArrays objectAtIndex:_segValue];
        controller.delegate = self;
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}


#pragma mark PaperViewControllerDelegate
//加载数据源(PaperItemModel数组,异步线程调用)
-(NSArray *)dataSourceOfPaperViewController:(PaperViewController *)controller{
    switch (_segValue) {
        case __kFavoritesViewController_segErrorValue:{//错题加载
            _itemsArrays = [_service loadErrorsWithSubjectCode:_subjectId];
            break;
        }
        case __kFavoritesViewController_segFavoriteValue:{//收藏加载
            _itemsArrays = [_service loadFavoritesWithSubjectCode:_subjectId];
            break;
        }
    }
    return _itemsArrays;
}
//加载试题答案(异步线程中调用)
-(NSString *)loadMyAnswerWithModel:(PaperItemModel *)itemModel{
    if(itemModel && itemModel.paperRecordId && itemModel.paperRecordId.length > 0){
        return [_service loadRecordAnswersWithPaperRecordId:itemModel.paperRecordId itemModel:itemModel];
    }
    return nil;
}
//更新做题记录到SQL(异步线程中调用)
-(void)updateRecordAnswerWithModel:(PaperItemModel *)itemModel myAnswers:(NSString *)myAnswers useTimes:(NSUInteger)times{
    if(itemModel && itemModel.paperRecordId && itemModel.paperRecordId.length > 0){
        [_service addRecordWithPaperRecordId:itemModel.paperRecordId itemModel:itemModel myAnswers:myAnswers useTimes:times];
    }
}
//更新收藏记录(异步线程中被调用)
-(BOOL)updateFavoriteWithModel:(PaperItemModel *)itemModel{
    if(_subjectId && _subjectId.length > 0){
        return [_service updateFavoriteWithSubjectCode:_subjectId itemModel:itemModel];
    }
    return NO;
}
//加载答题卡数据(异步线程中被调用)
-(void)loadAnswerCardDataWithSection:(NSArray *__autoreleasing *)sections andAllData:(NSDictionary *__autoreleasing *)dict{
    if(_itemsArrays && _itemsArrays.count > 0){
        //按题型分类
        NSMutableDictionary *itemTypesDicts = [NSMutableDictionary dictionary];
        for(PaperItemModel *itemModel in _itemsArrays){
            if(!itemModel)continue;
            NSNumber *itemType = [NSNumber numberWithInteger:itemModel.itemType];
            NSMutableArray *arrays = [itemTypesDicts objectForKey:itemType];
            if(!arrays){
                arrays = [NSMutableArray array];
            }
            [arrays addObject:itemModel];
            [itemTypesDicts setObject:arrays forKey:itemType];
        }
        //按题型排序
        NSArray *itemTypeArrays = [itemTypesDicts.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return ((NSNumber *)obj1).intValue - ((NSNumber *)obj2).intValue;
        }];
        //
        NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:itemTypeArrays.count];
        NSMutableDictionary *dataDicts = [NSMutableDictionary dictionaryWithCapacity:itemTypeArrays.count];
        NSUInteger order = 0;
        for (NSUInteger i = 0; i < itemTypeArrays.count; i++) {
            NSNumber *itemType = [itemTypeArrays objectAtIndex:i];
            if(!itemType)continue;
            //分组
            NSString *itemTypeName = [PaperItemModel nameWithItemType:itemType.integerValue];
            NSString *title = [NSString stringWithFormat:@"%d.%@",(int)(i+1),itemTypeName];
            [sectionArrays addObject:[[AnswerCardSectionModel alloc] initWithTitle:title desc:nil]];
            //数据
            NSArray *arrays = [itemTypesDicts objectForKey:itemType];
            if(arrays && arrays.count > 0){
                NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrays.count];
                for(PaperItemModel *itemModel in arrays){
                    if(!itemModel)continue;
                    
                    NSUInteger status = 0;
                    if(itemModel.paperRecordId && itemModel.paperRecordId.length > 0){
                        status = [_service exitRecordWithPaperRecordId:itemModel.paperRecordId itemModel:itemModel];
                    }
                    [models addObject:[[AnswerCardModel alloc] initWithOrder:order status:status]];
                    order += 1;
                }
                [dataDicts setObject:models forKey:[NSNumber numberWithInteger:i]];
            }
        }
        //
        *sections = [sectionArrays copy];
        *dict = [dataDicts copy];
    }
}

#pragma mark 重载视图将载入
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"视图将载入...");
    //隐藏导航条
    //self.navigationController.navigationBarHidden = YES;
    [self.navigationController setToolbarHidden:YES];
    if(_isReLoad){
        _isReLoad = NO;
        //重新加载数据
        [self loadDataWithSegValue:_segValue];
    }
}
#pragma mark 重载视图将卸载
-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"视图将卸载...");
    //隐藏导航条
    //self.navigationController.navigationBarHidden = NO;
    //
    _isReLoad = YES;
}


#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(_dataSource && _dataSource.count > 0){
        [_dataSource removeAllObjects];
    }
}
@end
