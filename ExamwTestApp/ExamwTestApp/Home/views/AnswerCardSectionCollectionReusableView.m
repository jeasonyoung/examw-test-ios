//
//  AnswerCardSectionCollectionReusableView.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AnswerCardSectionCollectionReusableView.h"
#import "AnswerCardSectionModelCellFrame.h"

//答题卡Header成员变量
@interface AnswerCardSectionCollectionReusableView (){
    UILabel *_lbTitle,*_lbDesc;
}
@end
//答题卡Header实现
@implementation AnswerCardSectionCollectionReusableView

#pragma mark 重载初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self initializationComponents];
    }
    return self;
}

//初始化组件
-(void)initializationComponents{
    //标题
    _lbTitle = [[UILabel alloc] init];
    _lbTitle.textAlignment = NSTextAlignmentLeft;
    _lbTitle.numberOfLines = 0;
    //描述
    _lbDesc = [[UILabel alloc] init];
    _lbDesc.textAlignment = NSTextAlignmentLeft;
    _lbDesc.numberOfLines = 0;
    
    //添加到容器
    [self addSubview:_lbTitle];
    [self addSubview:_lbDesc];
}

#pragma mark 设置数据模型Frame
-(void)loadModelCellFrame:(AnswerCardSectionModelCellFrame *)cellFrame{
    if(!cellFrame)return;
    NSLog(@"加载答题卡Header的数据模型Frame...");
    //标题
    _lbTitle.font = cellFrame.titleFont;
    _lbTitle.frame = cellFrame.titleFrame;
    _lbTitle.text = cellFrame.title;
    //描述
    _lbDesc.font = cellFrame.descFont;
    _lbDesc.frame = cellFrame.descFrame;
    _lbDesc.text = cellFrame.desc;
}
@end
