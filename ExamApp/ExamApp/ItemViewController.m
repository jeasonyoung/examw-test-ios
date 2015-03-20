//
//  ItemViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ItemViewController.h"
#import "UIViewController+VisibleView.h"

#import "PaperReview.h"
#import "PaperRecord.h"
#import "PaperItemRecord.h"
#import "PaperRecordService.h"

#import "ETAlert.h"

#import "UIColor+Hex.h"
#import "NSString+Size.h"

#import "ETTimerView.h"

#import "AnswersheetViewController.h"
#import "PaperListViewController.h"
#import "ResultViewController.h"

#import "ItemContentView.h"
#import "ItemContentGroupView.h"

#import "UIViewUtils.h"

#define __k_itemviewcontroller_left_alert_title @"退出"//
#define __k_itemviewcontroller_left_alert_msg @"是否退出考试?"
#define __k_itemviewcontroller_left_alert_btn_submit @"交卷"
#define __k_itemviewcontroller_left_alert_btn_confirm @"下次再做"
#define __k_itemviewcontroller_left_alert_btn_cancel @"取消"

#define __k_itemviewcontroller_favorite_with 30//收藏宽度
#define __k_itemviewcontroller_favorite_height 30//收藏高度
#define __k_itemviewcontroller_favorite_bgColor 0xCCCCCC//收藏的背景色
#define __k_itemviewcontroller_favorite_normal_img @"favorite_normal.png"//未被收藏
#define __k_itemviewcontroller_favorite_highlight_img @"favorite_highlight.png"//已被收藏

#define __k_itemviewcontroller_timer_with 80//计时器宽度
#define __k_itemviewcontroller_timer_height 30//计时器高度

#define __k_itemviewcontroller_submit_title @"交卷"//交卷

//试题考试视图控制器成员变量
@interface ItemViewController ()<ItemContentGroupViewDataSource>{
    NSDate *_startTime;
    NSInteger _order;
    UIButton *_btnFavorite;
    UIImage *_imgFavoriteNormal,*_imgFavoriteHighlight;
    
    PaperReview *_review;
    PaperRecord *_record;
    
    ItemContentGroupView *_itemContentView;
    ETTimerView *_timerView;
    
    PaperRecordService *_recordService;
    
