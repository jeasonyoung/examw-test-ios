//
//  AnswersheetViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AnswersheetViewController.h"
#import "PaperReview.h"
#import "PaperRecord.h"

#import "UIViewController+VisibleView.h"
#import "NSString+Size.h"
#import "UIColor+Hex.h"

#import "UIViewUtils.h"
#import "ItemViewController.h"

#import "PaperRecordService.h"

#define __k_answersheetviewcontroller_title @"答题卡"

#define __k_answersheetviewcontroller_top 5//顶部间距
#define __k_answersheetviewcontroller_left 5//左边间距
#define __k_answersheetviewcontroller_right 5//左边间距
#define __k_answersheetviewcontroller_bottom 10//底部间距

#define __k_answersheetviewcontroller_margin_min 2//最小间距
#define __k_answersheetviewcontroller_margin_max 5//最大间距

#define __k_answersheetviewcontroller_legend_with 15//图示的宽度
#define __k_answersheetviewcontroller_legend_height 20//图示的高度
#define __k_answersheetviewcontroller_legend_font_size 10//图示字体大小
#define __k_answersheetviewcontroller_legend_borderColor 0x3277fc//边框颜色
#define __k_answersheetviewcontroller_legend_has_bgColor 0x3277fc//已做背景
#define __k_answersheetviewcontroller_legend_has_title @"已做"
#define __k_answersheetviewcontroller_legend_todo_bgColor 0xffffff//未做背景色
#define __k_answersheetviewcontroller_legend_todo_title @"未做"

#define __k_answersheetviewcontroller_title_font_size 13

#define __k_answersheetviewcontroller_item_font_size 12//字体
#define __k_answersheetviewcontroller_item_font_color 0x545454//
#define __k_answersheetviewcontroller_item_borderColor 0xcccccc//边框颜色
#define __k_answersheetviewcontroller_item_cols 5//每行的列数
#define __k_answersheetviewcontroller_item_height 30//试题号高度
#define __k_answersheetviewcontroller_item_vspace 10//纵向间距
#define __k_answersheetviewcontroller_item_hspace 10//横向间距

//答题卡视图控制器成员变量
@interface AnswersheetViewController (){
    PaperReview *_review;
    PaperRecord *_record;
    ItemViewController *_targetItemControoler;
    UIColor *_hasBgColor,*_todoBgColor,*_itemBorderColor,*_itemFontColor;
    UIFont *_itemFont;
    
    PaperRecordService *_recordService;
}
@end
//答题卡视图控制器实现
@implementation AnswersheetViewController
#pragma mark 初始化
-(instancetype)initWithPaperReview:(PaperReview *)review PaperRecord:(PaperRecord *)record{
    if(self = [super init]){
        _review = review;
        _record = record;
        
        _hasBgColor = [UIColor colorWithHex:__k_answersheetviewcontroller_legend_has_bgColor],
        _todoBgColor = [UIColor colorWithHex:__k_answersheetviewcontroller_legend_todo_bgColor];
        
        _itemBorderColor = [UIColor colorWithHex:__k_answersheetviewcontroller_item_borderColor];
        _itemFontColor = [UIColor colorWithHex:__k_answersheetviewcontroller_item_font_color];
        _itemFont = [UIFont systemFontOfSize:__k_answersheetviewcontroller_item_font_size];
    }
    return self;
}
#pragma mark 控件添加入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //标题
    self.title = __k_answersheetviewcontroller_title;
    //y坐标
    NSNumber *outY = [NSNumber numberWithFloat:[self loadTopHeight] + __k_answersheetviewcontroller_top];
    //加载图例
    [self setupIconsWithOutY:&outY];
    //初始化试卷记录服务
    _recordService = [[PaperRecordService alloc] init];
    //加载试题
    [self setupItemsWithOutY:&outY];
}
//左边返回按钮

