//
//  PaperDetailsViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperDetailsViewController.h"

#import "PaperInfoModel.h"
#import "PaperModel.h"
#import "PaperStructureModel.h"
#import "PaperItemModel.h"

#import "PaperRecordModel.h"

#import "PaperTitleModel.h"
#import "PaperTitleModelCellFrame.h"
#import "PaperTitleTableViewCell.h"

#import "PaperButtonModel.h"
#import "PaperButtonModelCellFrame.h"
#import "PaperButtonTableViewCell.h"

#import "PaperDetailsModel.h"
#import "PaperDetailsModelCellFrame.h"
#import "PaperDetailsTableViewCell.h"

#import "AnswerCardSectionModel.h"
#import "AnswerCardModel.h"

#import "PaperService.h"

#import "MBProgressHUD.h"
#import "UIColor+Hex.h"
#import "EffectsUtils.h"

#import "PaperViewController.h"
#import "PaperResultViewController.h"


//答题卡数据模型扩展
@interface AnswerCardModel(makeObjects)
//加载试题状态
-(void)loadItemStatusWithObjs:(NSArray *)objs;
@end
//答题卡数据模型扩展实现
@implementation AnswerCardModel(makeObjects)
#pragma mark 加载试题状态
-(void)loadItemStatusWithObjs:(NSArray *)objs{
    PaperService *paperService = [objs objectAtIndex:0];
    NSString *paperRecordId = [objs objectAtIndex:1];
    NSArray *itemsArrays = [objs objectAtIndex:2];
    
    if(paperService && paperRecordId && itemsArrays && itemsArrays.count > self.order){
        PaperItemModel *itemModel = [itemsArrays objectAtIndex:self.order];
        if(!itemModel)return;
        NSLog(@"加载试题[%@$%d]做题状态...",itemModel.itemId, (int)itemModel.index);
        self.status = [paperService exitRecordWithPaperRecordId:paperRecordId itemModel:itemModel];
    }
}
@end

#define __kPaperDetailsViewController_title @"试卷详情"//

#define __kPaperDetailsViewController_tag_start 0x01//开始考试
#define __kPaperDetailsViewController_tag_continue 0x02//继续考试
#define __kPaperDetailsViewController_tag_reset 0x03//重新开始
#define __kPaperDetailsViewController_tag_review 0x04//查看成绩

#define __kPaperDetailsViewController_cellIdentifier @"_cellDetails_%d"//
//试卷明细视图控制器成员变量
@interface PaperDetailsViewController ()<PaperViewControllerDelegate>{
    //按钮类型
    NSUInteger _tagValue;
    //
    BOOL _displayAnswer;
    //试卷信息数据模型
    PaperInfoModel *_infoModel;
    //试卷数据模型
    PaperModel *_paperModel;
    //试卷记录数据模型
    PaperRecordModel *_recordModel;
    
    //数据源
    NSMutableArray *_dataSource;
    
    //试卷服务
    PaperService *_service;
    //等待动画
    MBProgressHUD *_waitHud;
}
@end

//试卷明细视图控制器实现
@implementation PaperDetailsViewController

#pragma mark 初始化
-(instancetype)initWithPaperInfo:(PaperInfoModel *)model{
    if(self = [super initWithStyle:UITableViewStylePlain]){
        _infoModel = model;
        _displayAnswer = NO;
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.title = __kPaperDetailsViewController_title;
    //开启等待动画
    _waitHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _waitHud.color = [UIColor colorWithHex:0xD3D3D3];
    //初始化数据源
    _dataSource = [NSMutableArray arrayWithCapacity:3];
    //加载数据
    [self loadData];
}

//加载数据
-(void)loadData{
    //隐藏行分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //异步加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //初始化试卷服务
        _service = [[PaperService alloc] init];
        //加载数据
        _paperModel = [_service loadPaperModelWithPaperId:_infoModel.Id];
        NSLog(@"paperModel=>%@",_paperModel);
        if(_paperModel && _infoModel){
            //1.标题
            PaperTitleModelCellFrame *titleModelCellFrame = [[PaperTitleModelCellFrame alloc] init];
            titleModelCellFrame.model = [[PaperTitleModel alloc]initWithTitle:_paperModel.name
                                                                   andSubject:_infoModel.subject];
            [_dataSource addObject:titleModelCellFrame];
            //2.按钮
            PaperButtonModelCellFrame *btnModelCellFrame = [[PaperButtonModelCellFrame alloc] init];
            _recordModel = [_service loadNewsRecordWithPaperId:_paperModel.code];
            btnModelCellFrame.model = [[PaperButtonModel alloc] initWithPaperRecord:_recordModel];
            [_dataSource addObject:btnModelCellFrame];
            //3.明细
            PaperDetailsModel *detailsModel = [[PaperDetailsModel alloc] init];
            detailsModel.desc = _paperModel.desc;
            detailsModel.source = _paperModel.source;
            detailsModel.area = _paperModel.area;
            detailsModel.type = _paperModel.type;
            detailsModel.time = _paperModel.time;
            detailsModel.year = _paperModel.year;
            detailsModel.total = _paperModel.total;
            detailsModel.score = _paperModel.score;
            PaperDetailsModelCellFrame *detailsCellFrame = [[PaperDetailsModelCellFrame alloc] init];
            detailsCellFrame.model = detailsModel;
            [_dataSource addObject:detailsCellFrame];
            //更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                //
                [self.tableView reloadData];
                [_waitHud hide:YES];
            });
        }
    });
}

