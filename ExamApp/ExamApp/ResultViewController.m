//
//  ResultViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ResultViewController.h"
#import "UIViewController+VisibleView.h"
#import "NSString+Size.h"
#import "UIColor+Hex.h"

#import "PaperReview.h"
#import "PaperRecord.h"
#import "PaperItemRecord.h"

#import "PaperListViewController.h"
#import "ItemViewController.h"

#import "PaperRecordService.h"

#import "UIViewUtils.h"

#define __kResultViewController_Title @"答题情况"
#define __kResultViewController_Top 5//顶部间隔
#define __kResultViewController_Left 5//左边间隔
#define __kResultViewController_Right 5//右边间隔
#define __kResultViewController_Bottom 5//底部间隔
#define __kResultViewController_Margin_Max 10//最大间距
#define __kResultViewController_Margin_Min 2//最小间距

#define __kResultViewController_fontSize 14//字体大小

#define __kResultViewController_Title_TotalScore @"试题总分:%.1f分"//
#define __kResultViewController_Title_Score @"本次得分:%.1f分"//
#define __kResultViewController_Title_Times @"试题限时:%ld分钟"//
#define __kResultViewController_Title_useTimes @"答题耗时:%.1f分钟"//
#define __kResultViewController_Title_finishItems @"已做:%ld题"//
#define __kResultViewController_Title_todoItems @"未做:%ld题"//
#define __kResultViewController_Title_rights @"做对:%ld题"//
#define __kResultViewController_Title_errors @"做错:%ld题"//
#define __kResultViewController_Title_totals @"共计:%ld题"//
#define __kResultViewController_Title_rightRate @"正确率:%.1f%%"//
#define __kResultViewController_Title_borderColor 0xdedede//边框颜色

#define __kResultViewController_btn_height 40//按钮高度
#define __kResultViewController_btn_borderColor 0xdedede
#define __kResultViewController_btn_normalColor 0x3277ec//
#define __kResultViewController_btn_highlightColor 0x008B00//
#define __kResultViewController_btn_view @"查看题目"
#define __kResultViewController_btn_reset @"再做一次"


#define __kResultViewController_list_title @"试题列表"
#define __kResultViewController_list_titleColor 0x0000FF//

#define __kResultViewController_list_legend_width 15//图例宽度
#define __kResultViewController_list_legend_height 20//图例高度
#define __kResultViewController_list_legend_fontSize 10//字体大小
#define __kResultViewController_list_legend_borderColor 0xDEDEDE//边框颜色
#define __kResultViewController_list_legend_rightColor 0x00FF00//正确
#define __kResultViewController_list_legend_rightTitle @"正确"
#define __kResultViewController_list_legend_wrongColor 0xFF0000//错误
#define __kResultViewController_list_legend_wrongTitle @"错误"
#define __kResultViewController_list_legend_todoColor 0xFFFAFA//未做
#define __kResultViewController_list_legend_todoTitle @"未做"

#define __kResultViewController_list_item_font_size 12//字体
#define __kResultViewController_list_item_font_color 0x545454//
#define __kResultViewController_list_item_borderColor 0xcccccc//边框颜色
#define __kResultViewController_list_item_cols 5//每行的列数
#define __kResultViewController_list_item_height 30//试题号高度
#define __kResultViewController_list_item_vspace 10//纵向间距
#define __kResultViewController_list_item_hspace 10//横向间距

