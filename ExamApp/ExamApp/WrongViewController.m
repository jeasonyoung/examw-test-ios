//
//  WrongViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "WrongViewController.h"

#import "UIColor+Hex.h"
#import "UIViewController+VisibleView.h"

#import "UIViewUtils.h"
#import "ItemContentPanel.h"

#import "WrongItemRecordService.h"
#import "PaperItemRecord.h"
#import "PaperReview.h"

#import "WrongSheetViewController.h"

#define __kWrongViewController_btnAnswerWith 50//
#define __kWrongViewController_btnAnswerHeight 22//
#define __kWrongViewController_btnAnswerFontSize 12//
#define __kWrongViewController_btnAnswerText @"答案"
#define __kWrongViewController_btnAnswerNormalColor 0x00868B
#define __kWrongViewController_btnAnswerHighlightColor 0x00CD66
#define __kWrongViewController_btnAnswerBorderColor 0x00C5CD

//错题重做视图控制器成员变量
@interface WrongViewController ()<ItemContentPanelDelegate>{
    NSString *_subjectCode;
    BOOL _displayAnswer;
    NSUInteger _order,_total,_itemIndex;
    WrongItemRecordService *_service;
    PaperItemRecord *_itemRecord;
    ItemContentPanel *_itemContentPanel;
    NSMutableDictionary *_itemAnswersCache;
}
@end
//错题重做视图控制器实现
@implementation WrongViewController
#pragma mark 初始化重载
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
    _service = [[WrongItemRecordService alloc]init];
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
    UIBarButtonItem *btnBarRight = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                target:self
                                                                                action:@selector(btnBarRightClick:)];
    self.navigationItem.rightBarButtonItem = btnBarRight;
}
//答题卡按钮
-(void)btnBarRightClick:(UIBarButtonItem *)sender{
    //答题卡按钮
    WrongSheetViewController *wsvc = [[WrongSheetViewController alloc] initWithSubjectCode:_subjectCode
                                                                                andAnswers:_itemAnswersCache];
    wsvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:wsvc animated:NO];
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
    btnAnswer.frame = CGRectMake(0, 0, __kWrongViewController_btnAnswerWith, __kWrongViewController_btnAnswerHeight);
    btnAnswer.titleLabel.font = [UIFont systemFontOfSize:__kWrongViewController_btnAnswerFontSize];
    [btnAnswer setTitle:__kWrongViewController_btnAnswerText forState:UIControlStateNormal];
    [btnAnswer setTitleColor:[UIColor colorWithHex:__kWrongViewController_btnAnswerNormalColor] forState:UIControlStateNormal];
    [btnAnswer setTitleColor:[UIColor colorWithHex:__kWrongViewController_btnAnswerHighlightColor] forState:UIControlStateHighlighted];
    [btnAnswer addTarget:self action:@selector(btnAnswerClick:) forControlEvents:UIControlEventTouchUpInside];
    [UIViewUtils addBoundsRadiusWithView:btnAnswer BorderColor:[UIColor colorWithHex:__kWrongViewController_btnAnswerBorderColor] BackgroundColor:nil];
    UIBarButtonItem *btnBarAnswer = [[UIBarButtonItem alloc]initWithCustomView:btnAnswer];
    //设置底部工具栏
    [self setToolbarItems:@[btnBarPrev,space,space,btnBarAnswer,space,btnBarNext]];
}
//上一题按钮
-(void)btnBarPrevClick:(UIBarButtonItem *)sender{
    if(_total == 0 || _order == 0)return;
    _order--;
    if(_order <= 0){
        _order = 0;
    }
    [_itemContentPanel loadDataAtOrder:_order];
}
//下一题按钮
-(void)btnBarNextClick:(UIBarButtonItem *)sender{
    if(_total == 0 || _order == _total - 1)return;
    _order++;
    if(_order > _total - 1){
        _order = _total - 1;
    }
    [_itemContentPanel loadDataAtOrder:_order];
}
//答案按钮
-(void)btnAnswerClick:(UIButton *)sender{
    _displayAnswer = !_displayAnswer;
    //加载数据
    [_itemContentPanel loadDataAtOrder:_order];
}
#pragma mark 加载数据
-(void)loadDataAtOrder:(NSInteger)order{
    _total = [_service loadWrongsWithSubjectCode:_subjectCode];
    if(_total <= 0){
        return;
    }
    _order = order;
    //加载数据
    [_itemContentPanel loadDataAtOrder:_order];
}
#pragma mark ItemContentPanelDelegate
//总数
-(NSUInteger)numbersOfItemContentPanel{
    return _total;
}
//加载数据
-(PaperItem *)dataWithItemView:(ItemView *)itemView atOrder:(NSUInteger)order{
    _order = order;
    _itemIndex = 0;
    if(_service){
        _itemRecord = [_service loadWrongWithSubjectCode:_subjectCode AtOrder:order];
        if(_itemRecord && _itemRecord.itemContent && _itemRecord.itemContent.length > 0){
            //试题索引
            if(_itemRecord.itemType && ((_itemRecord.itemType.integerValue == (NSUInteger)PaperItemTypeShareTitle) ||
               (_itemRecord.itemType.integerValue == (NSUInteger)PaperItemTypeShareAnswer))){
                NSArray *arrays = [_itemRecord.code componentsSeparatedByString:@"$"];
                if(arrays){
                    _itemIndex = [[arrays lastObject] integerValue];
                }
            }
            return [[PaperItem alloc] initWithJSON:_itemRecord.itemContent];
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
    return (_itemRecord ? _itemRecord.answer : @"");
}
//是否显示答案
-(BOOL)displayAnswerWithItemView:(ItemView *)itemView atOrder:(NSUInteger)order{
    return _displayAnswer;
}
//选中
-(void)itemView:(ItemView *)itemView didSelectAtSelected:(ItemViewSelected *)selected atOrder:(NSUInteger)order{
    if(!_itemAnswersCache){
        _itemAnswersCache = [NSMutableDictionary dictionary];
    }
    //加入缓存
    [_itemAnswersCache setObject:selected.selectedCode forKey:[NSNumber numberWithInteger:order]];
    //
    _displayAnswer = YES;
    //重新加载数据
    [_itemContentPanel loadDataAtOrder:order];
}
#pragma mark 视图将呈现
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _displayAnswer = NO;
    self.navigationController.toolbarHidden = NO;
}
#pragma mark 视图将隐藏
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
