//
//  PaperItemViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemViewController.h"
#import "PaperItemModel.h"

#import "PaperItemTitleModel.h"
#import "PaperItemTitleModelCellFrame.h"
#import "PaperItemTitleTableViewCell.h"

#import "PaperItemOptModel.h"
#import "PaperItemOptModelCellFrame.h"
#import "PaperItemOptTableViewCell.h"

#import "PaperItemAnalysisModel.h"
#import "PaperItemAnalysisModelCellFrame.h"
#import "PaperItemAnalysisTableViewCell.h"

#import "MBProgressHUD.h"
#import "UIColor+Hex.h"

#define __kPaperItemViewController_cellTitleIdentifier @"_cellTitle"//标题行
#define __kPaperItemViewController_cellOptIdentifier @"_cellOpt"//选项行
#define __kPaperItemViewController_cellAnalysisIdentifier @"_cellAnalysis"//题目解析行

//试卷试题视图控制器成员变量
@interface PaperItemViewController (){
    //试题数据模型
    PaperItemModel *_itemModel;
    //当前序号
    NSUInteger _order;
    //是否显示答案
    BOOL _displayAnswer;
    //试题数据源
    NSMutableArray *_itemsDataSource;
    //等待动画
    MBProgressHUD *_waitHud;
}
@end
//试卷试题视图控制器实现
@implementation PaperItemViewController

