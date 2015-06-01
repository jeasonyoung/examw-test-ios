//
//  AnswerCardCollectionViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AnswerCardCollectionViewCell.h"
#import "AnswerCardModelCellFrame.h"
#import "AnswerCardModel.h"

#import "UIColor+Hex.h"
#import "EffectsUtils.h"


#define __kAnswerCardCollectionViewCell_borderColor 0x1E90FF//边框颜色
#define __kAnswerCardCollectionViewCell_normalFontColor 0x696969//字体颜色
#define __kAnswerCardCollectionViewCell_highlightFontColor 0xFFDEAD//高亮字体颜色
//答题卡集合Cell成员变量
@interface AnswerCardCollectionViewCell (){
    UIButton *_btnOrder;
    UIColor *_borderColor;
}
@end
//答题卡集合Cell实现
@implementation AnswerCardCollectionViewCell

#pragma mark 重载初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self initializationComponents];
    }
    return self;
}

//初始化组件
-(void)initializationComponents{
    //边框颜色
    _borderColor = [UIColor colorWithHex:__kAnswerCardCollectionViewCell_borderColor];
    
    //字体颜色
    UIColor *normalFontColor = [UIColor colorWithHex:__kAnswerCardCollectionViewCell_normalFontColor],
    *highlightFontColor = [UIColor colorWithHex:__kAnswerCardCollectionViewCell_highlightFontColor];
    
    //按钮
    _btnOrder = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnOrder setTitleColor:normalFontColor forState:UIControlStateNormal];
    [_btnOrder setTitleColor:highlightFontColor forState:UIControlStateHighlighted];
    [_btnOrder addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //添加到容器
    [self.contentView addSubview:_btnOrder];
}

#pragma mark 加载模型Frame
-(void)loadModelCellFrame:(AnswerCardModelCellFrame *)cellFrame{
    if(!cellFrame)return;
    NSLog(@"加载答题卡Cell Frame[%@]...", cellFrame.order);
    _btnOrder.titleLabel.font = cellFrame.orderFont;
    _btnOrder.frame = cellFrame.orderFrame;
    [_btnOrder setTitle:cellFrame.order forState:UIControlStateNormal];
    //
    [EffectsUtils addBoundsRadiusWithView:self BorderColor:_borderColor BackgroundColor:cellFrame.orderBgColor];
    //
    if(cellFrame.model){
        _btnOrder.tag = cellFrame.model.order;
    }
}

//点击事件
-(void)btnClick:(UIButton *)sender{
    if(_delegate && [_delegate respondsToSelector:@selector(answerCardCell:clickOrder:)]){
        [_delegate answerCardCell:self clickOrder:sender.tag];
    }
}
@end
