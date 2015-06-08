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

#import "EffectsUtils.h"

//答题卡集合Cell成员变量
@interface AnswerCardCollectionViewCell (){
    UIButton *_btnOrder;
    //UIColor *_borderColor;
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
    //按钮
    _btnOrder = [UIButton buttonWithType:UIButtonTypeSystem];
    [_btnOrder addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //添加到容器
    [self.contentView addSubview:_btnOrder];
}

#pragma mark 加载模型Frame
-(void)loadModelCellFrame:(AnswerCardModelCellFrame *)cellFrame{
    if(!cellFrame)return;
    NSLog(@"加载答题卡Cell Frame[%@]...", cellFrame.order);
    UIColor *color = cellFrame.orderColor;
    
    _btnOrder.titleLabel.font = cellFrame.orderFont;
    _btnOrder.frame = cellFrame.orderFrame;
    [_btnOrder setTitle:cellFrame.order forState:UIControlStateNormal];
    [_btnOrder setTitleColor:color forState:UIControlStateNormal];
    //
    [EffectsUtils addBoundsRadiusWithView:self BorderColor:color BackgroundColor:nil];
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
