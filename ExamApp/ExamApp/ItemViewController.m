//
//  ItemViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ItemViewController.h"
#import "UIViewController+VisibleView.h"

#import "NSStringUtils.h"

#import "ItemViewExitAlert.h"
#import "FavoriteBarItem.h"
#import "ETTimerView.h"
#import "SubmitBarItem.h"
#import "ItemContentPanel.h"

#import "PaperReview.h"
#import "PaperRecord.h"
#import "PaperItemRecord.h"
#import "PaperRecordService.h"

#import "PaperListViewController.h"
#import "LearnRecordViewController.h"
#import "AnswersheetViewController.h"
#import "ResultViewController.h"

#define __kItemViewController_timerWith 80//计时器宽度
#define __kItemViewController_timerHeight 30//计时器高度
//试题考试视图控制器成员变量
@interface ItemViewController ()<ItemViewExitAlertDelegate,FavoriteBarItemDelegate,SubmitBarItemDelegate,ItemContentPanelDelegate>{
    PaperReview *_paperReview;
    PaperRecord *_paperRecord;
    BOOL _displayAnswer;
    NSInteger _currentOrder,_itemsTotals;
    
    ItemViewExitAlert *_exitAlert;
    ETTimerView *_timerView;
    FavoriteBarItem *_btnFav;
    ItemContentPanel *_itemPanel;
    
    NSDate *_startTime;
    NSString *_multyAnswers;
    
    PaperItemOrderIndexPath *_itemOrderIndexPath;
    PaperRecordService *_paperRecordService;
    
