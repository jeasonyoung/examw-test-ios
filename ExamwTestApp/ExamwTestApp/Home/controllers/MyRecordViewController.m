//
//  MyRecordViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyRecordViewController.h"

#import "PaperModel.h"
#import "PaperStructureModel.h"
#import "PaperItemModel.h"
#import "AnswerCardSectionModel.h"
#import "AnswerCardModel.h"
#import "AnswerCardModel+MakeObjects.h"

#import "PaperRecordModel.h"
#import "PaperRecordModelCellFrame.h"
#import "PaperRecordModelTableViewCell.h"

#import "PaperService.h"

#import "MJRefresh.h"

#import "PaperViewController.h"

#define __kMyRecordViewController_cellIdentifier @"_cellRecord"//
//试卷记录视图控制器成员变量
@interface MyRecordViewController ()<PaperViewControllerDelegate>{
    //科目ID
    NSString *_subjectCode,*_paperId,*_paperRecordId;
    //数据源
    NSMutableArray *_dataSource,*_itemsArrays,*_cardSectionArrays;
    NSMutableDictionary *_cardAllDataDict;
    //当前页码
    NSUInteger _pageIndex;
    //
    BOOL _isAddedRefresh,_displayAnswer;
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
        _displayAnswer = YES;
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
    //异步线程处理点击事件
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PaperRecordModelCellFrame *cellFrame = [_dataSource objectAtIndex:indexPath.row];
        if(!cellFrame || !cellFrame.model)return;
        _paperRecordId = cellFrame.model.Id;
        _paperId = cellFrame.model.paperId;
        if(_paperId && _paperId.length > 0 && _paperRecordId && _paperRecordId.length > 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                //界面跳转
                PaperViewController *controller = [[PaperViewController alloc] initWithDisplayAnswer:_displayAnswer];
                controller.delegate = self;
                controller.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:controller animated:YES];
            });
        }
    });
}

#pragma mark PaperViewControllerDelegate
//加载数据源(PaperItemModel数组,异步线程调用)
-(NSArray *)dataSourceOfPaperViewController:(PaperViewController *)controller{
    NSLog(@"加载试卷[%@/%@]数据...",_paperId,_paperRecordId);
    if(!_service || !_paperId || _paperId.length == 0)return nil;
    PaperModel *paperModel = [_service loadPaperModelWithPaperId:_paperId];
    if(!paperModel){
        NSLog(@"加载试卷[%@]数据模型失败!",_paperId);
        return nil;
    }
    if(paperModel.total > 0 && paperModel.structures){
        //初始化试题数组
        _itemsArrays = [NSMutableArray arrayWithCapacity:paperModel.total];
        NSUInteger total = paperModel.structures.count;
        //初始化答题卡分组数组
        _cardSectionArrays = [NSMutableArray arrayWithCapacity:total];
        //初始化答题卡数据字典
        _cardAllDataDict = [NSMutableDictionary dictionaryWithCapacity:total];
        //
        NSUInteger section = 0, order = 0;
        //试卷结构
        for(PaperStructureModel *structure in paperModel.structures){
            if(!structure || !structure.items) continue;
            //创建答题卡分组数据模型
            [_cardSectionArrays addObject:[[AnswerCardSectionModel alloc] initWithTitle:structure.title desc:structure.desc]];
            //初始化答题卡分组内容数据数组
            NSMutableArray *cardModels = [NSMutableArray arrayWithCapacity:structure.items.count];
            //试题
            for(PaperItemModel *item in structure.items){
                if(!item || !item.itemId || item.itemId.length == 0) continue;
                //所属试卷结构ID
                item.structureId = structure.code;
                //所属试卷结构名称
                item.structureTitle = structure.title;
                //每题得分
                item.structureScore = structure.score;
                //最小得分
                item.structureMin = structure.min;
                for(NSUInteger index = 0; index < item.count; index++){
                    //试题索引
                    item.index = index;
                    //添加到数组
                    [_itemsArrays addObject:item];
                    //
                    [cardModels addObject:[[AnswerCardModel alloc] initWithOrder:order status:0]];
                    //
                    order += 1;
                }
            }
            //添加到答题卡数据字典中
            [_cardAllDataDict setObject:[cardModels copy] forKey:[NSNumber numberWithInteger:section]];
            section += 1;
        }
        return [_itemsArrays copy];
    }
    return nil;
}
//加载试题答案(异步线程中调用)
-(NSString *)loadMyAnswerWithModel:(PaperItemModel *)itemModel{
    if(_service && itemModel && _paperRecordId && _paperRecordId.length > 0){
        NSLog(@"加载试题[%@$%d]在记录[%@]中的答案...", itemModel.itemId, (int)itemModel.index, _paperRecordId);
        return [_service loadRecordAnswersWithPaperRecordId:_paperRecordId itemModel:itemModel];
    }
    return nil;
}
//更新收藏记录(异步线程中被调用)
-(BOOL)updateFavoriteWithModel:(PaperItemModel *)itemModel{
    if(_service && itemModel && _subjectCode && _subjectCode.length > 0){
        NSLog(@"更新试题[%@$%d]收藏记录...", itemModel.itemId, (int)itemModel.index);
        return [_service updateFavoriteWithSubjectCode:_subjectCode itemModel:itemModel];
    }
    return NO;
}
//加载答题卡数据(异步线程中被调用)
-(void)loadAnswerCardDataWithSection:(NSArray *__autoreleasing *)sections andAllData:(NSDictionary *__autoreleasing *)dict{
    NSLog(@"加载试卷[%@/%@]答题卡数据源...", _paperId, _paperRecordId);
    if(_cardSectionArrays && _cardAllDataDict){
        *sections = [_cardSectionArrays copy];
        //加载做题记录
        if(_cardAllDataDict && _cardAllDataDict.count > 0 && _itemsArrays && _paperRecordId && _paperRecordId.length > 0){
            NSArray *keys = _cardAllDataDict.allKeys;
            for(NSNumber *key in keys){
                if(!key) continue;
                NSArray *arrays = [_cardAllDataDict objectForKey:key];
                if(arrays && arrays.count > 0){
                    [arrays makeObjectsPerformSelector:@selector(loadItemStatusWithObjs:)
                                            withObject:@[_service,_paperRecordId,_itemsArrays]];
                }
            }
        }
        
        *dict = [_cardAllDataDict copy];
    }
}

#pragma mark 重载View显示
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end