//
//  MyRecordViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyRecordViewController.h"
#import "MySubjectModel.h"

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
@interface MyRecordViewController ()<PaperViewControllerDelegate,UIAlertViewDelegate>{
    MySubjectModel *_mySubjectModel;
    //科目ID
    NSString *_paperId,*_paperRecordId;
    //数据源
    NSMutableArray *_dataSource,*_itemsArrays,*_cardSectionArrays;
    NSMutableDictionary *_cardAllDataDict;
    //
    BOOL _displayAnswer;
    //
    PaperService *_service;
    //
    UIAlertView *_alertView;
}

//页码
@property(nonatomic,assign)NSUInteger pageIndex;

@end
//试卷记录视图控制器实现
@implementation MyRecordViewController

#pragma mark 初始化
-(instancetype)initWithModel:(MySubjectModel *)model{
    if(self = [super initWithStyle:UITableViewStylePlain]){
        _mySubjectModel = model;
        _displayAnswer = YES;
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化页码
    _pageIndex = 0;
    //初始化服务
    _service = [[PaperService alloc] init];
    //初始化数据源
    _dataSource = [NSMutableArray arrayWithCapacity:_service.pageOfRows];
    //加载数据
    [self loadData];
}

//加载数据
-(void)loadData{
    //异步线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"开始异步线程加载试卷记录数据...");
        //加载数据
        NSArray *arrays = [_service loadPaperRecordsWithSubjectCode:(_mySubjectModel ? _mySubjectModel.subjectCode : @"")
                                                       andPageIndex:_pageIndex];
        if(!arrays || arrays.count == 0){
            if(_pageIndex > 0){
                _pageIndex -= 1;
                //updateUI
                dispatch_async(dispatch_get_main_queue(), ^{
                    //没有更多数据
                    [self.tableView.footer noticeNoMoreData];
                });
            }
            return;
        }
        NSUInteger pos = _dataSource.count;
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:arrays.count];
        for(NSUInteger i = 0; i < arrays.count; i++){
            PaperRecordModelCellFrame *frame = [[PaperRecordModelCellFrame alloc] init];
            frame.model = [arrays objectAtIndex:i];
            [_dataSource addObject:frame];
            if(pos > 0 && _pageIndex > 0){
                [indexPaths addObject:[NSIndexPath indexPathForRow:(pos + i) inSection:0]];
            }
        }
        //updateUI
        dispatch_async(dispatch_get_main_queue(), ^{
            //刷新数据
            if(indexPaths.count > 0){
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView.footer endRefreshing];
            }else{
                [self.tableView reloadData];
            }
            //加载的数据等于分页数据量，添加上拉加载数据
            if(arrays.count >= _service.pageOfRows){
                __weak MyRecordViewController *weakSelf = self;
                [self.tableView addLegendFooterWithRefreshingBlock:^{
                    weakSelf.pageIndex += 1;
                    NSLog(@"上拉刷新[%d]...", (int)weakSelf.pageIndex);
                    [weakSelf loadData];
                }];
            }
        });
    });
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
            //4.更新标题
            NSString *title = nil;
            if(_mySubjectModel){
                if(_mySubjectModel.total > 0){_mySubjectModel.total -= 1;}
                title = [NSString stringWithFormat:@"%@(%d)",_mySubjectModel.subject, (int)_mySubjectModel.total];
            }
            //5.更新前台UI
            dispatch_async(dispatch_get_main_queue(), ^{
                if(title){
                    self.title = title;
                }
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
        _displayAnswer = cellFrame.model.status;
        _paperRecordId = cellFrame.model.Id;
        _paperId = cellFrame.model.paperId;
        
        if(_paperId && _paperId.length > 0 && _paperRecordId && _paperRecordId.length > 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!_displayAnswer){//未做完
                    //弹出对话框
                    _alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否继续考试" delegate:self
                                                  cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
                    [_alertView show];
                    
                }else{//已做完
                    [self alertView:_alertView clickedButtonAtIndex:0];
                }
            });
        }
    });
}

#pragma mark UIAlertViewDelegate
//弹出框按钮事件
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //是否显示答案
    _displayAnswer = (buttonIndex == 0 ? YES : NO);
    
    //界面跳转
    PaperViewController *controller = [[PaperViewController alloc] initWithDisplayAnswer:_displayAnswer];
    controller.delegate = self;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark PaperViewControllerDelegate
//加载数据源(PaperItemModel数组,异步线程调用)
-(NSArray *)dataSourceOfPaperView{
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
//加载的当前试题题序(异步线程中调用)
-(NSUInteger)currentOrderOfPaperView{
    if(!_displayAnswer && _service && _paperRecordId && _paperRecordId.length > 0 && _itemsArrays && _itemsArrays.count > 0){
        NSString *lastItemId = [_service loadNewsItemIndexWithPaperRecordId:_paperRecordId];
        if(lastItemId && lastItemId.length > 0){
            for(NSUInteger i = 0; i < _itemsArrays.count; i++){
                PaperItemModel *itemModel = [_itemsArrays objectAtIndex:i];
                if(!itemModel) continue;
                NSString *itemId = [NSString stringWithFormat:@"%@$%d", itemModel.itemId, (int)itemModel.index];
                if([itemId isEqualToString:lastItemId]){
                    return i;
                }
            }
        }
    }
    return 0;
}
//考试时长
-(NSUInteger)timeOfPaperView{
    if(_service && _paperId && _paperId.length > 0){
        PaperModel *paperModel = [_service loadPaperModelWithPaperId:_paperId];
        if(paperModel){
            return paperModel.time;
        }
    }
    return 0;
}
//加载试题答案(异步线程中调用)
-(NSString *)loadMyAnswerWithModel:(PaperItemModel *)itemModel{
    if(_service && itemModel && _paperRecordId && _paperRecordId.length > 0){
        NSLog(@"加载试题[%@$%d]在记录[%@]中的答案...", itemModel.itemId, (int)itemModel.index, _paperRecordId);
        return [_service loadRecordAnswersWithPaperRecordId:_paperRecordId itemModel:itemModel];
    }
    return nil;
}
//更新做题记录到SQL(异步线程中调用)
-(void)updateRecordAnswerWithModel:(PaperItemModel *)itemModel myAnswers:(NSString *)myAnswers useTimes:(NSUInteger)times{
    if(_service && itemModel && myAnswers){
        NSLog(@"更新做题[%@$%d]记录到数据库...",itemModel.itemId, (int)itemModel.index);
        [_service addRecordWithPaperRecordId:_paperRecordId itemModel:itemModel myAnswers:myAnswers useTimes:times];
    }
}
//更新收藏记录(异步线程中被调用)
-(BOOL)updateFavoriteWithModel:(PaperItemModel *)itemModel{
    if(_service && itemModel && _mySubjectModel && _mySubjectModel.subjectCode){
        NSLog(@"更新试题[%@$%d]收藏记录...", itemModel.itemId, (int)itemModel.index);
        return [_service updateFavoriteWithSubjectCode:_mySubjectModel.subjectCode itemModel:itemModel];
    }
    return NO;
}
//交卷处理(异步线程中被调用)
-(void)submitPaperWithUseTimes:(NSUInteger)useTimes resultHandler:(void (^)(NSString *))resultController{
    if(_service){
        NSLog(@"交卷处理[%@]...", _paperRecordId);
        [_service submitWithPaperRecordId:_paperRecordId andUseTimes:useTimes];
        //试卷记录ID
        resultController(_paperRecordId);
    }
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