#pragma mark 初始化
-(instancetype)initWithPaperItem:(PaperItemModel *)model andOrder:(NSUInteger)order andDisplayAnswer:(BOOL)display{
    if(self = [super init]){
        NSLog(@"初始化试题视图控制器[是否显示答案:%d]%@...", display, model);
        _displayAnswer = display;
        _order = order;
        _itemModel = model;
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化等待
    _waitHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _waitHud.color = [UIColor colorWithHex:0xD3D3D3];
    //初始化数据源
    _itemsDataSource = [NSMutableArray array];
    
    NSLog(@"PaperItemViewController===>%d",(int)_order);
    //加载数据
    [self loadData];
}

//加载试题数据
-(void)loadData{
    //异步线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"开始异步线程加载试题[%d]数据...",(int)_order);
        if(!_itemModel)return;
        NSArray *optModelArrays;
        //加载试题
        switch (_itemModel.itemType) {
            case PaperItemTypeSingle://单选
            case PaperItemTypeMulty://多选
            case PaperItemTypeUncertain://不定向选
            {
                //标题
                PaperItemTitleModel *titleModel = [[PaperItemTitleModel alloc] initWithItemModel:_itemModel];
                titleModel.order = _order + 1;
                PaperItemTitleModelCellFrame *titleFrame = [[PaperItemTitleModelCellFrame alloc] init];
                titleFrame.model = titleModel;
                //添加到数据源
                [_itemsDataSource addObject:titleFrame];
                //选项
                NSArray *optFrames = [self createCellOptions:_itemModel.children
                                                    itemType:_itemModel.itemType
                                                outOptModels:&optModelArrays];
                //添加到数据源
                if(optFrames && optFrames.count > 0){
                    [_itemsDataSource addObjectsFromArray:optFrames];
                }
                //答案解析
                if(_displayAnswer && optModelArrays){
                    PaperItemAnalysisModel *analysisModel = [[PaperItemAnalysisModel alloc] initWithItemModel:_itemModel];
                    analysisModel.options = optModelArrays;
                    PaperItemAnalysisModelCellFrame *analysisFrame = [[PaperItemAnalysisModelCellFrame alloc] init];
                    analysisFrame.model = analysisModel;
                    //添加到数据源
                    [_itemsDataSource addObject:analysisFrame];
                }
                break;
            }
            case PaperItemTypeJudge:{//判断题
                //标题
                PaperItemTitleModel *titleModel = [[PaperItemTitleModel alloc] initWithItemModel:_itemModel];
                titleModel.order = _order + 1;
                PaperItemTitleModelCellFrame *titleFrame = [[PaperItemTitleModelCellFrame alloc] init];
                titleFrame.model = titleModel;
                //添加到数据源
                [_itemsDataSource addObject:titleFrame];
                //判断选项初始化
                PaperItemModel *optRightModel = [[PaperItemModel alloc] initWithDict:@{@"id":[NSNumber numberWithInteger:PaperItemJudgeAnswerRight],@"content":[PaperItemModel nameWithItemJudgeAnswer:PaperItemJudgeAnswerRight]}],
                *optWrongModel = [[PaperItemModel alloc] initWithDict:@{@"id":[NSNumber numberWithInteger:PaperItemJudgeAnswerWrong],@"content":[PaperItemModel nameWithItemJudgeAnswer:PaperItemJudgeAnswerWrong]}];
                //选项
                NSArray *optFrames = [self createCellOptions:@[optRightModel, optWrongModel]
                                                    itemType:PaperItemTypeSingle
                                                outOptModels:&optModelArrays];
                //添加到数据源
                if(optFrames && optFrames.count > 0){
                    [_itemsDataSource addObjectsFromArray:optFrames];
                }
                //答案解析
                if(_displayAnswer && optModelArrays){
                    PaperItemAnalysisModel *analysisModel = [[PaperItemAnalysisModel alloc] initWithItemModel:_itemModel];
                    analysisModel.options = optModelArrays;
                    PaperItemAnalysisModelCellFrame *analysisFrame = [[PaperItemAnalysisModelCellFrame alloc] init];
                    analysisFrame.model = analysisModel;
                    //添加到数据源
                    [_itemsDataSource addObject:analysisFrame];
                }
                break;
            }
            case PaperItemTypeQanda:{//问答题
                //标题
                PaperItemTitleModel *titleModel = [[PaperItemTitleModel alloc] initWithItemModel:_itemModel];
                titleModel.order = _order + 1;
                PaperItemTitleModelCellFrame *titleFrame = [[PaperItemTitleModelCellFrame alloc] init];
                titleFrame.model = titleModel;
                //添加到数据源
                [_itemsDataSource addObject:titleFrame];
                //答案解析
                if(_displayAnswer && optModelArrays){
                    PaperItemAnalysisModelCellFrame *analysisFrame = [[PaperItemAnalysisModelCellFrame alloc] init];
                    analysisFrame.model = [[PaperItemAnalysisModel alloc] initWithItemModel:_itemModel];
                    //添加到数据源
                    [_itemsDataSource addObject:analysisFrame];
                }
                break;
            }
            case PaperItemTypeShareTitle:{//共享题干题
                //标题
                PaperItemTitleModelCellFrame *titleFrame = [[PaperItemTitleModelCellFrame alloc] init];
                titleFrame.model = [[PaperItemTitleModel alloc] initWithItemModel:_itemModel];
                //添加到数据源
                [_itemsDataSource addObject:titleFrame];
                NSUInteger index = _itemModel.index;
                if(_itemModel.children && _itemModel.children.count > index){
                    PaperItemModel *child = [_itemModel.children objectAtIndex:index];
                    if(child){
                        //子标题
                        PaperItemTitleModel *titleModel = [[PaperItemTitleModel alloc] initWithItemModel:child];
                        titleModel.order = _order + 1;
                        PaperItemTitleModelCellFrame *titleFrame = [[PaperItemTitleModelCellFrame alloc] init];
                        titleFrame.model = titleModel;
                        //添加到数据源
                        [_itemsDataSource addObject:titleFrame];
                        //选项
                        NSArray *optFrames = [self createCellOptions:child.children
                                                            itemType:child.itemType
                                                        outOptModels:&optModelArrays];
                        //添加到数据源
                        if(optFrames && optFrames.count > 0){
                            [_itemsDataSource addObjectsFromArray:optFrames];
                        }
                        //答案解析
                        if(_displayAnswer && optModelArrays){
                            PaperItemAnalysisModel *analysisModel = [[PaperItemAnalysisModel alloc] initWithItemModel:child];
                            analysisModel.options = optModelArrays;
                            PaperItemAnalysisModelCellFrame *analysisFrame = [[PaperItemAnalysisModelCellFrame alloc] init];
                            analysisFrame.model = analysisModel;
                            //添加到数据源
                            [_itemsDataSource addObject:analysisFrame];
                        }
                    }
                }
                break;
            }
            case PaperItemTypeShareAnswer:{//共享答案题
                //一级标题
                if(_itemModel.itemContent && _itemModel.itemContent.length > 0){
                    PaperItemTitleModelCellFrame *titleFrame = [[PaperItemTitleModelCellFrame alloc] init];
                    titleFrame.model = [[PaperItemTitleModel alloc] initWithItemModel:_itemModel];
                    //添加到数据源
                    [_itemsDataSource addObject:titleFrame];
                }
                //子题
                if(_itemModel.children && _itemModel.children.count > 0){
                    NSUInteger max = 0, index = _itemModel.index;
                    PaperItemModel *p;
                    NSMutableArray *optItemModels = [NSMutableArray array];
                    for(PaperItemModel *child in _itemModel.children){
                        if(!child) continue;
                        if(child.order > max){
                            if(p){
                                [optItemModels addObject:p];
                            }
                            p = child;
                            max = child.order;
                        }else{
                            [optItemModels addObject:child];
                        }
                    }
                    if(p && p.children && p.children.count > index){
                        PaperItemModel *subItemModel = [p.children objectAtIndex:index];
                        if(subItemModel){
                            //子标题
                            PaperItemTitleModel *titleModel = [[PaperItemTitleModel alloc] initWithItemModel:subItemModel];
                            titleModel.order = _order + 1;
                            PaperItemTitleModelCellFrame *titleFrame = [[PaperItemTitleModelCellFrame alloc] init];
                            titleFrame.model = titleModel;
                            //添加到数据源
                            [_itemsDataSource addObject:titleFrame];
                            //选项
                            NSArray *optFrames = [self createCellOptions:optItemModels
                                                                itemType:subItemModel.itemType
                                                            outOptModels:&optModelArrays];
                            //添加到数据源
                            if(optFrames && optFrames.count > 0){
                                [_itemsDataSource addObjectsFromArray:optFrames];
                            }
                            //答案解析
                            if(_displayAnswer && optModelArrays){
                                PaperItemAnalysisModel *analysisModel = [[PaperItemAnalysisModel alloc] initWithItemModel:subItemModel];
                                analysisModel.options = optModelArrays;
                                PaperItemAnalysisModelCellFrame *analysisFrame = [[PaperItemAnalysisModelCellFrame alloc] init];
                                analysisFrame.model = analysisModel;
                                //添加到数据源
                                [_itemsDataSource addObject:analysisFrame];
                            }
                        }
                    }
                }
                break;
            }
            default:
                break;
        }
        //updateUI
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"刷新试题[%d]UI...", (int)_order);
            //刷新数据
            [self.tableView reloadData];
            //关闭等待动画
            [_waitHud hide:YES];
        });
    });
}