//跳转到试卷控制器
-(void)doPaperControllerWithTag:(NSInteger)tag{
    _tagValue = tag;
    //异步线程处理
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"异步线程处理按钮事件...");
        switch (_tagValue) {
            case __kPaperDetailsViewController_tag_start://开始考试
            case __kPaperDetailsViewController_tag_reset://重新开始
            case __kPaperDetailsViewController_tag_continue://继续考试
            {
                if(_tagValue != __kPaperDetailsViewController_tag_continue){
                    //新建试卷记录
                    _recordModel = [[PaperRecordModel alloc] initWithPaperId:_infoModel.Id];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSLog(@"异步线程保存新建的试卷记录到数据库...");
                        //保存到数据库
                        [_service addPaperRecord:_recordModel];
                    });
                }
                _displayAnswer = NO;
                //updateUI
                dispatch_async(dispatch_get_main_queue(), ^{
                    PaperViewController *controller = [[PaperViewController alloc] init];
                    controller.delegate = self;
                    controller.hidesBottomBarWhenPushed = YES;
                    [EffectsUtils animationPushWithView:self.navigationController.view delegate:self];
                    [self.navigationController pushViewController:controller animated:YES];
                });
                break;
            }
            case __kPaperDetailsViewController_tag_review:{//查看成绩
                _displayAnswer = YES;
                //updateUI
                dispatch_async(dispatch_get_main_queue(), ^{
                    PaperResultViewController *controller = [[PaperResultViewController alloc] initWithPaperRecordId:_recordModel.Id];
                    controller.paperViewControllerDelegate = self;
                    controller.hidesBottomBarWhenPushed = YES;
                    [EffectsUtils animationPushWithView:self.navigationController.view delegate:self];
                    [self.navigationController pushViewController:controller animated:YES];
                });
                break;
            }
            default:{
                 NSLog(@"未定义规则的Tag=>%d ...",(int)_tagValue);
                break;
            }
        }
    });    
}