    BOOL _displayAnswer;
}
@end
//试题考试视图控制器实现
@implementation ItemViewController
#pragma mark 初始化
-(instancetype)initWithPaper:(PaperReview *)review
                       Order:(NSInteger)order
                   andRecord:(PaperRecord *)record
            andDisplayAnswer:(BOOL)displayAnswer{
    if(self = [super init]){
        _review = review;
        _order = order;
        _record = record;
        _displayAnswer = displayAnswer;
        
        _imgFavoriteNormal = [UIImage imageNamed:__k_itemviewcontroller_favorite_normal_img];
        _imgFavoriteHighlight = [UIImage imageNamed:__k_itemviewcontroller_favorite_highlight_img];
        //关闭滚动条y轴自动下移
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}
#pragma mark 初始化
-(instancetype)initWithPaper:(PaperReview *)review
                   andRecord:(PaperRecord *)record
            andDisplayAnswer:(BOOL)displayAnswer{
    return [self initWithPaper:review Order:0 andRecord:record andDisplayAnswer:displayAnswer];
}
#pragma 加载界面入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //加载顶部工具栏
    [self setupTopBar];
    //加载底部工具栏
    [self setupFootBar];
    //初始化试题记录
    _recordService = [[PaperRecordService alloc] init];
    //加载试题内容
    [self setupItemContentView];
}
#pragma mark 视图将呈现
-(void)viewWillAppear:(BOOL)animated{
    //显示底部工具栏
    self.navigationController.toolbarHidden = NO;
}
//加载顶部工具栏
-(void)setupTopBar{
    //加载顶部标题内容xx
    //self.navigationItem.title = @"一、单项选择题单项选择题单项选择题单项选择题单项选择题";
    //左边按钮
    UIBarButtonItem *btnLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                                             target:self
                                                                             action:@selector(topLeftBarButtonClick:)];
    self.navigationItem.leftBarButtonItem = btnLeft;
    //右边按钮
    UIBarButtonItem *btnRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                              target:self
                                                                              action:@selector(topRightBarButtonClick:)];
    self.navigationItem.rightBarButtonItem = btnRight;
}
//左边返回按钮
-(void)topLeftBarButtonClick:(UIBarButtonItem *)sender{
    ETAlert *alert = [[ETAlert alloc] initWithTitle:__k_itemviewcontroller_left_alert_title
                                            Message:__k_itemviewcontroller_left_alert_msg];
    if(_displayAnswer){
        [alert addConfirmActionWithTitle:__k_itemviewcontroller_left_alert_btn_submit Handler:^(UIAlertAction *action) {
            NSLog(@"交卷");
            [self btnSubmitClick:nil];
        }];
        [alert addConfirmActionWithTitle:__k_itemviewcontroller_left_alert_btn_confirm Handler:^(UIAlertAction *action) {
            NSLog(@"下次再做");
            [self popViewController];
        }];
    }
    [alert addCancelActionWithTitle:__k_itemviewcontroller_left_alert_btn_cancel Handler:nil];
    [alert showWithController:self];
}
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
        }
    }
}
//答题卡按钮事件
-(void)topRightBarButtonClick:(UIBarButtonItem *)sender{
    //NSLog(@"right_bar_click:%@",sender);
    //隐藏状态栏
    self.navigationController.toolbarHidden = YES;
    AnswersheetViewController *avc = [[AnswersheetViewController alloc] initWithPaperReview:_review PaperRecord:_record];
    avc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:avc animated:NO];
}
//加载底部工具栏
-(void)setupFootBar{
    //上一题
    UIBarButtonItem *btnPrev = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                                             target:self
                                                                             action:@selector(btnPrevClick:)];
    //下一题
    UIBarButtonItem *btnNext = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                                                             target:self
                                                                             action:@selector(btnNextClick:)];
    //填充
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:self
                                                                           action:nil];
    //收藏按钮
    _btnFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnFavorite.frame = CGRectMake(0, 0, __k_itemviewcontroller_favorite_with, __k_itemviewcontroller_favorite_height);
    UIColor *favColor = [UIColor colorWithHex:__k_itemviewcontroller_favorite_bgColor];
    [UIViewUtils addBoundsRadiusWithView:_btnFavorite BorderColor:favColor BackgroundColor:favColor];
    [_btnFavorite setBackgroundImage:[self loadFavoriteBackgroundImage] forState:UIControlStateNormal];
    [_btnFavorite addTarget:self action:@selector(btnFavoriteClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnFavoriteItem = [[UIBarButtonItem alloc] initWithCustomView:_btnFavorite];
    //倒计时器
    _timerView = [[ETTimerView alloc] initWithFrame:CGRectMake(0, 0, __k_itemviewcontroller_timer_with, __k_itemviewcontroller_timer_height)
                                              Total:_review.time];
    UIBarButtonItem *btnTimer = [[UIBarButtonItem alloc] initWithCustomView:_timerView];
    //交卷
    UIBarButtonItem *btnSubmit = [[UIBarButtonItem alloc] initWithTitle:__k_itemviewcontroller_submit_title
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(btnSubmitClick:)];
    [self setToolbarItems:@[btnPrev,space,btnFavoriteItem,space,btnTimer,space,btnSubmit,space,btnNext]
                 animated:YES];
}
//上一题
-(void)btnPrevClick:(UIBarButtonItem *)sender{
    NSLog(@"Prev:%@",sender);
    if(_itemContentView){
        _itemContentView.displayAnswer = _displayAnswer;
        [_itemContentView loadPrevContent];
        if(_btnFavorite){
            [_btnFavorite setBackgroundImage:[self loadFavoriteBackgroundImage] forState:UIControlStateNormal];
        }
    }
}
//下一题
-(void)btnNextClick:(UIBarButtonItem *)sender{
    NSLog(@"Next:%@",sender);
    if(_itemContentView){
        _itemContentView.displayAnswer = _displayAnswer;
        [_itemContentView loadNextContent];
        if(_btnFavorite){
            [_btnFavorite setBackgroundImage:[self loadFavoriteBackgroundImage] forState:UIControlStateNormal];
        }
    }
}
//加载试题内容
-(void)setupItemContentView{
    CGRect itemFrame = [self loadVisibleViewFrame];
    _itemContentView = [[ItemContentGroupView alloc] initWithFrame:itemFrame Order:_order];
    _itemContentView.displayAnswer = _displayAnswer;
    _itemContentView.dataSource = self;
    [_itemContentView loadContent];
    [self.view addSubview:_itemContentView];
    //开始时间
    _startTime = [NSDate date];
}
#pragma mark ItemContentGroupViewDataSource
//加载数据
-(ItemContentSource *)itemContentAtIndex:(NSInteger)index{
    NSLog(@"加载数据...%ld",(long)index);
    if(index < 0 || !_review)return nil;
    __block ItemContentSource *source;
    [_review loadItemAtOrder:index ItemBlock:^(PaperItemOrderIndexPath *indexPath) {
        if(indexPath){
            self.navigationItem.title = indexPath.structureTitle;
            
            NSString *answer = nil;
            if(_record && _record.code && _record.code.length > 0){
                answer = [_recordService loadAnswerRecordWithPaperRecordCode:_record.code
                                                                    ItemCode:indexPath.item.code
                                                                     atIndex:indexPath.index];
            }
            source = [ItemContentSource itemContentStructureCode:indexPath.structureCode
                                                          Source:indexPath.item
                                                           Index:indexPath.index
                                                           Order:indexPath.order
                                                   SelectedValue:answer];
        }
    }];
    return source;
}
//选中的答案数据
-(void)selectedData:(ItemContentSource *)data{
    if(!_record || !data || !data.source)return;
    NSNumber *doTime = [self doItemTimeSecondWithStart:_startTime];
    
    PaperItemType itemType = (PaperItemType)data.source.type;
    PaperItemRecord *itemRecord = [_recordService loadRecordAndNewWithPaperRecordCode:_record.code
                                                                             ItemCode:data.source.code
                                                                              atIndex:data.index];
    if(itemRecord){
        itemRecord.structureCode = data.structureCode;
        itemRecord.itemContent = [data.source serialize];
        itemRecord.answer = data.value;
        itemRecord.useTimes = doTime;
        NSString *rightAnswer = data.source.answer;
        if(itemType == PaperItemTypeShareTitle){//共享题干题
            if(data.source.children && data.source.children.count > 0 && data.index < data.source.children.count){
                PaperItem *child = [data.source.children objectAtIndex:data.index];
                if(child){
                    itemType = (PaperItemType)child.type;
                    rightAnswer = child.answer;
                }
            }
        }else if(itemType == PaperItemTypeShareAnswer){//共享答案题
            NSInteger count = 0;
            if(data.source.children && (count = data.source.children.count) > 0){
                PaperItem *item = [data.source.children objectAtIndex:(count - 1)];
                if(item && item.children && item.children.count > 0 && data.index < item.children.count){
                    PaperItem *child = [item.children objectAtIndex:data.index];
                    if(child){
                        itemType = (PaperItemType)child.type;
                        rightAnswer = child.answer;
                    }
                }
            }
        }
        //判断答案是否正确
        if(rightAnswer){
            itemRecord.status = [NSNumber numberWithBool:([rightAnswer isEqualToString:data.value])];
        }
        //计算得分
        if(_review && rightAnswer && rightAnswer.length > 0){
            [_review findStructureAtStructureCode:itemRecord.structureCode StructureBlock:^(PaperStructure *ps) {
                if(!ps)return;
                //NSLog(@"%@,%@,%@",ps.code,ps.score,ps.min);
                
                if(itemRecord.status == [NSNumber numberWithBool:YES]){
                    if(ps.score){
                        itemRecord.score = ps.score;
                    }
                }else if(ps.min && ps.min.floatValue > 0 && data.value && data.value.length > 0){
                    NSArray *arrays = [data.value componentsSeparatedByString:@","];
                    if(arrays && arrays.count > 0){
                        for(NSString *str in arrays){
                            if(!str || str.length == 0)continue;
                            if([rightAnswer containsString:str]){
                                itemRecord.score = ps.min;
                                break;
                            }
                        }
                    }
                }
            }];
        }
        //更新数据
        if(_recordService){
            [_recordService subjectWithItemRecord:itemRecord];
        }
    }
    NSLog(@"selectedData:%@ === %@",data.value, doTime);
    
    //重置开始时间
    _startTime = [NSDate date];
    //下一题
    if(itemType == PaperItemTypeSingle || itemType == PaperItemTypeJudge){
        [self btnNextClick:nil];
    }
}
//做题时间计算
-(NSNumber *)doItemTimeSecondWithStart:(NSDate *)startTime{
    NSNumber *second = [NSNumber numberWithDouble:0];
    if(startTime){
        NSTimeInterval timeInterval = [startTime timeIntervalSinceNow];
        if(timeInterval < 0){
            timeInterval = -timeInterval;
        }
        second = [NSNumber numberWithDouble:timeInterval];
    }
    return second;
}
//收藏
-(void)btnFavoriteClick:(UIButton *)sender{
    NSLog(@"Favorite:%@",sender);
    
    if(!_itemContentView)return;
    NSInteger order = _itemContentView.currentOrder;
    
    if([self isFavoriteWithOrder:order]){//如果已收藏则取消收藏
        [self removeFavoriteWithOrder:order];
        [sender setBackgroundImage:_imgFavoriteNormal forState:UIControlStateNormal];
        return;
    }
    //添加到收藏
    [self addFavoriteWithOrder:order];
    [sender setBackgroundImage:_imgFavoriteHighlight forState:UIControlStateNormal];
}
//加载收藏图片
-(UIImage *)loadFavoriteBackgroundImage{
    if(_itemContentView && [self isFavoriteWithOrder:_itemContentView.currentOrder]){
        return _imgFavoriteHighlight;
    }
    return _imgFavoriteNormal;
}
//判断是否收藏
-(BOOL)isFavoriteWithOrder:(NSInteger)order{
    if(_review && _recordService && order >= 0){
        __block BOOL result = NO;
        [_review loadItemAtOrder:order ItemBlock:^(PaperItemOrderIndexPath *indexPath) {
            if(indexPath && indexPath.item){
                result = [_recordService exitFavoriteWithPaperCode:_review.code
                                                          ItemCode:indexPath.item.code
                                                           atIndex:indexPath.index];
                
            }
        }];
        return result;
    }
    return NO;
}
//添加收藏
-(void)addFavoriteWithOrder:(NSInteger)order{
    if(_review && _recordService && order >= 0){
        [_review loadItemAtOrder:order ItemBlock:^(PaperItemOrderIndexPath *indexPath) {
            if(indexPath && indexPath.item){
                [_recordService addFavoriteWithPaperCode:_review.code Data:indexPath];
            }
        }];
    }
}
//移除收藏
-(void)removeFavoriteWithOrder:(NSInteger)order{
    if(_review && _recordService && order >= 0){
        [_review loadItemAtOrder:order ItemBlock:^(PaperItemOrderIndexPath *indexPath) {
            if(indexPath && indexPath.item){
                [_recordService removeFavoriteWithPaperCode:_review.code
                                                   ItemCode:indexPath.item.code
                                                    atIndex:indexPath.index];
            }
        }];
    }
}
//交卷
-(void)btnSubmitClick:(UIBarButtonItem *)sender{
    if(_itemContentView){
        [_itemContentView submit];
    }
    if(_recordService && _record && _timerView){
        _record.useTimes = [_timerView stop];
        [_recordService subjectWithPaperRecord:_record];
    }
    //查看结果
    ResultViewController *rvc = [[ResultViewController alloc] initWithPaper:_review andRecord:_record];
    rvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:rvc animated:NO];
}
#pragma mark 加载数据
-(void)loadDataAtOrder:(NSInteger)order
      andDisplayAnswer:(BOOL)displayAnswer{
    if(order < 0 || !_itemContentView)return;
     _order = order;
    _displayAnswer = displayAnswer;
    //
    _itemContentView.displayAnswer = _displayAnswer = displayAnswer;
    [_itemContentView loadContentAtOrder:order];
    //重置开始时间
    _startTime = [NSDate date];
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
