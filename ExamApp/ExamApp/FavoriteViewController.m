//
//  FavoriteViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "FavoriteViewController.h"

#import "UIColor+Hex.h"
#import "UIViewController+VisibleView.h"

#import "UIViewUtils.h"

#import "ItemContentPanel.h"

#import "FavoriteSheetViewController.h"

#import "FavoriteService.h"
#import "PaperItemFavorite.h"

#import "PaperReview.h"

#define __kFavoriteViewController_btnAnswerWith 50//
#define __kFavoriteViewController_btnAnswerHeight 22//
#define __kFavoriteViewController_btnAnswerFontSize 12//
#define __kFavoriteViewController_btnAnswerText @"答案"
#define __kFavoriteViewController_btnAnswerNormalColor 0x00868B
#define __kFavoriteViewController_btnAnswerHighlightColor 0x00CD66
#define __kFavoriteViewController_btnAnswerBorderColor 0x00C5CD
//收藏试题控制器成员变量
@interface FavoriteViewController ()<ItemContentPanelDelegate>{
    NSString *_subjectCode;
    BOOL _displayAnswer;
    
    NSUInteger _order,_totals,_itemIndex;
    
    FavoriteService *_service;
    
    ItemContentPanel *_itemContentPanel;
    
    NSMutableDictionary *_itemAnswersCache;
}
@end
//收藏试题控制器实现
@implementation FavoriteViewController
#pragma mark 初始化
-(instancetype)initWithSubjectCode:(NSString *)subjectCode{
    if(self = [super init]){
        _subjectCode = subjectCode;
    }
    return self;
}
#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //关闭滚动条y轴自动下移
    self.automaticallyAdjustsScrollViewInsets = NO;
    //加载顶部工具栏
    [self setupTopbar];
    //加载底部工具栏
    [self setupFootbar];
    //初始化收藏数据服务
    _service = [[FavoriteService alloc]init];
    _displayAnswer = NO;
    _itemAnswersCache = [NSMutableDictionary dictionary];
    //加载试题内容
    _itemContentPanel = [[ItemContentPanel alloc]initWithFrame:[self loadVisibleViewFrame]];
    _itemContentPanel.delegate = self;
    [self.view addSubview:_itemContentPanel];
    //加载数据
    [self loadDataAtOrder:0];
}
//加载顶部工具栏
-(void)setupTopbar{
    //右边按钮
    UIBarButtonItem *btnBarRight = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                             target:self
                                                                             action:@selector(btnBarRightClick:)];
    self.navigationItem.rightBarButtonItem = btnBarRight;
}
//答题卡按钮
-(void)btnBarRightClick:(UIBarButtonItem *)sender{
    //NSLog(@"%@",sender);
    FavoriteSheetViewController *fsvc = [[FavoriteSheetViewController alloc] initWithSubjectCode:_subjectCode
                                                                                      andAnswers:_itemAnswersCache];
    fsvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:fsvc animated:NO];
}
//加载底部工具栏
-(void)setupFootbar{
    //上一题
    UIBarButtonItem *btnBarPrev = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                                               target:self
                                                                               action:@selector(btnBarPrevClick:)];
    //下一题
    UIBarButtonItem *btnBarNext = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                                                               target:self
                                                                               action:@selector(btnBarNextClick:)];
    //填充
    UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:self action:nil];
    //答案
    UIButton *btnAnswer = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAnswer.frame = CGRectMake(0, 0, __kFavoriteViewController_btnAnswerWith, __kFavoriteViewController_btnAnswerHeight);
    btnAnswer.titleLabel.font = [UIFont systemFontOfSize:__kFavoriteViewController_btnAnswerFontSize];
    [btnAnswer setTitle:__kFavoriteViewController_btnAnswerText forState:UIControlStateNormal];
    [btnAnswer setTitleColor:[UIColor colorWithHex:__kFavoriteViewController_btnAnswerNormalColor] forState:UIControlStateNormal];
    [btnAnswer setTitleColor:[UIColor colorWithHex:__kFavoriteViewController_btnAnswerHighlightColor] forState:UIControlStateHighlighted];
    [btnAnswer addTarget:self action:@selector(btnAnswerClick:) forControlEvents:UIControlEventTouchUpInside];
    [UIViewUtils addBoundsRadiusWithView:btnAnswer BorderColor:[UIColor colorWithHex:__kFavoriteViewController_btnAnswerBorderColor] BackgroundColor:nil];
    UIBarButtonItem *btnBarAnswer = [[UIBarButtonItem alloc]initWithCustomView:btnAnswer];
    //设置底部工具栏
    [self setToolbarItems:@[btnBarPrev,space,space,btnBarAnswer,space,btnBarNext]];
}
//上一题按钮
-(void)btnBarPrevClick:(UIBarButtonItem *)sender{
    if(_totals == 0 || _order == 0)return;
    _order--;
    if(_order <= 0){
        _order = 0;
    }
    [_itemContentPanel loadDataAtOrder:_order];
}
//下一题按钮
-(void)btnBarNextClick:(UIBarButtonItem *)sender{
    if(_totals == 0 || _order == _totals - 1)return;
    _order++;
    if(_order > _totals - 1){
        _order = _totals - 1;
    }
    [_itemContentPanel loadDataAtOrder:_order];
}
//答案按钮
-(void)btnAnswerClick:(UIButton *)sender{
    _displayAnswer = !_displayAnswer;
    [_itemContentPanel loadDataAtOrder:_order];
}
#pragma mark 加载数据
-(void)loadDataAtOrder:(NSInteger)order{
    _totals = [_service loadFavoritesWithSubjectCode:_subjectCode];
    if(_totals == 0)return;
    _order = order;
    if(_order <= 0){
        _order = 0;
    }else if(_order > _totals - 1){
        _order = _totals - 1;
    }
    //加载数据
    [_itemContentPanel loadDataAtOrder:_order];
}
#pragma mark ItemContentPanelDelegate
//总数
-(NSUInteger)numbersOfItemContentPanel{
    return _totals;
}
//加载数据
-(PaperItem *)dataWithItemView:(ItemView *)itemView atOrder:(NSUInteger)order{
    _order = order;
    _itemIndex = 0;
    if(_service && _subjectCode && _subjectCode.length > 0){
        PaperItemFavorite *favorite = [_service loadFavoriteWithSubjectCode:_subjectCode AtOrder:order];
        if(favorite && favorite.itemContent && favorite.itemContent.length > 0){
            //试题索引
            if(favorite.itemType && ((favorite.itemType.integerValue == (NSUInteger)PaperItemTypeShareTitle) ||
                                        (favorite.itemType.integerValue == (NSUInteger)PaperItemTypeShareAnswer))){
                NSArray *arrays = [favorite.code componentsSeparatedByString:@"$"];
                if(arrays){
                    _itemIndex = [[arrays lastObject] integerValue];
                }
            }
            return [[PaperItem alloc] initWithJSON:favorite.itemContent];
        }
    }
    return nil;
}
//加载试题索引
-(NSUInteger)itemIndexWithItemView:(ItemView *)itemView atOrder:(NSUInteger)order{
    return _itemIndex;
}
//加载答案
-(NSString *)answerWithItemView:(ItemView *)itemView atOrder:(NSUInteger)order atIndex:(NSUInteger)index{
    if(_itemAnswersCache && _itemAnswersCache.count > 0){
        NSString *answer = [_itemAnswersCache objectForKey:[NSNumber numberWithInteger:order]];
        if(answer && answer.length > 0){
            return answer;
        }
    }
    return nil;
}
//是否显示答案
-(BOOL)displayAnswerWithItemView:(ItemView *)itemView atOrder:(NSUInteger)order{
    return _displayAnswer;
}
//选中答案
-(void)itemView:(ItemView *)itemView didSelectAtSelected:(ItemViewSelected *)selected atOrder:(NSUInteger)order{
     _displayAnswer = YES;
    if(!_itemAnswersCache){
        _itemAnswersCache = [NSMutableDictionary dictionary];
    }
    //缓存答案
    [_itemAnswersCache setObject:selected.selectedCode forKey:[NSNumber numberWithInteger:order]];
    //加载数据
    [_itemContentPanel loadDataAtOrder:order];
}
#pragma mark 试图将呈现
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _displayAnswer = NO;
    self.navigationController.toolbarHidden = NO;
}
#pragma mark 试图将隐藏
-(void)viewWillDisappear:(BOOL)animated{
    _displayAnswer = NO;
    self.navigationController.toolbarHidden = YES;
    [super viewWillDisappear:animated];
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(_itemAnswersCache && _itemAnswersCache.count > 0){
        [_itemAnswersCache removeAllObjects];
    }
}
@end
