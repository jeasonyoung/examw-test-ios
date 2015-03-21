//
//  FavoriteViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "FavoriteViewController.h"

#import "UIColor+Hex.h"

#import "UIViewUtils.h"

#import "FavoriteSheetViewController.h"

#define __kFavoriteViewController_btnAnswerWith 50//
#define __kFavoriteViewController_btnAnswerHeight 22//
#define __kFavoriteViewController_btnAnswerFontSize 12//
#define __kFavoriteViewController_btnAnswerText @"答案"
#define __kFavoriteViewController_btnAnswerNormalColor 0x00868B
#define __kFavoriteViewController_btnAnswerHighlightColor 0x00CD66
#define __kFavoriteViewController_btnAnswerBorderColor 0x00C5CD
//收藏试题控制器成员变量
@interface FavoriteViewController (){
    NSString *_subjectCode;
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
    //加载顶部工具栏
    [self setupTopbar];
    //加载底部工具栏
    [self setupFootbar];
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
    FavoriteSheetViewController *fsvc = [[FavoriteSheetViewController alloc] initWithSubjectCode:_subjectCode];
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
    NSLog(@"%@",sender);
}
//下一题按钮
-(void)btnBarNextClick:(UIBarButtonItem *)sender{
    NSLog(@"%@",sender);
}
//答案按钮
-(void)btnAnswerClick:(UIButton *)sender{
     NSLog(@"%@",sender);
}
//加载试题内容
-(void)setupItemContentView{
    
}
#pragma mark 加载数据
-(void)loadDataAtOrder:(NSInteger)order{
    ///TODO:
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