    AnswersheetViewController *_sheetController;
    ResultViewController *_resultController;
}
@end
//试题考试视图控制器实现
@implementation ItemViewController
#pragma mark 初始化
-(instancetype)initWithPaper:(PaperReview *)review record:(PaperRecord *)record displayAnswer:(BOOL)display order:(NSUInteger)order{
    if(self = [super init]){
        _paperReview = review;
        _paperRecord = record;
        _displayAnswer = display;
        _currentOrder = order;
        _itemsTotals = review.total;
    }
    return self;
}
#pragma mark 加载界面UI
-(void)viewDidLoad{
    [super viewDidLoad];
     //关闭滚动条y轴自动下移
    self.automaticallyAdjustsScrollViewInsets = NO;
    //加载顶部工具栏
    [self setupTopBars];
    //加载底部工具栏
    [self setupBottomBars];
    //初始化服务
    _paperRecordService = [[PaperRecordService alloc]init];
    //试题视图
    _itemPanel = [[ItemContentPanel alloc]initWithFrame:[self loadVisibleViewFrame]];
    _itemPanel.delegate = self;
    [self.view addSubview:_itemPanel];
    
    //加载数据
    [self loadDataAtOrder:_currentOrder displayAnswer:_displayAnswer];
}
//加载顶部工具栏
-(void)setupTopBars{
    //左边按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                                                          target:self
                                                                                          action:@selector(topBarLeftBtnClick:)];
    //右边按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                           target:self
                                                                                           action:@selector(topBarRightBtnClick:)];
    
}
//顶部工具栏左边按钮事件
-(void)topBarLeftBtnClick:(UIBarButtonItem *)sender{
    if(!_displayAnswer){
        _exitAlert = [[ItemViewExitAlert alloc]init];
        _exitAlert.delegate = self;
        [_exitAlert showAlert];
    }else{
        //退出当前视图
        [self popViewController];
    }
}
#pragma mark ItemViewExitAlertDelegate
-(void)alertExitWithTag:(NSInteger)tag{
    NSLog(@"alertExitWithTag=>%d",(int)tag);
    switch (tag) {
        case __kItemViewExitAlertCancel:{//取消
            break;
        }
        case __kItemViewExitAlertSubmit:{//交卷
            if(_paperRecordService && _paperRecord && _timerView){
                //关闭倒计时
                _paperRecord.useTimes = [_timerView stop];
                //提交试卷
                [_paperRecordService submitWithPaperRecord:_paperRecord];
                //查看结果
                _resultController = [[ResultViewController alloc]initWithPaper:_paperReview andRecord:_paperRecord];
                _resultController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:_resultController animated:NO];
                return;
            }
            break;
        }
        case __kItemViewExitAlertConfirm:{//下次再做
            //退出当前视图
            [self popViewController];
        }
        default:
            break;
    }
}
//顶部工具栏右边按钮事件
-(void)topBarRightBtnClick:(UIBarButtonItem *)sender{
    //隐藏状态栏
    self.navigationController.toolbarHidden = YES;
    if(!_displayAnswer){
        _sheetController = [[AnswersheetViewController alloc]initWithPaperReview:_paperReview PaperRecord:_paperRecord];
        _sheetController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:_sheetController animated:NO];
    }else{
        NSArray *controllers = self.navigationController.viewControllers;
        if(controllers && controllers.count > 0){
            for(UIViewController *vc in controllers){
                if(vc && [vc isKindOfClass:[ResultViewController class]]){
                    _resultController = (ResultViewController *)vc;
                    break;
                }
            }
        }
        if(!_resultController){
            _resultController = [[ResultViewController alloc]initWithPaper:_paperReview andRecord:_paperRecord];
            _resultController.isAnswersheet = YES;
            [self.navigationController pushViewController:_resultController animated:NO];
        }else{
            _resultController.isAnswersheet = YES;
            [self.navigationController popToViewController:_resultController animated:NO];
        }
    }
}
//加载底部工具栏
-(void)setupBottomBars{
    //上一题
    UIBarButtonItem *btnPrev = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                                            target:self
                                                                            action:@selector(btnPrevClick:)];
    //下一题
    UIBarButtonItem *btnNext = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                                                            target:self
                                                                            action:@selector(btnNextClick:)];
    //分隔平均填充
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil action:nil];
    //收藏
    _btnFav = [[FavoriteBarItem alloc]initWidthDelegate:self];
    
    NSArray *bars;
    if(!_displayAnswer){
        CGRect timerViewRect = CGRectMake(0, 0, __kItemViewController_timerWith, __kItemViewController_timerHeight);
        _timerView = [[ETTimerView alloc]initWithFrame:timerViewRect Total:_paperReview.time];
        UIBarButtonItem *btnTimer = [_timerView toBarButtonItem];
        //交卷
        SubmitBarItem *btnSubmit = [[SubmitBarItem alloc]initWithDelegate:self];
        
        bars = @[btnPrev,space,_btnFav,space,btnTimer,space,btnSubmit,space,btnNext];
    }else{
        bars = @[btnPrev,space,_btnFav,space,btnNext];
    }
    //设置底部工具栏
    [self setToolbarItems:bars animated:YES];    
}
#pragma mark FavoriteBarItemDelegate
//加载收藏状态
-(BOOL)stateWithFavorite:(FavoriteBarItem *)favorite{
    if(_paperReview && _paperRecordService && _currentOrder >= 0 && _currentOrder < _itemsTotals){
        __block BOOL state = NO;
        [_paperReview loadItemAtOrder:_currentOrder ItemBlock:^(PaperItemOrderIndexPath *indexPath) {
            if(indexPath && indexPath.item){
                NSString *itemCode = indexPath.item.code;
                NSInteger index = indexPath.index;
                state = [_paperRecordService exitFavoriteWithPaperCode:_paperReview.code ItemCode:itemCode atIndex:index];
            }
        }];
        return state;
    }
    return NO;
}
//收藏状态点击事件
-(void)clickWithFavorite:(FavoriteBarItem *)favorite{
    //NSLog(@"收藏状态：%d",favorite.state);
    if(_paperReview && _paperRecordService && _currentOrder >= 0 && _currentOrder < _itemsTotals){
        BOOL state = favorite.state;
        [_paperReview loadItemAtOrder:_currentOrder ItemBlock:^(PaperItemOrderIndexPath *indexPath) {
            if(indexPath && indexPath.item){
                NSString *paperCode = _paperReview.code;
                NSString *itemCode = indexPath.item.code;
                NSInteger index = indexPath.index;
                
                if(state){//添加收藏
                    [_paperRecordService addFavoriteWithPaperCode:paperCode Data:indexPath];
                }else{//删除收藏
                    [_paperRecordService removeFavoriteWithPaperCode:paperCode ItemCode:itemCode atIndex:index];
                }
            }
        }];
    }
}

//上一题
-(void)btnPrevClick:(UIBarButtonItem *)sender{
    if(_currentOrder == 0)return;
    _currentOrder--;
    if(_currentOrder < 0){
        _currentOrder = 0;
    }
    //重置开始时间
    _startTime = [NSDate date];
    //加载数据
    [_itemPanel loadDataAtOrder:_currentOrder];
}
//下一题
-(void)btnNextClick:(UIBarButtonItem *)sender{
    if(_currentOrder == _itemsTotals - 1)return;
    _currentOrder++;
    if(_currentOrder > _itemsTotals - 1){
        _currentOrder = _itemsTotals - 1;
    }
    //重置开始时间
    _startTime = [NSDate date];
    //加载数据
    [_itemPanel loadDataAtOrder:_currentOrder];
}

