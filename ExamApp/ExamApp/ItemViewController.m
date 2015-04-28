//
//  ItemViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ItemViewController.h"
#import "UIViewController+VisibleView.h"

#import "ItemViewExitAlert.h"
#import "FavoriteBarItem.h"
#import "ETTimerView.h"
#import "SubmitBarItem.h"
#import "ItemContentPanel.h"

#import "PaperReview.h"
#import "PaperRecord.h"
#import "PaperRecordService.h"

#import "PaperListViewController.h"
#import "AnswersheetViewController.h"
#import "ResultViewController.h"

#define __kItemViewController_timerWith 80//计时器宽度
#define __kItemViewController_timerHeight 30//计时器高度
//试题考试视图控制器成员变量
@interface ItemViewController ()<ItemViewExitAlertDelegate,FavoriteBarItemDelegate,SubmitBarItemDelegate,ItemViewDataSource,ItemContentPanelDelegate>{
    PaperReview *_paperReview;
    PaperRecord *_paperRecord;
    BOOL _displayAnswer;
    NSInteger _currentOrder,_itemsTotals;
    
    ItemViewExitAlert *_exitAlert;
    ETTimerView *_timerView;
    FavoriteBarItem *_btnFav;
    ItemContentPanel *_itemPanel;
    
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
    _itemPanel.dataSource = self;
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
            ////交卷处理
            //-(void)submitHandler{
            ////    if(_itemContentView){
            ////        [_itemContentView submit];
            ////    }
            ////    if(_recordService && _record && _timerView){
            ////        _record.useTimes = [_timerView stop];
            ////        [_recordService subjectWithPaperRecord:_record];
            ////    }
            ////    //查看结果
            ////    ResultViewController *rvc = [[ResultViewController alloc] initWithPaper:_review andRecord:_record];
            ////    rvc.hidesBottomBarWhenPushed = YES;
            ////    [self.navigationController pushViewController:rvc animated:NO];
            //}
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
        }
        _resultController.isAnswersheet = YES;
        [self.navigationController pushViewController:_resultController animated:NO];
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
    NSLog(@"收藏状态：%d",favorite.state);
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
    _currentOrder--;
    if(_currentOrder < 0){
        _currentOrder = 0;
        return;
    }
    //加载收藏数据
    if(_btnFav)[_btnFav reloadData];
     ///TODO:加载数据
}
//下一题
-(void)btnNextClick:(UIBarButtonItem *)sender{
    _currentOrder++;
    if(_currentOrder > _itemsTotals -1){
        _currentOrder = _itemsTotals - 1;
        return;
    }
    //加载收藏数据
    if(_btnFav)[_btnFav reloadData];
    ///TODO:加载数据
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
            if([controller isKindOfClass:[PaperListViewController class]]){
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
            self.navigationController.toolbarHidden = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
#pragma mark ItemViewDataSource
//加载试题数据
-(PaperItem*)dataWithItemView:(ItemView *)itemView{
    __block PaperItem *item;
    [_paperReview loadItemAtOrder:_currentOrder ItemBlock:^(PaperItemOrderIndexPath *indexPath) {
        _itemOrderIndexPath = indexPath;
        
        self.navigationItem.title = indexPath.structureTitle;
        item = indexPath.item;
    }];
    return item;;
}
//加载试题索引
-(NSUInteger)itemIndexWithItemView:(ItemView *)itemView{
    return (_itemOrderIndexPath ? _itemOrderIndexPath.index : 0);
}
//加载试题题序标题
-(NSString *)itemOrderTitleWithItemView:(ItemView *)itemView{
    return [NSString stringWithFormat:@"%d",(int)(_currentOrder + 1)];
}
//加载试题答案
-(NSString *)answerWithItemView:(ItemView *)itemView{
    NSString *answer = @"";
    if(_paperRecordService && _paperRecord && _itemOrderIndexPath){
        NSString *itemCode = _itemOrderIndexPath.item.code;
        NSInteger itemIndex = _itemOrderIndexPath.index;
        answer = [_paperRecordService loadAnswerRecordWithPaperRecordCode:_paperRecord.code ItemCode:itemCode atIndex:itemIndex];
    }
    return answer;
}
//是否显示答案解析
-(BOOL)displayAnswerWithItemView:(ItemView *)itemView{
    return _displayAnswer;
}
#pragma mark ItemContentPanelDelegate
//加载试题总数
-(NSUInteger)numbersOfItemContentPanel{
    return _itemsTotals;
}
//加载当前题序
-(NSUInteger)currentOfItemContentPanel{
    return _currentOrder;
}
//上一题
-(void)previousOfItemContentPanel{
    NSLog(@"加载上一题...");
    [self btnPrevClick:nil];
}
//下一题
-(void)nextOfItemContentPanel{
    NSLog(@"加载下一题...");
    [self btnNextClick:nil];
}
//选中
-(void)itemView:(ItemView *)itemView didSelectAtSelected:(ItemViewSelected *)selected{
    NSLog(@"选中＝> %@",selected);
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
#pragma mark 加载数据
-(void)loadDataAtOrder:(NSInteger)order displayAnswer:(BOOL)display{
    _currentOrder = order;
    _displayAnswer = display;
    
    //加载数据
    [_itemPanel loadData];
}
//#pragma mark 初始化
//-(instancetype)initWithPaper:(PaperReview *)review
//                       Order:(NSInteger)order
//                   andRecord:(PaperRecord *)record
//            andDisplayAnswer:(BOOL)displayAnswer{
//    if(self = [super init]){
//        _review = review;
//        _order = order;
//        _record = record;
//        _displayAnswer = displayAnswer;
//        
//        _imgFavoriteNormal = [UIImage imageNamed:__kItemViewController_favorite_normal_img];
//        _imgFavoriteHighlight = [UIImage imageNamed:__kItemViewController_favorite_highlight_img];
//        //关闭滚动条y轴自动下移
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
//    return self;
//}
//#pragma 加载界面入口
//- (void)viewDidLoad {
//    [super viewDidLoad];
//
//    [self setupTopBar];
//    //加载底部工具栏
//    [self setupFootBar];
//    //初始化试题记录
//    _recordService = [[PaperRecordService alloc] init];
//    //加载试题内容
//    [self setupItemContentView];
//}

////加载底部工具栏
//-(void)setupFootBar{
//}
////上一题
//-(void)btnPrevClick:(UIBarButtonItem *)sender{
//    NSLog(@"Prev:%@",sender);
////    if(_itemContentView){
////        _itemContentView.displayAnswer = _displayAnswer;
////        [_itemContentView loadPrevContent];
////        if(_btnFavorite){
////            [_btnFavorite setBackgroundImage:[self loadFavoriteBackgroundImage] forState:UIControlStateNormal];
////        }
////    }
//}
////下一题
//-(void)btnNextClick:(UIBarButtonItem *)sender{
//    NSLog(@"Next:%@",sender);
////    if(_itemContentView){
////        _itemContentView.displayAnswer = _displayAnswer;
////        [_itemContentView loadNextContent];
////        if(_btnFavorite){
////            [_btnFavorite setBackgroundImage:[self loadFavoriteBackgroundImage] forState:UIControlStateNormal];
////        }
////    }
//}
////加载试题内容
//-(void)setupItemContentView{
////    CGRect itemFrame = [self loadVisibleViewFrame];
////    _itemContentView = [[ItemContentGroupView alloc] initWithFrame:itemFrame Order:_order];
////    _itemContentView.displayAnswer = _displayAnswer;
////    _itemContentView.dataSource = self;
////    [_itemContentView loadContent];
////    [self.view addSubview:_itemContentView];
//    //开始时间
//    _startTime = [NSDate date];
//}
//#pragma mark ItemContentGroupViewDataSource
////加载数据
//-(ItemContentSource *)itemContentAtOrder:(NSInteger)order{
//    NSLog(@"加载数据...%ld",(long)order);
//    if(index < 0 || !_review)return nil;
//    __block ItemContentSource *source;
////    [_review loadItemAtOrder:order ItemBlock:^(PaperItemOrderIndexPath *indexPath) {
////        if(indexPath){
////            self.navigationItem.title = indexPath.structureTitle;
////            
////            NSString *answer = nil;
////            if(_record && _record.code && _record.code.length > 0){
////                answer = [_recordService loadAnswerRecordWithPaperRecordCode:_record.code
////                                                                    ItemCode:indexPath.item.code
////                                                                     atIndex:indexPath.index];
////            }
////            source = [ItemContentSource itemContentStructureCode:indexPath.structureCode
////                                                          Source:indexPath.item
////                                                           Index:indexPath.index
////                                                           Order:indexPath.order
////                                                   SelectedValue:answer];
////        }
////    }];
//    return source;
//}
//////选中的答案数据
////-(void)selectedData:(ItemContentSource *)data{
////    if(!_record || !data || !data.source)return;
////    NSNumber *doTime = [self doItemTimeSecondWithStart:_startTime];
////    
////    PaperItemType itemType = (PaperItemType)data.source.type;
////    PaperItemRecord *itemRecord = [_recordService loadRecordAndNewWithPaperRecordCode:_record.code
////                                                                             ItemCode:data.source.code
////                                                                              atIndex:data.index];
////    if(itemRecord){
////        itemRecord.structureCode = data.structureCode;
////        itemRecord.itemType = [NSNumber numberWithInt:(int)itemType];
////        itemRecord.itemContent = [data.source serialize];
////        itemRecord.answer = data.value;
////        itemRecord.useTimes = doTime;
////        NSString *rightAnswer = data.source.answer;
////        if(itemType == PaperItemTypeShareTitle){//共享题干题
////            if(data.source.children && data.source.children.count > 0 && data.index < data.source.children.count){
////                PaperItem *child = [data.source.children objectAtIndex:data.index];
////                if(child){
////                    itemType = (PaperItemType)child.type;
////                    rightAnswer = child.answer;
////                }
////            }
////        }else if(itemType == PaperItemTypeShareAnswer){//共享答案题
////            NSInteger count = 0;
////            if(data.source.children && (count = data.source.children.count) > 0){
////                PaperItem *item = [data.source.children objectAtIndex:(count - 1)];
////                if(item && item.children && item.children.count > 0 && data.index < item.children.count){
////                    PaperItem *child = [item.children objectAtIndex:data.index];
////                    if(child){
////                        itemType = (PaperItemType)child.type;
////                        rightAnswer = child.answer;
////                    }
////                }
////            }
////        }
////        //判断答案是否正确
////        if(rightAnswer){
////            itemRecord.status = [NSNumber numberWithBool:([rightAnswer isEqualToString:data.value])];
////        }
////        //计算得分
////        if(_review && rightAnswer && rightAnswer.length > 0){
////            [_review findStructureAtStructureCode:itemRecord.structureCode StructureBlock:^(PaperStructure *ps) {
////                if(!ps)return;
////                //NSLog(@"%@,%@,%@",ps.code,ps.score,ps.min);
////                
////                if(itemRecord.status == [NSNumber numberWithBool:YES]){
////                    if(ps.score){
////                        itemRecord.score = ps.score;
////                    }
////                }else if(ps.min && ps.min.floatValue > 0 && data.value && data.value.length > 0){
////                    NSArray *arrays = [data.value componentsSeparatedByString:@","];
////                    if(arrays && arrays.count > 0){
////                        for(NSString *str in arrays){
////                            if(!str || str.length == 0)continue;
////                            if([NSStringUtils existContains:rightAnswer subText:str]){
////                                itemRecord.score = ps.min;
////                                break;
////                            }
////                        }
////                    }
////                }
////            }];
////        }
////        //更新数据
////        if(_recordService){
////            [_recordService subjectWithItemRecord:itemRecord];
////        }
////    }
////    NSLog(@"selectedData:%@ === %@",data.value, doTime);
////    
////    //重置开始时间
////    _startTime = [NSDate date];
////    //下一题
////    if(itemType == PaperItemTypeSingle || itemType == PaperItemTypeJudge){
////        [self btnNextClick:nil];
////    }
////}
////做题时间计算
//-(NSNumber *)doItemTimeSecondWithStart:(NSDate *)startTime{
//    NSNumber *second = [NSNumber numberWithDouble:0];
//    if(startTime){
//        NSTimeInterval timeInterval = [startTime timeIntervalSinceNow];
//        if(timeInterval < 0){
//            timeInterval = -timeInterval;
//        }
//        second = [NSNumber numberWithDouble:timeInterval];
//    }
//    return second;
//}
////交卷
//-(void)btnSubmitClick:(UIBarButtonItem *)sender{
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:__kItemViewController_submit_alert
//                                                   message:__kItemViewController_submit_alert_msg
//                                                  delegate:self
//                                         cancelButtonTitle:__kItemViewController_alert_btn_cancel
//                                         otherButtonTitles:__kItemViewController_alert_btn_submit, nil];
//    alert.tag = __kItemViewController_toolbar_submitTag;
//    [alert show];
//}
////交卷处理
//-(void)submitHandler{
////    if(_itemContentView){
////        [_itemContentView submit];
////    }
////    if(_recordService && _record && _timerView){
////        _record.useTimes = [_timerView stop];
////        [_recordService subjectWithPaperRecord:_record];
////    }
////    //查看结果
////    ResultViewController *rvc = [[ResultViewController alloc] initWithPaper:_review andRecord:_record];
////    rvc.hidesBottomBarWhenPushed = YES;
////    [self.navigationController pushViewController:rvc animated:NO];
//}
//#pragma mark 加载数据
//-(void)loadDataAtOrder:(NSInteger)order andDisplayAnswer:(BOOL)displayAnswer{
////    if(order < 0 || !_itemContentView)return;
////     _order = order;
////    _displayAnswer = displayAnswer;
////    //
////    _itemContentView.displayAnswer = _displayAnswer = displayAnswer;
////    [_itemContentView loadContentAtOrder:order];
////    //重置开始时间
////    _startTime = [NSDate date];
//}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