//答题情况试图控制器成员变量
@interface ResultViewController (){
    PaperReview *_paperReview;
    PaperRecord *_paperRecord;
    PaperRecordService *_paperRecordService;
    UIFont *_font;
}
@end
//答题情况试图控制器实现
@implementation ResultViewController
#pragma mark 初始化
-(instancetype)initWithPaper:(PaperReview *)review andRecord:(PaperRecord *)record{
    if(self = [super init]){
        _paperReview = review;
        _paperRecord = record;
        _font = [UIFont systemFontOfSize:__kResultViewController_fontSize];
    }
    return self;
}
#pragma mark UI加载入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //关闭滚动条y轴自动下移
    self.automaticallyAdjustsScrollViewInsets = NO;
    //设置标题
    self.title = __kResultViewController_Title;
    //左边按钮
    UIBarButtonItem *btnLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                                             target:self
                                                                             action:@selector(topLeftBarButtonClick:)];
    self.navigationItem.leftBarButtonItem = btnLeft;
    //初始化试题记录服务
    _paperRecordService = [[PaperRecordService alloc] init];
    //滚动
    UIScrollView *scrollPanel = [[UIScrollView alloc] initWithFrame:[self loadVisibleViewFrame]];
    //初始化y坐标
    NSNumber *y = [NSNumber numberWithFloat:0];
    //答题情况UI
    [self setupResultInfoViewWithPanel:scrollPanel OutY:&y];
    //两个按钮
    [self setupDoubleButtonViewWithPanel:scrollPanel OutY:&y];
    //题目列表
    [self setupPaperItemListViewWithPanel:scrollPanel OutY:&y];
    //重置可视范围滚动条
    CGRect temp = scrollPanel.frame;
    if(y.floatValue > CGRectGetHeight(temp)){
        scrollPanel.contentSize = CGSizeMake(CGRectGetWidth(temp), y.floatValue);
    }
    //添加到界面
    [self.view addSubview:scrollPanel];
}
//顶部返回按钮
-(void)topLeftBarButtonClick:(UIBarButtonItem *)sender{
    NSArray *controllers = self.navigationController.viewControllers;
    NSLog(@"viewControllers=>%@",controllers);
    if(_isAnswersheet){
        [self viewItemOrder:_itemOrder andDisplayAnswer:YES];
        return;
    }
    UIViewController *target;
    if(controllers && controllers.count > 0){
        for(UIViewController *vc in controllers){
            if(vc && [vc isKindOfClass:[PaperListViewController class]]){
                target = vc;
                break;
            }
        }
    }
    if(target){
        [self.navigationController popToViewController:target animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
//答题情况UI
-(void)setupResultInfoViewWithPanel:(UIView *)panel OutY:(NSNumber **)outY{
    CGRect tempFrame = CGRectMake(__kResultViewController_Left,
                                  (*outY).floatValue + __kResultViewController_Margin_Max,
                                  CGRectGetWidth(self.view.frame) - __kResultViewController_Left - __kResultViewController_Right,
                                  0);
    //初始化容器
    UIView *p = [[UIView alloc] initWithFrame:tempFrame];
    tempFrame.origin.x = tempFrame.origin.y = 0;
    NSNumber *y = [NSNumber numberWithInteger:__kResultViewController_Margin_Min];
    CGFloat width = CGRectGetWidth(tempFrame);
    //第一行
    //试卷总分
    NSNumber *paperTotalScore = [NSNumber numberWithInt:0],*paperTimes = [NSNumber numberWithInt:0];
    if(_paperReview && _paperReview.score){
        paperTotalScore = _paperReview.score;
    }
    //试卷限时
    if(_paperReview && _paperReview.time){
        paperTimes = [NSNumber numberWithInteger:_paperReview.time];
    }
    [self createResultRowWithPanel:p Y:&y Width:width
                         FirstText:[NSString stringWithFormat:__kResultViewController_Title_TotalScore,paperTotalScore.floatValue]
                        SecondText:[NSString stringWithFormat:__kResultViewController_Title_Times,paperTimes.longValue]
                    FirstTextColor:nil];
    //第二行
    y = [NSNumber numberWithFloat:(y.floatValue + __kResultViewController_Top)];
    //本次得分
    NSNumber *score = [NSNumber numberWithInt:0],*useTimes = [NSNumber numberWithInt:0];
    if(_paperRecord && _paperRecord.score){
        score = _paperRecord.score;
    }
    //答题耗时
    if(_paperRecord && _paperRecord.useTimes){
        useTimes = [NSNumber numberWithFloat:(_paperRecord.useTimes.floatValue / 60)];
    }
    [self createResultRowWithPanel:p Y:&y Width:width
                         FirstText:[NSString stringWithFormat:__kResultViewController_Title_Score, score.floatValue]
                        SecondText:[NSString stringWithFormat:__kResultViewController_Title_useTimes,useTimes.floatValue]
                    FirstTextColor:[UIColor redColor]];
    //第三行
    y = [NSNumber numberWithFloat:(y.floatValue + __kResultViewController_Top)];
    //已做／未做
    NSNumber *totalItems = [NSNumber numberWithInt:0],*finishItems = [NSNumber numberWithInt:0];
    if(_paperReview && _paperReview.total > 0){
        totalItems = [NSNumber numberWithInteger:_paperReview.total];
    }
    if(_paperRecord && _paperRecord.code && _paperRecordService){
        finishItems = [_paperRecordService loadFinishItemsWithPaperRecordCode:_paperRecord.code];
    }
    [self createResultRowWithPanel:p Y:&y Width:width
                         FirstText:[NSString stringWithFormat:__kResultViewController_Title_finishItems,finishItems.longValue]
                        SecondText:[NSString stringWithFormat:__kResultViewController_Title_todoItems,
                                    (long)(totalItems.integerValue - finishItems.integerValue)]
                    FirstTextColor:nil];
    //第四行
    y = [NSNumber numberWithFloat:(y.floatValue + __kResultViewController_Top)];
    //做对／做错
    NSNumber *rightItems = [NSNumber numberWithInt:0];
    if(_paperRecord && _paperRecord.code && _paperRecordService){
        rightItems = [_paperRecordService loadRightItemsWithPaperRecordCode:_paperRecord.code];
    }
    [self createResultRowWithPanel:p Y:&y Width:width
                         FirstText:[NSString stringWithFormat:__kResultViewController_Title_rights,rightItems.longValue]
                        SecondText:[NSString stringWithFormat:__kResultViewController_Title_errors,
                                    (long)(totalItems.integerValue - rightItems.integerValue)]
                    FirstTextColor:nil];
    //第五行
    y = [NSNumber numberWithFloat:(y.floatValue + __kResultViewController_Top)];
    //共计／正确率
    NSNumber *rightRate = [NSNumber numberWithInt:0];
    if(rightItems && rightItems.integerValue > 0 && totalItems && totalItems.integerValue > 0){
        rightRate = [NSNumber numberWithFloat:(rightItems.floatValue / finishItems.floatValue) * 100];
    }
    
    [self createResultRowWithPanel:p Y:&y Width:width
                         FirstText:[NSString stringWithFormat:__kResultViewController_Title_totals,totalItems.longValue]
                        SecondText:[NSString stringWithFormat:__kResultViewController_Title_rightRate,rightRate.floatValue]
                    FirstTextColor:nil];
    //重置高度
    tempFrame = p.frame;
    tempFrame.size.height = y.floatValue + __kResultViewController_Margin_Max;
    p.frame = tempFrame;
    //添加圆角边框
    [UIViewUtils addBoundsRadiusWithView:p
                             BorderColor:[UIColor colorWithHex:__kResultViewController_Title_borderColor]
                         BackgroundColor:nil];
    //添加到界面
    [panel addSubview:p];
    //输出y坐标
    *outY = [NSNumber numberWithFloat:CGRectGetMaxY(p.frame)];
}
//创建答题情况行
-(void)createResultRowWithPanel:(UIView *)panel
                              Y:(NSNumber **)y
                          Width:(CGFloat)width
                      FirstText:(NSString *)first
                     SecondText:(NSString *)second
                 FirstTextColor:(UIColor *)firstColor{
    if(!panel || !first || !second) return;
    CGFloat maxHeight = 0;
    if(first && first.length > 0){
        CGSize textSize = [first sizeWithFont:_font
                            constrainedToSize:CGSizeMake(width/2, CGFLOAT_MAX)
                                lineBreakMode:NSLineBreakByWordWrapping];
        if(maxHeight < textSize.height){
            maxHeight = textSize.height;
        }
    }
    if(second && second.length > 0){
        CGSize textSize = [second sizeWithFont:_font
                            constrainedToSize:CGSizeMake(width/2, CGFLOAT_MAX)
                                lineBreakMode:NSLineBreakByWordWrapping];
        if(maxHeight < textSize.height){
            maxHeight = textSize.height;
        }
    }
    CGRect tempFrame = CGRectMake(0, (*y).floatValue, width/2, maxHeight);
    //first
    UILabel *lbFirst = [[UILabel alloc]initWithFrame:tempFrame];
    lbFirst.font = _font;
    lbFirst.textAlignment = NSTextAlignmentCenter;
    lbFirst.numberOfLines = 0;
    if(firstColor){
        lbFirst.textColor = firstColor;
    }
    lbFirst.text = first;
    [panel addSubview:lbFirst];
    //second
    tempFrame.origin.x = CGRectGetMaxX(tempFrame);
    UILabel *lbSecond = [[UILabel alloc]initWithFrame:tempFrame];
    lbSecond.font = _font;
    lbSecond.textAlignment = NSTextAlignmentCenter;
    lbSecond.numberOfLines = 0;
    lbSecond.text = second;
    [panel addSubview:lbSecond];
    //重置y
    *y = [NSNumber numberWithFloat:CGRectGetMaxY(tempFrame)];
}
//两个按钮
-(void)setupDoubleButtonViewWithPanel:(UIView *)panel OutY:(NSNumber **)outY{
    CGRect tempFrame = CGRectMake(__kResultViewController_Left, (*outY).floatValue + __kResultViewController_Top,
    CGRectGetWidth(panel.frame) - __kResultViewController_Left - __kResultViewController_Right -__kResultViewController_Margin_Max,
                                  __kResultViewController_btn_height);
    //
    tempFrame.size.width /= 2;
    UIColor *normalColor = [UIColor colorWithHex:__kResultViewController_btn_normalColor],
            *highlightColor = [UIColor colorWithHex:__kResultViewController_btn_highlightColor],
            *borderColor = [UIColor colorWithHex:__kResultViewController_btn_borderColor];
    
    //查看题目
    UIButton *btnView = [UIButton buttonWithType:UIButtonTypeCustom];
    btnView.frame = tempFrame;
    btnView.titleLabel.font = _font;
    [btnView setTitleColor:normalColor forState:UIControlStateNormal];
    [btnView setTitleColor:highlightColor forState:UIControlStateHighlighted];
    [btnView setTitle:__kResultViewController_btn_view forState:UIControlStateNormal];
    [btnView addTarget:self action:@selector(btnViewClick:) forControlEvents:UIControlEventTouchUpInside];
    [UIViewUtils addBoundsRadiusWithView:btnView BorderColor:borderColor BackgroundColor:nil];
    [panel addSubview:btnView];
    //再做一次按钮
    tempFrame.origin.x = CGRectGetMaxX(tempFrame) + __kResultViewController_Margin_Max;
    UIButton *btnReset = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReset.frame = tempFrame;
    btnReset.titleLabel.font = _font;
    [btnReset setTitleColor:normalColor forState:UIControlStateNormal];
    [btnReset setTitleColor:highlightColor forState:UIControlStateHighlighted];
    [btnReset setTitle:__kResultViewController_btn_reset forState:UIControlStateNormal];
    [btnReset addTarget:self action:@selector(btnResetClick:) forControlEvents:UIControlEventTouchUpInside];
    [UIViewUtils addBoundsRadiusWithView:btnReset BorderColor:borderColor BackgroundColor:nil];
    [panel addSubview:btnReset];
    //输出高度
    *outY = [NSNumber numberWithFloat:CGRectGetMaxY(tempFrame)];
}
//试题列表
-(void)setupPaperItemListViewWithPanel:(UIScrollView *)panel OutY:(NSNumber **)outY{
    //题目列表标题
    [self setupListTitleWithPanel:panel OutY:outY];
    //图例
    [self setupListLegendWithPanel:panel OutY:outY];
    //试题列表
    //*outY = [NSNumber numberWithFloat:(*outY).floatValue + __kResultViewController_Top];
    //
    if(_paperReview){
        CGFloat w = CGRectGetWidth(panel.frame) - __kResultViewController_Left - __kResultViewController_Right;
        UIColor *borderColor = [UIColor colorWithHex:__kResultViewController_list_item_borderColor],
        *fontColor = [UIColor colorWithHex:__kResultViewController_list_item_font_color],
        *rightColor = [UIColor colorWithHex:__kResultViewController_list_legend_rightColor],
        *wrongColor = [UIColor colorWithHex:__kResultViewController_list_legend_wrongColor],
        *todoColor = [UIColor colorWithHex:__kResultViewController_list_legend_todoColor];
        UIFont *font = [UIFont systemFontOfSize:__kResultViewController_list_item_font_size];
        
        [_paperReview loadAnswersheet:^(NSString *text, NSArray *indexPaths) {
            if(!text || !indexPaths)return;
            CGRect tempFrame = CGRectMake(__kResultViewController_Left, (*outY).floatValue + __kResultViewController_Top, w, 0);
            //大题标题
            if(text.length > 0){
                CGSize textSize = [text sizeWithFont:_font
                                   constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame), CGFLOAT_MAX)
                                       lineBreakMode:NSLineBreakByWordWrapping];
                tempFrame.size.height = textSize.height;
                UILabel *lbText = [[UILabel alloc]initWithFrame:tempFrame];
                lbText.font = _font;
                lbText.textAlignment = NSTextAlignmentLeft;
                lbText.numberOfLines = 0;
                lbText.text = text;
                [panel addSubview:lbText];
            }
            //试题集合
            if(indexPaths.count > 0){
                tempFrame.origin.y =  CGRectGetMaxY(tempFrame) + __kResultViewController_Margin_Min;
                CGFloat itemWith = (CGRectGetWidth(tempFrame) - (__kResultViewController_list_item_cols + 1)*__kResultViewController_list_item_hspace)/__kResultViewController_list_item_cols;
                CGFloat x = tempFrame.origin.x, y = tempFrame.origin.y;
                
                for(NSUInteger i = 0; i < indexPaths.count; i++){
                    PaperItemOrderIndexPath *indexPath = [indexPaths objectAtIndex:i];
                    if(!indexPath)continue;
                    NSInteger col = i % __kResultViewController_list_item_cols;//列
                    NSInteger row = i / __kResultViewController_list_item_cols;//行
                    
                    tempFrame.origin.x = x + (itemWith + __kResultViewController_list_item_hspace)*col + __kResultViewController_list_item_hspace;
                    tempFrame.origin.y = y + (__kResultViewController_list_item_height + __kResultViewController_list_item_vspace) * row + __kResultViewController_list_item_vspace;
                    tempFrame.size = CGSizeMake(itemWith, __kResultViewController_list_item_height);
                    
                    UIButton *btnItem = [UIButton buttonWithType:UIButtonTypeCustom];
                    btnItem.frame = tempFrame;
                    btnItem.titleLabel.font = font;
                    btnItem.tag = indexPath.order;
                    [btnItem setTitleColor:fontColor forState:UIControlStateNormal];
                    [btnItem setTitle:[NSString stringWithFormat:@"%ld", (long)(indexPath.order + 1)] forState:UIControlStateNormal];
                    [btnItem addTarget:self action:@selector(btnItemOrderClick:) forControlEvents:UIControlEventTouchUpInside];
                    [UIViewUtils addBorderWithView:btnItem BorderColor:borderColor BackgroundColor:todoColor];
                    //加载做题记录
                    if(_paperRecord && _paperRecord.code && _paperRecordService && indexPath.item){
                        PaperItemRecord *itemRecord = [_paperRecordService loadRecordWithPaperRecordCode:_paperRecord.code
                                                                                                ItemCode:indexPath.item.code
                                                                                                 atIndex:indexPath.index];
                        if(itemRecord){
                            btnItem.backgroundColor = (itemRecord.status && (itemRecord.status.integerValue == [NSNumber numberWithBool:YES].integerValue)) ? rightColor : wrongColor;
                        }
                    }
                    //添加到面板
                    [panel addSubview:btnItem];
                }
            }
            //输出高度
            *outY = [NSNumber numberWithFloat:CGRectGetMaxY(tempFrame) + __kResultViewController_Bottom];
        }];
    }
}
//题目列表标题
-(void)setupListTitleWithPanel:(UIScrollView *)panel OutY:(NSNumber **)outY{
    //题目列表
    CGRect tempFrame = CGRectMake(__kResultViewController_Left,
                                  (*outY).floatValue + __kResultViewController_Top,
                                  CGRectGetWidth(panel.frame) - __kResultViewController_Left - __kResultViewController_Right, 0);
    UIFont *fontListTitle = [UIFont boldSystemFontOfSize:__kResultViewController_fontSize];
    CGSize listTitleSize = [__kResultViewController_list_title sizeWithFont:fontListTitle
                                                          constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame), CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    tempFrame.size.height = listTitleSize.height;
    UILabel *lbListTitle = [[UILabel alloc]initWithFrame:tempFrame];
    lbListTitle.font = fontListTitle;
    lbListTitle.textAlignment = NSTextAlignmentLeft;
    lbListTitle.textColor = [UIColor colorWithHex:__kResultViewController_list_titleColor];
    lbListTitle.text = __kResultViewController_list_title;
    [panel addSubview:lbListTitle];
    
    //输出高度
    *outY = [NSNumber numberWithFloat:CGRectGetMaxY(tempFrame)];
}
//试题图例
-(void)setupListLegendWithPanel:(UIScrollView *)panel OutY:(NSNumber **)outY{
    CGRect tempFrame = CGRectMake(__kResultViewController_Left,
                                  (*outY).floatValue + __kResultViewController_Top,
                                  CGRectGetWidth(panel.frame) - __kResultViewController_Left - __kResultViewController_Right, 0);
    CGFloat maxHeight = __kResultViewController_list_legend_height;
    UIFont *fontLegend = [UIFont systemFontOfSize:__kResultViewController_list_legend_fontSize];
    UIColor *borderColor = [UIColor colorWithHex:__kResultViewController_list_legend_borderColor];
    NSArray *legendTitles = @[__kResultViewController_list_legend_wrongTitle,
                              __kResultViewController_list_legend_rightTitle,
                              __kResultViewController_list_legend_todoTitle],
            *legendColors = @[[UIColor colorWithHex:__kResultViewController_list_legend_wrongColor],
                              [UIColor colorWithHex:__kResultViewController_list_legend_rightColor],
                              [UIColor colorWithHex:__kResultViewController_list_legend_todoColor]];
    for(NSUInteger i = 0; i < legendTitles.count; i++){
        NSString *text = [legendTitles objectAtIndex:i];
        if(text && text.length > 0){
            CGSize size = [text sizeWithFont:fontLegend];
            if(size.height > maxHeight){
                maxHeight = size.height;
            }
        }
    }
    //循环输出图例
    CGFloat x = tempFrame.origin.x, y = tempFrame.origin.y;
    for(NSUInteger i = 0; i < legendTitles.count; i++){
        //图例
        tempFrame.origin.x = (i == 0 ? x : CGRectGetMaxX(tempFrame)) + __kResultViewController_Margin_Min;
        tempFrame.origin.y = y + (maxHeight - __kResultViewController_list_legend_height)/2;
        tempFrame.size = CGSizeMake(__kResultViewController_list_legend_width, __kResultViewController_list_legend_height);
        
        UILabel *lbLegend = [[UILabel alloc] initWithFrame:tempFrame];
        lbLegend.backgroundColor = (UIColor *)[legendColors objectAtIndex:i];
        [UIViewUtils addBorderWithView:lbLegend BorderColor:borderColor BackgroundColor:nil];
        [panel addSubview:lbLegend];
        //文字
        NSString *title = (NSString *)[legendTitles objectAtIndex:i];
        tempFrame.origin.x = CGRectGetMaxX(tempFrame) + __kResultViewController_Margin_Min;
        CGSize titleSize = [title sizeWithFont:fontLegend];
        tempFrame.origin.y = y + (maxHeight - titleSize.height)/2;
        tempFrame.size = titleSize;
        
        UILabel *lbLegendTitle = [[UILabel alloc] initWithFrame:tempFrame];
        lbLegendTitle.font = fontLegend;
        lbLegendTitle.textAlignment = NSTextAlignmentLeft;
        lbLegendTitle.text = title;
        [panel addSubview:lbLegendTitle];
    }
    //输出高度
    *outY = [NSNumber numberWithFloat:(y + maxHeight + __kResultViewController_Margin_Min)];
}
//查看题目
-(void)btnViewClick:(UIButton *)sender{
    //NSLog(@"查看题目....");
    [self viewItemOrder:0 andDisplayAnswer:YES];
}
//再做一次
-(void)btnResetClick:(UIButton *)sender{
    //NSLog(@"再做一次....");
    //重新创建试卷记录
    if(_paperReview && _paperReview.code && _paperRecordService){
        _paperRecord = [_paperRecordService createNewRecordWithPaperCode:_paperReview.code];
    }
    [self viewItemOrder:0 andDisplayAnswer:NO];
}
//按题序查看题目
-(void)btnItemOrderClick:(UIButton *)sender{
    //NSLog(@"%d",sender.tag);
    [self viewItemOrder:sender.tag andDisplayAnswer:YES];
}
//查看题目
-(void)viewItemOrder:(NSInteger)order andDisplayAnswer:(BOOL)displayAnswer{
    if(order < 0) order = 0;
    ItemViewController *target;
    NSArray *controllers = self.navigationController.viewControllers;
    if(controllers && controllers.count > 0){
        for(UIViewController *controller in controllers){
            if(controller && [controller isKindOfClass:[ItemViewController class]]){
                target = (ItemViewController *)controller;
                break;
            }
        }
    }
//    if(!target){
//        target = [[ItemViewController alloc] initWithPaper:_paperReview
//                                                     Order:order
//                                                 andRecord:_paperRecord
//                                          andDisplayAnswer:displayAnswer];
//        [self.navigationController pushViewController:target animated:NO];
//        return;
//    }
//    if(target){
//        [target loadDataAtOrder:order andDisplayAnswer:displayAnswer];
//        [self.navigationController popToViewController:target animated:YES];
//    }
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
