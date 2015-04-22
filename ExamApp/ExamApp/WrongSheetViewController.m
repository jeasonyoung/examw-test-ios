//
//  WrongSheetViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "WrongSheetViewController.h"
#import "UIViewController+VisibleView.h"
#import "UIColor+Hex.h"
#import "NSString+Size.h"

#import "UIViewUtils.h"

#import "WrongItemRecordService.h"

#import "WrongViewController.h"

#define __kWrongSheetViewController_title @"收藏试题"

#define __kWrongSheetViewController_Top 5//顶部间隔
#define __kWrongSheetViewController_Left 5//左边间隔
#define __kWrongSheetViewController_Right 5//右边间隔
#define __kWrongSheetViewController_Bottom 5//底部间隔

#define __kWrongSheetViewController_Margin_Max 10//最大间距
#define __kWrongSheetViewController_Margin_Min 2//最小间距

#define __kWrongSheetViewController_fontSize 14//字体大小

#define __kWrongSheetViewController_legend_with 15//图示的宽度
#define __kWrongSheetViewController_legend_height 20//图示的高度
#define __kWrongSheetViewController_legend_fontSize 10//图示字体大小
#define __kWrongSheetViewController_legend_borderColor 0x3277fc//边框颜色
#define __kWrongSheetViewController_legend_hasBgColor 0x3277fc//已做背景
#define __kWrongSheetViewController_legend_hasTitle @"已做"
#define __kWrongSheetViewController_legend_todoBgColor 0xffffff//未做背景色
#define __kWrongSheetViewController_legend_todoTitle @"未做"