#pragma mark SubmitBarItemDelegate
-(void)clickSubmitBar:(SubmitBarItem *)bar{
    //交卷
    [self alertExitWithTag:__kItemViewExitAlertSubmit];
}
//退出当前视图
-(void)popViewController{
    NSArray *controllers = self.navigationController.viewControllers;
    if(controllers && controllers.count > 0){
        //NSLog(@"viewControllers=>%@",controllers);
        UIViewController *targetController;
        for(UIViewController *controller in controllers){
            if([controller isKindOfClass:[PaperListViewController class]]
               || [controller isKindOfClass:[LearnRecordViewController class]]){
                targetController = controller;
                break;
            }
        }
        if(targetController){
            //隐藏状态栏
            self.navigationController.toolbarHidden = YES;
            [self.navigationController popToViewController:targetController animated:YES];
        }else{
            //隐藏状态栏
            //self.navigationController.toolbarHidden = YES;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}
#pragma mark ItemContentPanelDelegate
//加载总题目数量
-(NSUInteger)numbersOfItemContentPanel{
    return _itemsTotals;
}
//加载试题数据
-(PaperItem *)dataWithItemView:(ItemView *)itemView atOrder:(NSUInteger)order{
    _currentOrder = order;
    __block PaperItem *item;
    if(_paperReview){
        [_paperReview loadItemAtOrder:order ItemBlock:^(PaperItemOrderIndexPath *indexPath) {
             _itemOrderIndexPath = indexPath;
            self.navigationItem.title = indexPath.structureTitle;
            item = indexPath.item;
        }];
    }
    //加载收藏数据
    if(_btnFav){
        [_btnFav reloadData];
    }
    return item;
}
//加载试题索引
-(NSUInteger)itemIndexWithItemView:(ItemView *)itemView atOrder:(NSUInteger)order{
    return (_itemOrderIndexPath ? _itemOrderIndexPath.index : 0);
}
//加载试题答案
-(NSString *)answerWithItemView:(ItemView *)itemView atOrder:(NSUInteger)order atIndex:(NSUInteger)index{
    if(_paperRecordService && _paperRecord){
        return [_paperRecordService loadAnswerRecordWithPaperRecordCode:_paperRecord.code
                                                               ItemCode:itemView.itemCode
                                                                atIndex:index];
    }
    return nil;
}
//是否显示答案解析
-(BOOL)displayAnswerWithItemView:(ItemView *)itemView atOrder:(NSUInteger)order{
    return _displayAnswer;
}
//选中
-(void)itemView:(ItemView *)itemView didSelectAtSelected:(ItemViewSelected *)selected atOrder:(NSUInteger)order{
    NSLog(@"选中＝> %@",selected);
    if(!selected || !_paperRecordService || !_itemOrderIndexPath)return;
    NSInteger useTime = [self doItemTimeSecondWithStart:_startTime];
    PaperItemRecord *itemRecord = [_paperRecordService loadRecordAndNewWithPaperRecordCode:_paperRecord.code
                                                                                  ItemCode:selected.itemCode
                                                                                   atIndex:selected.itemIndex];
    if(!itemRecord)return;
    itemRecord.structureCode = _itemOrderIndexPath.structureCode;
    itemRecord.itemType = [NSNumber numberWithInteger:itemView.itemType];
    itemRecord.itemContent = selected.itemJSON;
    itemRecord.answer = selected.selectedCode;
    itemRecord.useTimes = [NSNumber numberWithInteger:useTime];
    NSString *rightAnswers = selected.rightAnswers;
    if(rightAnswers && rightAnswers.length > 0){
        itemRecord.status = [NSNumber numberWithBool:([rightAnswers isEqualToString:itemRecord.answer])];
        //计算得分
        if(_paperReview){
            [_paperReview findStructureAtStructureCode:itemRecord.structureCode StructureBlock:^(PaperStructure *ps) {
                if(ps.score && ps.score.floatValue > 0){
                    if(itemRecord.status == [NSNumber numberWithBool:YES]){
                        itemRecord.score = ps.score;
                    }else if(ps.min && ps.min.floatValue > 0 && itemRecord.answer && itemRecord.answer.length > 0) {
                        NSArray *arrays = [itemRecord.answer componentsSeparatedByString:@","];
                        for(NSString *my in arrays){
                            if(!my || my.length == 0)continue;
                            if([NSStringUtils existContains:rightAnswers subText:my]){
                                itemRecord.score = ps.min;
                                break;
                            }
                        }
                    }
                }
            }];
        }
    }
    //更新数据
    if(_paperRecordService){
        [_paperRecordService submitWithItemRecord:itemRecord];
    }
    //重置开始时间
    _startTime = [NSDate date];
    //单选题进入一题
    if(selected.itemType == (NSUInteger)PaperItemTypeSingle || selected.itemType == (NSUInteger)PaperItemTypeJudge){
        [self btnNextClick:nil];
    }
}
//做题时间计算
-(NSInteger)doItemTimeSecondWithStart:(NSDate *)startTime{
    NSInteger second = 0;
    if(startTime){
        NSTimeInterval timeInterval = [startTime timeIntervalSinceNow];
        second = fabs(timeInterval);
    }
    return second;
}
#pragma mark 加载数据
-(void)loadDataAtOrder:(NSInteger)order displayAnswer:(BOOL)display{
    //开始时间
    _startTime = [NSDate date];
    
    _currentOrder = order;
    _displayAnswer = display;
    
    //加载数据
    [_itemPanel loadDataAtOrder:_currentOrder];
}

#pragma mark 试图将呈现
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
}
#pragma mark 试图将隐藏
-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.toolbarHidden = YES;
    [super viewWillDisappear:animated];
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
