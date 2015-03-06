//
//  AnswersheetViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AnswersheetViewController.h"
#import "PaperReview.h"

#import "UIViewController+VisibleView.h"
#import "NSString+Size.h"
#import "UIColor+Hex.h"

#import "UIViewUtils.h"
#import "ItemAnswersheet.h"

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
#define __k_answersheetviewcontroller_item_space 10//

//答题卡视图控制器成员变量
@interface AnswersheetViewController (){
    PaperReview *_review;
    NSString *_paperRecordCode;
    UIColor *_hasBgColor,*_todoBgColor;
}
@end
//答题卡视图控制器实现
@implementation AnswersheetViewController
#pragma mark 初始化
-(instancetype)initWithPaperReview:(PaperReview *)review PaperRecordCode:(NSString *)recordCode{
    if(self = [super init]){
        _review = review;
        _paperRecordCode = recordCode;
        
        _hasBgColor = [UIColor colorWithHex:__k_answersheetviewcontroller_legend_has_bgColor],
        _todoBgColor = [UIColor colorWithHex:__k_answersheetviewcontroller_legend_todo_bgColor];
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
    //加载试题
    [self setupItemsWithOutY:&outY];
}
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
    CGSize hasTextSize = [hasText sizeWithFont:font constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame)/2, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    if(maxHeight < hasTextSize.height){
        maxHeight = hasTextSize.height;
    }
    //未做
    NSString *todoText = __k_answersheetviewcontroller_legend_todo_title;
    CGSize todoTextSize = [todoText sizeWithFont:font constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame)/2, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping];
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
    //添加试题
    NSNumber *itemOutY = [NSNumber numberWithFloat:0];
    if(_review && _review.structures && _review.structures.count > 0){
        for(PaperStructure *structure in _review.structures){
            if(structure){
                [self createTitleWithViewPanel:viewPanel Structure:structure OutY:&itemOutY];
            }
        }
    }
    //获取容器初始y
    if(itemOutY.floatValue > CGRectGetHeight(tempFrame)){
        viewPanel.contentSize = CGSizeMake(CGRectGetWidth(tempFrame), itemOutY.floatValue);
    }
    //获取到Y坐标
    *outY = [NSNumber numberWithFloat:CGRectGetMaxY(viewPanel.frame)];
    //将容器添加到界面
    [UIViewUtils addBoundsRadiusWithView:viewPanel
                       BorderColor:[UIColor colorWithHex:__k_answersheetviewcontroller_item_borderColor]
                   BackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewPanel];
}
//创建大题
-(void)createTitleWithViewPanel:(UIView *)viewPanel Structure:(PaperStructure *)structure OutY:(NSNumber **)outY{
    NSString *title = structure.title;
    if(!title || title.length == 0) return;
    CGFloat y = 0;
    
    CGRect tempFrame = self.view.frame;
    tempFrame.origin.x = __k_answersheetviewcontroller_left;
    tempFrame.origin.y = (*outY).floatValue + __k_answersheetviewcontroller_top;
    tempFrame.size.width -= (__k_answersheetviewcontroller_left + __k_answersheetviewcontroller_right);
    
    UIFont *titleFont = [UIFont boldSystemFontOfSize:__k_answersheetviewcontroller_title_font_size];
    CGSize titleSize = [title sizeWithFont:titleFont
                         constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame), 1000.0f)
                             lineBreakMode:NSLineBreakByWordWrapping];
    tempFrame.size.height = titleSize.height;
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:tempFrame];
    lbTitle.font = titleFont;
    lbTitle.text = [NSString stringWithFormat:@"%@[%d]",title, structure.total];
    [viewPanel addSubview:lbTitle];
    y = CGRectGetMaxY(tempFrame);
    
    CGFloat y1 = y;
    //试题集合
    UIView *contentView = [self createViewWithItems:structure.items With:CGRectGetWidth(tempFrame) - __k_answersheetviewcontroller_margin_min *2];
    if(contentView){
        tempFrame = contentView.frame;
        tempFrame.origin.x = __k_answersheetviewcontroller_margin_min;
        tempFrame.origin.y = y + __k_answersheetviewcontroller_margin_max;
        
        contentView.frame = tempFrame;
        //[UIViewUtils addBorderWithView:contentView BorderColor:[UIColor redColor] BackgroundColor:nil];
        
        y +=  CGRectGetHeight(contentView.frame) + __k_answersheetviewcontroller_margin_max;
        NSLog(@"y1 = %f,y2 = %f,y2 - y1 = %f",y1,y,y-y1);
        [viewPanel addSubview:contentView];
    }
    //高度
    *outY = [NSNumber numberWithFloat:y];
}
-(UIView *)createViewWithItems:(NSArray *)items With:(CGFloat)w{
    int count = 0;
    if(items && (count = items.count) > 0){
        UIColor *borderColor = [UIColor colorWithHex:__k_answersheetviewcontroller_item_borderColor],
                *itemTextColor = [UIColor colorWithHex:__k_answersheetviewcontroller_item_font_color];
        UIFont *itemFont = [UIFont systemFontOfSize:__k_answersheetviewcontroller_item_font_size];
        CGFloat item_width = (w - (__k_answersheetviewcontroller_item_cols + 1) * __k_answersheetviewcontroller_item_space)/__k_answersheetviewcontroller_item_cols;
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 0)];
        CGRect contentFrame;
        for(int i = 0; i < count; i++){
            PaperItem *item = [items objectAtIndex:i];
            if(!item)continue;
            int col = i % __k_answersheetviewcontroller_item_cols;//列
            int row = i /__k_answersheetviewcontroller_item_cols;//行
            contentFrame = CGRectMake((item_width +__k_answersheetviewcontroller_item_space) * col + __k_answersheetviewcontroller_item_space,
                                      (__k_answersheetviewcontroller_item_height + __k_answersheetviewcontroller_item_space) * row + __k_answersheetviewcontroller_item_space,
                                      item_width,
                                      __k_answersheetviewcontroller_item_height);
            ItemAnswersheet *btnTitle = [ItemAnswersheet buttonWithType:UIButtonTypeCustom];
            btnTitle.frame = contentFrame;
            btnTitle.titleLabel.font = itemFont;
            //btnTitle.item = item;
            [btnTitle setTitleColor:itemTextColor forState:UIControlStateNormal];
            [btnTitle setTitleColor:_hasBgColor forState:UIControlStateHighlighted];
            [btnTitle setTitle:[NSString stringWithFormat:@"%d",item.orderNo] forState:UIControlStateNormal];
            
            [btnTitle setBackgroundColor:(arc4random_uniform(10)/2 == 0 ? _hasBgColor : _todoBgColor)];
            
            [UIViewUtils addBorderWithView:btnTitle BorderColor:borderColor BackgroundColor:nil];
            [btnTitle addTarget:self action:@selector(itemAnswersheetClick:) forControlEvents:UIControlEventTouchUpInside];
            //
            [contentView addSubview:btnTitle];
        }
        //重置尺寸
        CGRect tempFrame = contentView.frame;
        tempFrame.size.height = CGRectGetMaxY(contentFrame) + __k_answersheetviewcontroller_item_space;
        contentView.frame = tempFrame;
        return contentView;
    }
    return nil;
}
//点击
-(void)itemAnswersheetClick:(ItemAnswersheet *)sender{
    NSLog(@"itemAnswersheetClick==>");
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
