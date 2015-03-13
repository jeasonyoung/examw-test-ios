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
#import "ETAlert.h"

#import "UIColor+Hex.h"
#import "NSString+Size.h"

#import "ETTimerView.h"

#import "AnswersheetViewController.h"
#import "PaperListViewController.h"

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
    PaperReview *_review;
    NSInteger _order;
    PaperRecord *_record;
    UIImage *_imgFavoriteNormal,*_imgFavoriteHighlight;
    ItemContentGroupView *_itemContentView;
    ETTimerView *_timerView;
}
@end
//试题考试视图控制器实现
@implementation ItemViewController
#pragma mark 初始化
-(instancetype)initWithPaper:(PaperReview *)review Order:(NSInteger)order andRecord:(PaperRecord *)record{
    if(self = [super init]){
        _review = review;
        _order = order;
        _record = record;
        
        _imgFavoriteNormal = [UIImage imageNamed:__k_itemviewcontroller_favorite_normal_img];
        _imgFavoriteHighlight = [UIImage imageNamed:__k_itemviewcontroller_favorite_highlight_img];
        //关闭滚动条y轴自动下移
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}
#pragma mark 初始化
-(instancetype)initWithPaper:(PaperReview *)review andRecord:(PaperRecord *)record{
    return [self initWithPaper:review Order:0 andRecord:record];
}
#pragma 加载界面入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //加载顶部工具栏
    [self setupTopBar];
    //加载底部工具栏
    [self setupFootBar];
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
    self.navigationItem.title = @"一、单项选择题单项选择题单项选择题单项选择题单项选择题";
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
    ETAlert *alert = [[ETAlert alloc] initWithTitle:__k_itemviewcontroller_left_alert_title Message:__k_itemviewcontroller_left_alert_msg];
    [alert addConfirmActionWithTitle:__k_itemviewcontroller_left_alert_btn_submit Handler:^(UIAlertAction *action) {
        NSLog(@"交卷");
    }];
    [alert addConfirmActionWithTitle:__k_itemviewcontroller_left_alert_btn_confirm Handler:^(UIAlertAction *action) {
        NSLog(@"下次再做");
        [self popViewController];
    }];
    [alert addCancelActionWithTitle:__k_itemviewcontroller_left_alert_btn_cancel Handler:nil];
    [alert showWithController:self];
}
-(void)popViewController{
    NSArray *controllers = self.navigationController.viewControllers;
    if(controllers && controllers.count > 0){
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
    UIButton *fav = [UIButton buttonWithType:UIButtonTypeCustom];
    fav.frame = CGRectMake(0, 0, __k_itemviewcontroller_favorite_with, __k_itemviewcontroller_favorite_height);
    UIColor *favColor = [UIColor colorWithHex:__k_itemviewcontroller_favorite_bgColor];
    [UIViewUtils addBoundsRadiusWithView:fav BorderColor:favColor BackgroundColor:favColor];
    [fav setBackgroundImage:[self loadFavoriteBackgroundImage] forState:UIControlStateNormal];
    [fav addTarget:self action:@selector(btnFavoriteClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnFavorite = [[UIBarButtonItem alloc] initWithCustomView:fav];
    //倒计时器
    _timerView = [[ETTimerView alloc] initWithFrame:CGRectMake(0, 0, __k_itemviewcontroller_timer_with, __k_itemviewcontroller_timer_height)
                                              Total:_review.time];
    UIBarButtonItem *btnTimer = [[UIBarButtonItem alloc] initWithCustomView:_timerView];
    //交卷
    UIBarButtonItem *btnSubmit = [[UIBarButtonItem alloc] initWithTitle:__k_itemviewcontroller_submit_title
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(btnSubmitClick:)];
    [self setToolbarItems:@[btnPrev,space,btnFavorite,space,btnTimer,space,btnSubmit,space,btnNext]
                 animated:YES];
}
//上一题
-(void)btnPrevClick:(UIBarButtonItem *)sender{
    NSLog(@"Prev:%@",sender);
    if(_itemContentView){
        [_itemContentView loadPrevContent];
    }
}
//下一题
-(void)btnNextClick:(UIBarButtonItem *)sender{
    NSLog(@"Next:%@",sender);
    if(_itemContentView){
        [_itemContentView loadNextContent];
    }
}
//加载试题内容
-(void)setupItemContentView{
    CGRect itemFrame = [self loadVisibleViewFrame];
    _itemContentView = [[ItemContentGroupView alloc] initWithFrame:itemFrame Order:_order];
    _itemContentView.dataSource = self;
    [_itemContentView loadContent];
    [self.view addSubview:_itemContentView];
}
#pragma mark ItemContentGroupViewDataSource
//加载数据
-(ItemContentSource *)itemContentAtIndex:(NSInteger)index{
    NSLog(@"加载数据...%d",index);
    if(index < 0 || !_review)return nil;
    __block ItemContentSource *source;
    [_review loadItemAtOrder:index ItemBlock:^(PaperItemOrderIndexPath *indexPath) {
        if(indexPath){
            self.navigationItem.title = indexPath.structureTitle;
            source = [ItemContentSource itemContentSource:indexPath.item
                                                    Index:indexPath.index
                                                    Order:indexPath.order + 1];
        }
    }];
    return source;
}
//选中的答案数据
-(void)itemContentWithItemType:(PaperItemType)itemType selectedCode:(NSString *)optCode{
    NSLog(@"itemContentAtSelectedCode:%@",optCode);
    [_itemContentView loadNextContent];
}
//收藏
-(void)btnFavoriteClick:(UIButton *)sender{
    NSLog(@"Favorite:%@",sender);
    NSString *itemCode = @"1231231231";
    if([self isFavoriteWithItemCode:itemCode]){//如果已收藏则取消收藏
        [self removeFavoriteWithItemCode:itemCode];
        [sender setBackgroundImage:_imgFavoriteNormal forState:UIControlStateNormal];
        return;
    }
    //添加到收藏
    [self addFavoriteWithItemCode:itemCode];
    [sender setBackgroundImage:_imgFavoriteHighlight forState:UIControlStateNormal];
}
//加载收藏图片
-(UIImage *)loadFavoriteBackgroundImage{
    NSString *itemCode = @"1231231231";
    if([self isFavoriteWithItemCode:itemCode]){
        return _imgFavoriteHighlight;
    }
    return _imgFavoriteNormal;
}
//判断是否收藏
-(BOOL)isFavoriteWithItemCode:(NSString *)itemCode{
    ///是否已被收藏
    return (arc4random_uniform(10)%2 == 0);
}
//添加收藏
-(void)addFavoriteWithItemCode:(NSString *)itemCode{
    ///TODO:添加到数据库
    
}
-(void)removeFavoriteWithItemCode:(NSString *)itemCode{
    ///TODO:从数据库中移除
    
}
//交卷
-(void)btnSubmitClick:(UIBarButtonItem *)sender{
    
    NSLog(@"submit:%@,useTimes:%d",sender, [NSNumber numberWithInteger:([_timerView stop])].intValue);
}
#pragma mark 加载数据
-(void)loadDataAtOrder:(NSInteger)order{
    if(order < 0 || !_itemContentView)return;
     _order = order;
    [_itemContentView loadContentAtOrder:order];
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
