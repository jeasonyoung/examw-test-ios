//
//  PaperDetailViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/2.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperDetailViewController.h"

#import "PaperDetailViewCell.h"
#import "PaperDetailModel.h"

#import "WaitForAnimation.h"

#import "PaperReview.h"
#import "PaperService.h"
//
#import "ItemViewController.h"
#import "ResultViewController.h"
//
#import "PaperRecordService.h"
#import "PaperRecord.h"
#import "PaperItemRecord.h"

//
#define __kPaperDetailViewController_infoStructuresTotal @"大题数:%d"
#define __kPaperDetailViewController_infoItemsTotal @"总题数:%d"
#define __kPaperDetailViewController_infoScores @"卷面总分:%d分"
#define __kPaperDetailViewController_infoTimes @"考试时长:%d分钟"

#define __kPaperDetailViewController_waitMsg @"加载数据..."//

#define __kPaperDetailViewController_cellIdentifierFormat @"cell_%d"
//试卷明细视图控制器成员变量
@interface PaperDetailViewController ()<UITableViewDataSource,UITableViewDelegate,PaperDetailViewCellDelegate>{
    NSString *_paperCode,*_paperRecordCode;
    PaperReview *_review;
    PaperRecordService *_paperRecordService;
    PaperRecord *_paperRecord;
    UITableView *_tableView;
    NSMutableArray *_dataCache;
    
    ResultViewController *_resultController;
    ItemViewController *_itemController;
}
@end
//试卷明细视图控制器实现
@implementation PaperDetailViewController
#pragma mark 初始化
-(instancetype)initWithPaperCode:(NSString *)paperCode paperRecordCode:(NSString *)paperRecordCode{
    if(self = [super init]){
        _paperCode = paperCode;
        _paperRecordCode = paperRecordCode;
    }
    return self;
}
#pragma mark 初始化
-(instancetype)initWithPaperCode:(NSString *)paperCode{
    return [self initWithPaperCode:paperCode paperRecordCode:nil];
}
#pragma mark 加载入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //关闭滚动条y轴自动下移
    //self.automaticallyAdjustsScrollViewInsets = NO;
    //数据列表
    _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    //加载数据
    [self loadDetailsData];
}
//加载数据
-(void)loadDetailsData{
    //初始化等待动画
    WaitForAnimation *wattingFor = [[WaitForAnimation alloc]initWithView:self.view
                                                               WaitTitle:__kPaperDetailViewController_waitMsg];
    //开启等待动画
    [wattingFor show];
    //加载数据缓存
    _dataCache = [NSMutableArray arrayWithCapacity:3];
    PaperService *pService = [[PaperService alloc]init];
    _review = [pService loadPaperWithCode:_paperCode];
    //添加标题
    PaperDetailModelFrame *modelTitleFrame = [self setupModelTitleWithPaperReview:_review];
    if(modelTitleFrame){
        [_dataCache addObject:modelTitleFrame];
    }
    //添加按钮
    PaperDetailModelFrame *modelBtnsFrame = [self setupModelButtonsWithPaperReview:_review];
    if(modelBtnsFrame){
        [_dataCache addObject:modelBtnsFrame];
    }
    //添加描述
    PaperDetailModelFrame *modelDetailFrame = [self setupModelDescWithPaperReview:_review];
    if(modelDetailFrame){
        [_dataCache addObject:modelDetailFrame];
    }
    
    //重新刷新数据
    [_tableView reloadData];
    //关闭等待动画
    [wattingFor hide];
}
//试卷标题
-(PaperDetailModelFrame *)setupModelTitleWithPaperReview:(PaperReview *)review{
    NSString *title = (review ? review.name : @"");
    //
    PaperDetailModelFrame *modelFrame = [[PaperDetailModelFrame alloc]init];
    modelFrame.model = [PaperDetailModel modelWithType:__kPaperDetailModel_typeTitle title:title];
    //
    return modelFrame;
}
//添加按钮
-(PaperDetailModelFrame *)setupModelButtonsWithPaperReview:(PaperReview *)review{
    PaperRecordService *paperRecordService = [[PaperRecordService alloc]init];
    if(_paperRecordCode && _paperRecordCode.length > 0){
        _paperRecord = [paperRecordService loadRecordWithPaperRecordCode:_paperRecordCode];
    }else{
        _paperRecord = [paperRecordService loadLastRecordWithPaperCode:review.code];
    }
    NSString *content = nil;
    if(_paperRecord){
        BOOL isView = (_paperRecord.status.integerValue == [NSNumber numberWithBool:YES].integerValue);
        content = [NSString stringWithFormat:@"%d",isView];
    }
    PaperDetailModelFrame *modelFrame = [[PaperDetailModelFrame alloc]init];
    modelFrame.model = [PaperDetailModel modelWithType:__kPaperDetailModel_typeButtons title:content];
    return modelFrame;
}
//添加描述信息
-(PaperDetailModelFrame *)setupModelDescWithPaperReview:(PaperReview *)review{
    NSMutableString *content = [NSMutableString string];
    //大题数
    [content appendFormat:__kPaperDetailViewController_infoStructuresTotal,(int)review.structures.count];
    [content appendString:@"<br/>"];
    //试题数
    [content appendFormat:__kPaperDetailViewController_infoItemsTotal,(int)review.total];
    [content appendString:@"<br/>"];
    //卷面总分
    [content appendFormat:__kPaperDetailViewController_infoScores,review.score.intValue];
    [content appendString:@"<br/>"];
    //考试时长
    [content appendFormat:__kPaperDetailViewController_infoTimes,(int)review.time];
    [content appendString:@"<br/><br/><br/>"];
    
    //
    //循环试卷结构
    for(PaperStructure *ps in review.structures){
        if(ps && ps.title && ps.title.length > 0){
            [content appendFormat:@"%@[共%d题]<br/>",ps.title,(int)ps.total];
            if(ps.desc && ps.desc.length > 0){
                [content appendFormat:@" %@",ps.desc];
            }
            [content appendString:@"<br/><br/>"];
        }
    }
    PaperDetailModelFrame *modelFrame = [[PaperDetailModelFrame alloc]init];
    modelFrame.model = [PaperDetailModel modelWithType:__kPaperDetailModel_typeDesc title:content];
    return modelFrame;
}

