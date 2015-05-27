//
//  PaperButtonModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperButtonModelCellFrame.h"

#import "AppConstants.h"
#import "PaperModel.h"
#import "PaperButtonModel.h"
#import "PaperRecordModel.h"

#define __kPaperButtonModelCellFrame_top 10//顶部间距
#define __kPaperButtonModelCellFrame_bottom 15//底部间距
#define __kPaperButtonModelCellFrame_left 10//左边间距
#define __kPaperButtonModelCellFrame_right 10//右边间距

//#define __kPaperButtonModelCellFrame_marginV 5//纵向间距
#define __kPaperButtonModelCellFrame_marginH 15//横向间距

#define __kPaperButtonModelCellFrame_btnStart @"开始考试"//1
#define __kPaperButtonModelCellFrame_btnContinue @"继续考试"//2
#define __kPaperButtonModelCellFrame_btnReset @"重新开始"//3
#define __kPaperButtonModelCellFrame_btnReview @"查看成绩"//4

#define __kPaperButtonModelCellFrame_btnHeight 30//

//试卷按钮数据模型实现
@implementation PaperButtonModelCellFrame

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        //按钮字体
        _btnFont = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    return self;
}

#pragma mark 设置数据模型
-(void)setModel:(PaperButtonModel *)model{
    _model = model;
    //重置
    _btn1Frame = _btn2Frame = CGRectZero;
    if(!_model){
        return;
    }
    CGFloat x = __kPaperButtonModelCellFrame_left, y = __kPaperButtonModelCellFrame_top,
    maxWidth = SCREEN_WIDTH,
    width = (maxWidth - __kPaperButtonModelCellFrame_left - __kPaperButtonModelCellFrame_right - __kPaperButtonModelCellFrame_marginH)/2;
    //做题记录不存在
    if(!_model.recordModel){
        _btn1Title = __kPaperButtonModelCellFrame_btnStart;
        _btn1Tag = 0x01;
        _btn1Frame = CGRectMake(maxWidth/2 - width/2, y, width, __kPaperButtonModelCellFrame_btnHeight);
        _cellHeight = CGRectGetMaxY(_btn1Frame) + __kPaperButtonModelCellFrame_bottom;
        return;
    }
    
    if(_model.recordModel.status){//已做完
        _btn1Title = __kPaperButtonModelCellFrame_btnReview;
        _btn1Tag = 0x04;
        _btn2Title = __kPaperButtonModelCellFrame_btnStart;
        _btn2Tag = 0x01;
    }else{//未做完
        _btn1Title = __kPaperButtonModelCellFrame_btnContinue;
        _btn1Tag = 0x02;
        _btn2Title = __kPaperButtonModelCellFrame_btnReset;
        _btn2Tag = 0x03;
    }
    
    //btn1
    _btn1Frame = CGRectMake(x, y, width, __kPaperButtonModelCellFrame_btnHeight);
    x = CGRectGetMaxX(_btn1Frame) + __kPaperButtonModelCellFrame_marginH;
    //btn2
    _btn2Frame = CGRectMake(x, y, width, __kPaperButtonModelCellFrame_btnHeight);
    //行高
    _cellHeight =  CGRectGetMaxY(_btn2Frame) + __kPaperButtonModelCellFrame_bottom;
}

@end
