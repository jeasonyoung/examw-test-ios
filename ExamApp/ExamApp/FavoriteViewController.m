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

#import "ItemContentGroupView.h"

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
@interface FavoriteViewController ()<ItemContentGroupViewDataSource>{
    NSString *_subjectCode;
    BOOL _displayAnswer;
    FavoriteService *_service;
    ItemContentGroupView *_itemContentView;
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
    [self setupItemContentView];
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
    //NSLog(@"%@",sender);
    if(_itemContentView){
        [_itemContentView loadPrevContent];
    }
}
//下一题按钮
-(void)btnBarNextClick:(UIBarButtonItem *)sender{
    //NSLog(@"%@",sender);
    if(_itemContentView){
        [_itemContentView loadNextContent];
    }
}
//答案按钮
-(void)btnAnswerClick:(UIButton *)sender{
    _displayAnswer = !_displayAnswer;
     //NSLog(@"%d",_displayAnswer);
    if(_itemContentView){
        [_itemContentView showDisplayAnswer:_displayAnswer];
    }
}
//加载试题内容
-(void)setupItemContentView{
    CGRect itemFrame = [self loadVisibleViewFrame];
    _itemContentView = [[ItemContentGroupView alloc]initWithFrame:itemFrame];
    _itemContentView.dataSource = self;
    [self.view addSubview:_itemContentView];
    //加载数据
    [self loadDataAtOrder:0];
}
#pragma mark 加载数据
-(void)loadDataAtOrder:(NSInteger)order{
    if(_itemContentView){
        [_itemContentView loadContentAtOrder:order];
    }
}
#pragma mark ItemContentGroupViewDataSource
//加载数据
-(ItemContentSource *)itemContentAtOrder:(NSInteger)order{
    if(_service){
        PaperItemFavorite *favorite = [_service loadFavoriteWithSubjectCode:_subjectCode AtOrder:order];
        if(favorite){
            if(favorite.itemType){
                self.title = [PaperItem itemTypeName:(PaperItemType)favorite.itemType.integerValue];
            }
            ItemContentSource *dataSource = [favorite toSourceAtOrder:order];
            if(_displayAnswer && _itemAnswersCache && _itemAnswersCache.count > 0){
                NSString *answer = [_itemAnswersCache valueForKey:[NSString stringWithFormat:@"%ld",(long)order]];
                if(answer && answer.length > 0){
                    dataSource.value = answer;
                }
            }
           return dataSource;
        }
    }
    return nil;
}
//选中的数据
-(void)selectedData:(ItemContentSource *)data{
    NSLog(@"selectedData:%@,%@",data,data.value);
    if(!data || !_itemContentView)return;
    _displayAnswer = YES;
    [_itemAnswersCache setValue:data.value forKey:[NSString stringWithFormat:@"%ld", (long)data.order]];
    [_itemContentView loadContentAtOrder:data.order];
    [_itemContentView showDisplayAnswer:_displayAnswer];
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
}
@end