#pragma mark UITableViewDataSource
//数据的总行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_dataCache){
        return _dataCache.count;
    }
    return 0;
}
//创建数据行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PaperDetailModelFrame *modelFrame = [_dataCache objectAtIndex:indexPath.row];
    NSString *cellIdentifier = [NSString stringWithFormat:__kPaperDetailViewController_cellIdentifierFormat,(int)modelFrame.modelType];
    PaperDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        switch (modelFrame.modelType) {
            case __kPaperDetailModel_typeTitle:{//标题
                cell = [[PaperDetailTitleViewCell alloc]initWithReuseIdentifier:cellIdentifier];
                break;
            }
            case __kPaperDetailModel_typeButtons:{//按钮
                cell = [[PaperDetailBtnsViewCell alloc]initWithReuseIdentifier:cellIdentifier];
                cell.delegate = self;
                break;
            }
            case __kPaperDetailModel_typeDesc:{//描述
                cell = [[PaperDetailDescViewCell alloc]initWithReuseIdentifier:cellIdentifier];
                break;
            }
            default:
                break;
        }
    }
    [cell loadModelFrame:modelFrame];
    return cell;
}
#pragma mark UITableViewDelegate
//数据行高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    PaperDetailModelFrame *modelFrame = [_dataCache objectAtIndex:indexPath.row];
    //NSLog(@"%d=>%f",indexPath.row,modelFrame.rowHeight);
    return modelFrame.rowHeight;
}
//选中行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark PaperDetailViewCellDelegate
//按钮事件
-(void)detailViewCell:(UITableViewCell *)cell didButtonClick:(UIButton *)sender{
    switch (sender.tag) {
        case __kPaperDetailViewCell_btnTypeStart://开始考试
        case __kPaperDetailViewCell_btnTypeReview://重新开始
        {
            _paperRecord = [_paperRecordService createNewRecordWithPaperCode:_review.code];
            _itemController = [[ItemViewController alloc] initWithPaper:_review record:_paperRecord displayAnswer:NO order:0];
            _itemController.hidesBottomBarWhenPushed = NO;
            [self.navigationController pushViewController:_itemController animated:NO];
            break;
        }
        case __kPaperDetailViewCell_btnTypeContinue://继续考试
        {
            PaperItemRecord *itemReord = [_paperRecordService loadLastRecordWithPaperRecordCode:_paperRecord.code];
            NSInteger order = [_review findOrderAtItemCode:itemReord.itemCode];
            _itemController = [[ItemViewController alloc]initWithPaper:_review record:_paperRecord displayAnswer:NO order:order];
            _itemController.hidesBottomBarWhenPushed = NO;
            [self.navigationController pushViewController:_itemController animated:NO];
            break;
        }
        case __kPaperDetailViewCell_btnTypeView://查看成绩
        {
            _resultController = [[ResultViewController alloc]initWithPaper:_review andRecord:_paperRecord];
            _resultController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:_resultController animated:NO];
            break;
        }
        default:
            break;
    }
 //   NSLog(@"sender:%@",sender);
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end