//加载图例
-(void)setupIconsWithOutY:(NSNumber **)outY{
    CGRect tempFrame = self.view.frame;
    tempFrame.origin.x = __k_answersheetviewcontroller_left;
    tempFrame.origin.y = (*outY).floatValue + __k_answersheetviewcontroller_margin_min;
    tempFrame.size.width -= (__k_answersheetviewcontroller_left + __k_answersheetviewcontroller_right);
    CGFloat maxHeight = tempFrame.size.height = __k_answersheetviewcontroller_legend_height;
    
    UIFont *font = [UIFont systemFontOfSize:__k_answersheetviewcontroller_legend_font_size];
    //已做
    NSString *hasText = __k_answersheetviewcontroller_legend_has_title;
    CGSize hasTextSize = [hasText sizeWithFont:font constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame)/2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    if(maxHeight < hasTextSize.height){
        maxHeight = hasTextSize.height;
    }
    //未做
    NSString *todoText = __k_answersheetviewcontroller_legend_todo_title;
    CGSize todoTextSize = [todoText sizeWithFont:font constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame)/2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    if(maxHeight < todoTextSize.height){
        maxHeight = todoTextSize.height;
    }
    tempFrame.size.height = maxHeight;
    //面板容器
    UIView *viewPanel = [[UIView alloc] initWithFrame:tempFrame];
    //边框颜色
    UIColor *borderColor = [UIColor colorWithHex:__k_answersheetviewcontroller_legend_borderColor];
    //已做图例
    tempFrame.origin.x = __k_answersheetviewcontroller_margin_min;
    tempFrame.origin.y = (maxHeight - __k_answersheetviewcontroller_legend_height)/2;
    tempFrame.size.width = __k_answersheetviewcontroller_legend_with;
    tempFrame.size.height = __k_answersheetviewcontroller_legend_height;
    UILabel *lbLegendHas = [[UILabel alloc] initWithFrame:tempFrame];
    [UIViewUtils addBorderWithView:lbLegendHas BorderColor:borderColor BackgroundColor:_hasBgColor];
    [viewPanel addSubview:lbLegendHas];
    //已做图例文字
    tempFrame.origin.x += CGRectGetWidth(tempFrame) + 2;
    tempFrame.origin.y = (maxHeight - hasTextSize.height)/2;
    tempFrame.size = hasTextSize;
    UILabel *lbLegendHasText = [[UILabel alloc] initWithFrame:tempFrame];
    lbLegendHasText.font = font;
    lbLegendHasText.text = hasText;
    [viewPanel addSubview:lbLegendHasText];
    //未做图例
    tempFrame.origin.x += CGRectGetWidth(tempFrame) + __k_answersheetviewcontroller_margin_max + __k_answersheetviewcontroller_margin_min;
    tempFrame.origin.y = (maxHeight - __k_answersheetviewcontroller_legend_height)/2;
    tempFrame.size.width = __k_answersheetviewcontroller_legend_with;
    tempFrame.size.height = __k_answersheetviewcontroller_legend_height;
    UILabel *lbLegendTodo = [[UILabel alloc] initWithFrame:tempFrame];
    [UIViewUtils addBorderWithView:lbLegendTodo BorderColor:borderColor BackgroundColor:_todoBgColor];
    [viewPanel addSubview:lbLegendTodo];
    //未做图例文字
    tempFrame.origin.x += CGRectGetWidth(tempFrame) + 2;
    tempFrame.origin.y = (maxHeight - todoTextSize.height)/2;
    tempFrame.size = todoTextSize;
    UILabel *lbLegendTodoText = [[UILabel alloc] initWithFrame:tempFrame];
    lbLegendTodoText.font = font;
    lbLegendTodoText.text = todoText;
    [viewPanel addSubview:lbLegendTodoText];
    //将容器添加到界面
    [self.view addSubview:viewPanel];
    //输出y坐标
    *outY = [NSNumber numberWithFloat:CGRectGetMaxY(viewPanel.frame)];
}
//加载试题
-(void)setupItemsWithOutY:(NSNumber **)outY{
    CGRect tempFrame = self.view.frame;
    tempFrame.origin.x = __k_answersheetviewcontroller_left;
    tempFrame.origin.y = (*outY).floatValue + __k_answersheetviewcontroller_margin_max;
    tempFrame.size.width -= (__k_answersheetviewcontroller_left + __k_answersheetviewcontroller_right);
    tempFrame.size.height -= ((*outY).floatValue + __k_answersheetviewcontroller_bottom);
    //创建容器面板
    UIScrollView *viewPanel = [[UIScrollView alloc] initWithFrame:tempFrame];
    //viewPanel.backgroundColor = [UIColor redColor];
    __block NSNumber *itemOutY = [NSNumber numberWithFloat:0];
    if(_review){
        [_review loadAnswersheet:^(NSString *text, NSArray *indexPaths) {
            //创建试卷结构
            [self setupStructureItemsWithPanel:viewPanel Title:text IndexPathArrays:indexPaths OutY:&itemOutY];
        }];
    }
    //获取容器初始y
    if(itemOutY.floatValue > CGRectGetHeight(tempFrame)){
        viewPanel.contentSize = CGSizeMake(CGRectGetWidth(tempFrame), itemOutY.floatValue);
    }
    //获取到Y坐标
    //*outY = [NSNumber numberWithFloat:CGRectGetMaxY(viewPanel.frame)];
    //将容器添加到界面
    [UIViewUtils addBoundsRadiusWithView:viewPanel
                       BorderColor:[UIColor colorWithHex:__k_answersheetviewcontroller_item_borderColor]
                   BackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewPanel];
}
//创建试卷结构
-(void)setupStructureItemsWithPanel:(UIView *)viewPanel
                         Title:(NSString *)title
               IndexPathArrays:(NSArray *)indexPaths
                          OutY:(NSNumber **)outY{
    if(!title || title.length == 0) return;
    CGFloat height = 0;
    //大题标题
    CGRect tempFrame = CGRectMake(__k_answersheetviewcontroller_margin_min,
                                  (*outY).floatValue + __k_answersheetviewcontroller_margin_min,
                                  CGRectGetWidth(viewPanel.frame) - __k_answersheetviewcontroller_margin_min,
                                  0);
    UIFont *titleFont = [UIFont boldSystemFontOfSize:__k_answersheetviewcontroller_title_font_size];
    CGSize titleSize = [title sizeWithFont:titleFont
                         constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame),CGFLOAT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];
    tempFrame.size.height = titleSize.height;
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:tempFrame];
    lbTitle.font = titleFont;
    lbTitle.text = title;
    [viewPanel addSubview:lbTitle];
    height += CGRectGetHeight(tempFrame);
    //小题
    NSUInteger count = 0;
    if(indexPaths && (count = indexPaths.count) > 0){
        tempFrame.origin.y = CGRectGetMaxY(tempFrame) + __k_answersheetviewcontroller_margin_min;
        CGFloat width = CGRectGetWidth(tempFrame) - __k_answersheetviewcontroller_margin_min;
        CGFloat item_width = (width - (__k_answersheetviewcontroller_item_cols + 1) * __k_answersheetviewcontroller_item_hspace)/__k_answersheetviewcontroller_item_cols;
        tempFrame.size = CGSizeMake(width, 0);
        UIView *contentView = [[UIView alloc] initWithFrame:tempFrame];
        
        CGRect itemFrame;
        for(NSInteger i = 0; i < count; i++){
            PaperItemOrderIndexPath *indexPath = [indexPaths objectAtIndex:i];
            if(!indexPath)continue;
            
            NSInteger col = i % __k_answersheetviewcontroller_item_cols;//列
            NSInteger row = i /__k_answersheetviewcontroller_item_cols;//行
            
            itemFrame = CGRectMake((item_width +__k_answersheetviewcontroller_item_hspace) * col + __k_answersheetviewcontroller_item_hspace,
                                   (__k_answersheetviewcontroller_item_height + __k_answersheetviewcontroller_item_vspace) * row + __k_answersheetviewcontroller_item_vspace,
                                   item_width,
                                   __k_answersheetviewcontroller_item_height);
            
            
            UIButton *btnItem = [UIButton buttonWithType:UIButtonTypeCustom];
            btnItem.frame = itemFrame;
            btnItem.titleLabel.font = _itemFont;
            btnItem.tag = indexPath.order;
            [btnItem setTitleColor:_itemFontColor forState:UIControlStateNormal];
            [btnItem setTitleColor:_hasBgColor forState:UIControlStateHighlighted];
            [btnItem setTitle:[NSString stringWithFormat:@"%ld", ((long)indexPath.order + 1)] forState:UIControlStateNormal];
            
            //加载做题记录
            if(_record && _record.code && _record.code.length > 0 && _recordService && indexPath && indexPath.item){
                BOOL exit = [_recordService exitItemRecordWithPaperRecordCode:_record.code
                                                                     ItemCode:indexPath.item.code
                                                                      atIndex:indexPath.index];
                [btnItem setBackgroundColor:(exit ? _hasBgColor : _todoBgColor)];
            }
            //[btnItem setBackgroundColor:(arc4random_uniform(10)/2 == 0 ? _hasBgColor : _todoBgColor)];
            [UIViewUtils addBorderWithView:btnItem BorderColor:_itemBorderColor BackgroundColor:nil];
            [btnItem addTarget:self action:@selector(itemAnswersheetClick:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:btnItem];
        }
        //重置高度
        tempFrame.size.height = CGRectGetMaxY(itemFrame) + __k_answersheetviewcontroller_item_vspace;
        contentView.frame = tempFrame;
        //添加到面板
        [viewPanel addSubview:contentView];
        height += CGRectGetHeight(tempFrame);
    }
    //输出y
    *outY = [NSNumber numberWithFloat:((*outY).floatValue + height + __k_answersheetviewcontroller_margin_max)];
}
-(void)itemAnswersheetClick:(UIButton *)sender{
    //NSLog(@"itemAnswersheetClick->tag:%ld ＝>%@",(long)sender.tag,_record);
    if(!_targetItemControoler){
        NSArray *controllers = self.navigationController.viewControllers;
        if(controllers && controllers.count > 0){
            for(UIViewController *controller in controllers){
                if(controller && [controller isKindOfClass:[ItemViewController class]]){
                    _targetItemControoler = (ItemViewController *)controller;
                    break;
                }
            }
        }
    }
    if(_targetItemControoler){
        [_targetItemControoler loadDataAtOrder:sender.tag andDisplayAnswer:NO];
        [self.navigationController popToViewController:_targetItemControoler animated:YES];
    }
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