#pragma mark PaperViewControllerDelegate
NSMutableArray *itemsArrays,*cardSection;
NSMutableDictionary *cardAllData;
//加载数据源(PaperItemModel数组,异步线程加载)
-(NSArray *)dataSourceOfPaperViewController:(PaperViewController *)controller{
    NSLog(@"开始加载试卷数据...");
    if(_paperModel && _paperModel.total > 0 && _paperModel.structures){
        //初始化
        itemsArrays = [NSMutableArray arrayWithCapacity:_paperModel.total];
        NSUInteger total = _paperModel.structures.count;
        cardSection = [NSMutableArray arrayWithCapacity:total];
        cardAllData = [NSMutableDictionary dictionaryWithCapacity:total];
        //
        NSUInteger section = 0, order = 0;
        //试卷结构
        for(PaperStructureModel *structure in _paperModel.structures){
            if(!structure || !structure.items) continue;
            //创建答题卡分组数据模型
            [cardSection addObject:[[AnswerCardSectionModel alloc] initWithTitle:structure.title desc:structure.desc]];
            //
            NSMutableArray *cardModels = [NSMutableArray arrayWithCapacity:structure.items.count];
            //循环试题
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
                    [itemsArrays addObject:item];
                    //
                    [cardModels addObject:[[AnswerCardModel alloc] initWithOrder:order status:0 displayAnswer:_displayAnswer]];
                    //
                    order += 1;
                }
            }
            //
            [cardAllData setObject:[cardModels copy] forKey:[NSNumber numberWithInteger:section]];
            //
            section += 1;
        }
        return itemsArrays;
    }
    return nil;
}
//加载的当前试题题序
-(NSUInteger)currentOrderOfPaperViewController:(PaperViewController *)controller{
    //继续考试
    if((_tagValue == __kPaperDetailsViewController_tag_continue) && _recordModel && itemsArrays && itemsArrays.count > 0){
        NSString *lastItemId = [_service loadNewsItemIndexWithPaperRecordId:_recordModel.Id];
        if(lastItemId && lastItemId.length > 0){
            for(NSUInteger i = 0; i < itemsArrays.count; i++){
                PaperItemModel *itemModel = [itemsArrays objectAtIndex:i];
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
//加载试题答案(异步线程中调用)
-(NSString *)loadMyAnswerWithModel:(PaperItemModel *)itemModel{
    if(itemModel && _recordModel){
        NSLog(@"加载试题[%@$%d]的答案...", itemModel.itemId, (int)itemModel.index);
        return [_service loadRecordAnswersWithPaperRecordId:_recordModel.Id itemModel:itemModel];
    }
    return nil;
}
//更新做题记录到SQL(异步线程中调用)
-(void)updateRecordAnswerWithModel:(PaperItemModel *)itemModel myAnswers:(NSString *)myAnswers useTimes:(NSUInteger)times{
    if(_recordModel && itemModel && myAnswers){
        NSLog(@"更新做题[%@$%d]记录到数据库...",itemModel.itemId, (int)itemModel.index);
        [_service addRecordWithPaperRecordId:_recordModel.Id itemModel:itemModel myAnswers:myAnswers useTimes:times];
    }
}
//更新收藏记录(异步线程中被调用)
-(BOOL)updateFavoriteWithModel:(PaperItemModel *)itemModel{
    if(_infoModel && itemModel){
        NSLog(@"更新试题[%@$%d]收藏记录...", itemModel.itemId, (int)itemModel.index);
        return [_service updateFavoriteWithPaperId:_infoModel.Id itemModel:itemModel];
    }
    return NO;
}
//交卷处理(异步线程中被调用)
-(void)submitPaper:(void (^)(NSString *))resultController{
    if(_recordModel){
        NSLog(@"交卷处理[%@]...", _recordModel.Id);
        [_service submitWithPaperRecordId:_recordModel.Id];
        //试卷记录ID
        resultController(_recordModel.Id);
    }
}
//加载答题卡数据(异步线程中被调用)
-(void)loadAnswerCardDataWithSection:(NSArray *__autoreleasing *)sections andAllData:(NSDictionary *__autoreleasing *)dict{
    NSLog(@"加载答题卡数据源...");
    if(cardSection && cardAllData){
        *sections = [cardSection copy];
        
        //加载做题记录
        if(cardAllData && cardAllData.count > 0 && itemsArrays && _recordModel){
            NSArray *keys = cardAllData.allKeys;
            for(NSNumber *key in keys){
                if(!key) continue;
                NSArray *arrays = [cardAllData objectForKey:key];
                if(arrays && arrays.count > 0){
                    [arrays makeObjectsPerformSelector:@selector(loadItemStatusWithObjs:)
                                            withObject:@[_service,_recordModel.Id,itemsArrays]];
                }
            }
        }
        
        *dict = [cardAllData copy];
    }
}


#pragma mark tableview
//加载数据量
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"加载数据量...");
    if(_dataSource){
        return _dataSource.count;
    }
    return 0;
}
//创建行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"创建行...");
    NSString *identifier = [NSString stringWithFormat:__kPaperDetailsViewController_cellIdentifier, (int)indexPath.row];
    switch (indexPath.row) {
        case 0://标题
        {
            PaperTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if(!cell){
                NSLog(@"创建标题行...");
                cell = [[PaperTitleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            //加载数据
            [cell loadModelCellFrame:[_dataSource objectAtIndex:indexPath.row]];
            return cell;
        }
        case 1:{//按钮
            PaperButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if(!cell){
                NSLog(@"创建按钮行...");
                cell = [[PaperButtonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.btnClick = ^(NSInteger tag){
                    NSLog(@"按钮点击:>>>%d",(int)tag);
                    [self doPaperControllerWithTag:tag];
                };
            }
            //加载数据
            [cell loadModelCellFrame:[_dataSource objectAtIndex:indexPath.row]];
            return cell;
        }
        case 2:{//明细
            PaperDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if(!cell){
                NSLog(@"创建明细行...");
                cell = [[PaperDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            //加载数据
            [cell loadModelCellFrame:[_dataSource objectAtIndex:indexPath.row]];
            return cell;
        }
        default:
            break;
    }
    return nil;
}
//获取行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[_dataSource objectAtIndex:indexPath.row] cellHeight];
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