#define __kWrongSheetViewController_item_fontSize 12//字体
#define __kWrongSheetViewController_item_fontColor 0x545454//
#define __kWrongSheetViewController_item_borderColor 0xcccccc//边框颜色
#define __kWrongSheetViewController_item_cols 5//每行的列数
#define __kWrongSheetViewController_item_height 30//试题号高度
#define __kWrongSheetViewController_item_vspace 10//纵向间距
#define __kWrongSheetViewController_item_hspace 10//横向间距
//错题重做答题卡视图成员变量
@interface WrongSheetViewController (){
    NSString *_subjectCode;
    UIColor *_hasBgColor,*_todoBgColor;
    WrongItemRecordService *_service;
    NSMutableDictionary *_answersCache;
}
@end
//错题重做答题卡视图实现
@implementation WrongSheetViewController
#pragma mark 初始化
-(instancetype)initWithSubjectCode:(NSString *)subjectCode andAnswers:(NSMutableDictionary *)answersCache{
    if(self = [super init]){
        _subjectCode = subjectCode;
        _answersCache = answersCache;
        _hasBgColor = [UIColor colorWithHex:__kWrongSheetViewController_legend_hasBgColor];
        _todoBgColor = [UIColor colorWithHex:__kWrongSheetViewController_legend_todoBgColor];
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //关闭滚动条y轴自动下移
    self.automaticallyAdjustsScrollViewInsets = NO;
    //设置标题
    self.title = __kWrongSheetViewController_title;
    //初始化服务类
    _service = [[WrongItemRecordService alloc]init];
    
    //答题卡
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, [self loadTopHeight],
                                                                              CGRectGetWidth(self.view.frame),
                                                                              CGRectGetHeight(self.view.frame))];
    NSNumber *height = [NSNumber numberWithFloat:0];
    //设置图标
    [self setLegendWithPanel:scrollView OutY:&height];
    //设置答题卡
    [self setupSheetWithPanel:scrollView OutY:&height];
    //重置高度
    if(height.floatValue > CGRectGetHeight(scrollView.frame)){
        scrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollView.frame), height.floatValue);
    }
    //添加到界面
    [self.view addSubview:scrollView];
}
//设置图标
-(void)setLegendWithPanel:(UIView *)panel OutY:(NSNumber **)outY{
    CGRect tempFrame = self.view.frame;
    tempFrame.origin.x = __kWrongSheetViewController_Left;
    tempFrame.origin.y = (*outY).floatValue + __kWrongSheetViewController_Margin_Min;
    tempFrame.size.width -= (__kWrongSheetViewController_Left + __kWrongSheetViewController_Right);
    CGFloat maxHeight = tempFrame.size.height = __kWrongSheetViewController_legend_height;
    
    UIFont *font =  [UIFont systemFontOfSize:__kWrongSheetViewController_legend_fontSize];
    //已做
    CGSize hasTextSize = [__kWrongSheetViewController_legend_hasTitle sizeWithFont:font
                                                                 constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame), CGFLOAT_MAX)
                                                                     lineBreakMode:NSLineBreakByWordWrapping];
    if(maxHeight < hasTextSize.height){
        maxHeight = hasTextSize.height;
    }
    //未做
    CGSize todoTextSize = [__kWrongSheetViewController_legend_todoTitle sizeWithFont:font
                                                                   constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame), CGFLOAT_MAX)
                                                                       lineBreakMode:NSLineBreakByWordWrapping];
    if(maxHeight < todoTextSize.height){
        maxHeight =  todoTextSize.height;
    }
    //
    tempFrame.size.height = maxHeight;
    //面板容器
    UIView *viewPanel = [[UIView alloc]initWithFrame:tempFrame];
    //边框颜色
    UIColor *borderColor = [UIColor colorWithHex:__kWrongSheetViewController_legend_borderColor];
    //已做图列
    tempFrame.origin.x = __kWrongSheetViewController_Margin_Min;
    tempFrame.origin.y = (maxHeight - __kWrongSheetViewController_legend_height)/2;
    tempFrame.size = CGSizeMake(__kWrongSheetViewController_legend_with, __kWrongSheetViewController_legend_height);
    UILabel *lbLegendHas = [[UILabel alloc]initWithFrame:tempFrame];
    [UIViewUtils addBorderWithView:lbLegendHas BorderColor:borderColor BackgroundColor:_hasBgColor];
    [viewPanel addSubview:lbLegendHas];
    //已做图例文字
    tempFrame.origin.x = CGRectGetMaxX(tempFrame) + 2;
    tempFrame.origin.y = (maxHeight - hasTextSize.height)/2;
    tempFrame.size = hasTextSize;
    UILabel *lbLegendHasText = [[UILabel alloc]initWithFrame:tempFrame];
    lbLegendHasText.font = font;
    lbLegendHasText.text = __kWrongSheetViewController_legend_hasTitle;
    [viewPanel addSubview:lbLegendHasText];
    
    //未做图例
    tempFrame.origin.x = CGRectGetMaxX(tempFrame) + __kWrongSheetViewController_Margin_Max + __kWrongSheetViewController_Margin_Min;
    tempFrame.origin.y = (maxHeight - __kWrongSheetViewController_legend_height)/2;
    tempFrame.size = CGSizeMake(__kWrongSheetViewController_legend_with, __kWrongSheetViewController_legend_height);
    UILabel *lbLegendTodo = [[UILabel alloc]initWithFrame:tempFrame];
    [UIViewUtils addBorderWithView:lbLegendTodo BorderColor:borderColor BackgroundColor:_todoBgColor];
    [viewPanel addSubview:lbLegendTodo];
    //未做图例文字
    tempFrame.origin.x = CGRectGetMaxX(tempFrame) + 2;
    tempFrame.origin.y = (maxHeight - todoTextSize.height)/2;
    tempFrame.size = todoTextSize;
    UILabel *lbLegendTodoText = [[UILabel alloc]initWithFrame:tempFrame];
    lbLegendTodoText.font = font;
    lbLegendTodoText.text = __kWrongSheetViewController_legend_todoTitle;
    [viewPanel addSubview:lbLegendTodoText];
    //将容器添加到界面
    [panel addSubview:viewPanel];
    //输出y坐标
    *outY = [NSNumber numberWithFloat:CGRectGetMaxY(viewPanel.frame)];
}
//设置答题卡
-(void)setupSheetWithPanel:(UIView *)panel OutY:(NSNumber **)outY{
    if(!_subjectCode || _subjectCode.length == 0)return;
    
    CGFloat w = CGRectGetWidth(panel.frame) - (__kWrongSheetViewController_Left + __kWrongSheetViewController_Right);
    UIColor *borderColor = [UIColor colorWithHex:__kWrongSheetViewController_item_borderColor],
    *fontColor = [UIColor colorWithHex:__kWrongSheetViewController_item_fontColor];
    UIFont *font = [UIFont systemFontOfSize:__kWrongSheetViewController_fontSize],
    *itemFont = [UIFont systemFontOfSize:__kWrongSheetViewController_item_fontSize];
    
    [_service loadSheetWithSubjectCode:_subjectCode SheetsBlock:^(NSString *itemTypeName, NSArray *sheets) {
        CGRect tempFrame = CGRectMake(__kWrongSheetViewController_Left, (*outY).floatValue + __kWrongSheetViewController_Top, w, 0);
        //试题类型名称
        if(itemTypeName && itemTypeName.length > 0){
            CGSize nameSize = [itemTypeName sizeWithFont:font
                                       constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame), CGFLOAT_MAX)
                                           lineBreakMode:NSLineBreakByWordWrapping];
            tempFrame.size.height = nameSize.height;
            UILabel *lbName = [[UILabel alloc]initWithFrame:tempFrame];
            lbName.font = font;
            lbName.textAlignment = NSTextAlignmentLeft;
            lbName.numberOfLines = 0;
            lbName.text = itemTypeName;
            [panel addSubview:lbName];
        }
        if(sheets && sheets.count > 0){
            tempFrame.origin.y =  CGRectGetMaxY(tempFrame) + __kWrongSheetViewController_Margin_Min;
            CGFloat itemWith = (CGRectGetWidth(tempFrame) - (__kWrongSheetViewController_item_cols + 1)*__kWrongSheetViewController_item_hspace)/__kWrongSheetViewController_item_cols;
            CGFloat x = tempFrame.origin.x, y = tempFrame.origin.y;
            
            for(NSInteger i = 0; i < sheets.count; i++){
                NSNumber *order = [sheets objectAtIndex:i];
                if(!order)continue;
                NSInteger col = i % __kWrongSheetViewController_item_cols;//列
                NSInteger row = i / __kWrongSheetViewController_item_cols;//行
                
                tempFrame.origin.x = x + (itemWith + __kWrongSheetViewController_item_hspace)*col + __kWrongSheetViewController_item_hspace;
                tempFrame.origin.y = y + (__kWrongSheetViewController_item_height + __kWrongSheetViewController_item_vspace) * row + __kWrongSheetViewController_item_vspace;
                tempFrame.size = CGSizeMake(itemWith, __kWrongSheetViewController_item_height);
                
                UIButton *btnItem = [UIButton buttonWithType:UIButtonTypeCustom];
                btnItem.frame = tempFrame;
                btnItem.titleLabel.font = itemFont;
                btnItem.tag = order.integerValue;
                
                if(_answersCache && _answersCache.count > 0){
                    NSString *answer = [_answersCache objectForKey:order];
                    btnItem.backgroundColor = (answer && answer.length > 0) ? _hasBgColor : _todoBgColor;
                }
                
                [btnItem setTitleColor:fontColor forState:UIControlStateNormal];
                [btnItem setTitle:[NSString stringWithFormat:@"%ld", (long)(order.integerValue + 1)] forState:UIControlStateNormal];
                [btnItem addTarget:self action:@selector(btnItemOrderClick:) forControlEvents:UIControlEventTouchUpInside];
                [UIViewUtils addBorderWithView:btnItem BorderColor:borderColor BackgroundColor:nil];
                //添加到面板
                [panel addSubview:btnItem];
            }
        }
        //输出高度
        *outY = [NSNumber numberWithFloat:CGRectGetMaxY(tempFrame) + __kWrongSheetViewController_Bottom];
    }];
}
//试题点击事件
-(void)btnItemOrderClick:(UIButton *)sender{
    //NSLog(@"%@,%d",sender,(int)sender.tag);
    NSArray *controllers = self.navigationController.viewControllers;
    if(controllers && controllers.count > 0){
        WrongViewController *target;
        for(UIViewController *vc in controllers){
            if(vc && [vc isKindOfClass:[WrongViewController class]]){
                target = (WrongViewController *)vc;
                break;
            }
        }
        if(target){
            [target loadDataAtOrder:sender.tag];
            [self.navigationController popToViewController:target animated:YES];
        }
    }
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(_answersCache && _answersCache.count > 0){
        [_answersCache removeAllObjects];
    }
}
@end