//加载试题数据
-(NSArray *)createCellOptions:(NSArray *)options itemType:(NSUInteger)type outOptModels:(NSArray **)optModels{
    NSUInteger len = 0;
    if(options && (len = options.count) > 0){
        //初始化选项数据模型数组
        NSMutableArray *optModelArrays = [NSMutableArray arrayWithCapacity:len],
                       *optFrames = [NSMutableArray arrayWithCapacity:len];
        //选项
        for(PaperItemModel *itemModel in options){
            if(!itemModel) continue;
            PaperItemOptModel *optModel = [[PaperItemOptModel alloc] initWithItemModel:itemModel];
            optModel.itemType = type;
            optModel.display = _displayAnswer;
            //添加到数据模型数组
            [optModelArrays addObject:optModel];
            //optCellFrame
            PaperItemOptModelCellFrame *optFrame = [[PaperItemOptModelCellFrame alloc] init];
            optFrame.model = optModel;
            [optFrames addObject:optFrame];
        }
        if(optModelArrays.count > 0){
            *optModels = [optModelArrays copy];
        }
        return [optFrames copy];
    }
    return nil;
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(_itemsDataSource && _itemsDataSource.count){
        [_itemsDataSource removeAllObjects];
    }
}

#pragma mark - Table view data source
//总行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_itemsDataSource){
        return _itemsDataSource.count;
    }
    return 0;
}
//创建行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id data = [_itemsDataSource objectAtIndex:indexPath.row];
    //标题
    if([data isKindOfClass:[PaperItemTitleModelCellFrame class]]){
        PaperItemTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kPaperItemViewController_cellTitleIdentifier];
        if(!cell){
            cell = [[PaperItemTitleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:__kPaperItemViewController_cellTitleIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell loadModelCellFrame:data];
        return cell;
    }
    //选项
    if([data isKindOfClass:[PaperItemOptModelCellFrame class]]){
        PaperItemOptTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kPaperItemViewController_cellOptIdentifier];
        if(!cell){
            cell = [[PaperItemOptTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:__kPaperItemViewController_cellOptIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell loadModelCellFrame:data];
        return cell;
    }
    //答案解析
    if([data isKindOfClass:[PaperItemAnalysisModelCellFrame class]]){
        PaperItemAnalysisTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kPaperItemViewController_cellAnalysisIdentifier];
        if(!cell){
            cell = [[PaperItemAnalysisTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:__kPaperItemViewController_cellAnalysisIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell loadModelCellFrame:data];
        return cell;
    }
    return nil;
}
//获取行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[_itemsDataSource objectAtIndex:indexPath.row] cellHeight];
}
//点击选中
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //异步线程处理点击事件
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        id cellFrame = [_itemsDataSource objectAtIndex:indexPath.row];
        //选项
        if([cellFrame isKindOfClass:[PaperItemOptModelCellFrame class]]){
            NSLog(@"异步线程处理点击选择试题[%d]-%@", (int)_order, indexPath);
            PaperItemOptModel *optModel = ((PaperItemOptModelCellFrame *)cellFrame).model;
            if(optModel.itemType == PaperItemTypeSingle){//单选
                //单选重复选择，忽略
                if(((PaperItemOptModelCellFrame *)cellFrame).isSelected) return;
                //更新数据库
                //本地
                NSMutableArray *reloadIndexPaths = [NSMutableArray array];
                for(NSUInteger i = 0; i < _itemsDataSource.count; i++){
                    id frame = [_itemsDataSource objectAtIndex:i];
                    if([frame isKindOfClass:[PaperItemOptModelCellFrame class]]){
                        PaperItemOptModel *opt = ((PaperItemOptModelCellFrame *)frame).model;
                        if(((PaperItemOptModelCellFrame *)frame).isSelected || [opt.Id isEqualToString:optModel.Id]){
                            opt.myAnswers = optModel.Id;
                            ((PaperItemOptModelCellFrame *)frame).model = opt;
                            [reloadIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                        }
                    }
                }
                //UpdateUI
                if(reloadIndexPaths.count > 0){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [tableView reloadRowsAtIndexPaths:reloadIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                    });
                }
            }else{//多选
                
            }
        }
    });
}

@end