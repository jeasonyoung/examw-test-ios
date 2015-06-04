//
//  MyUserRegisterModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyRegisterModelCellFrame.h"
#import "MyRegisterModel.h"

#import "AppConstants.h"

#define __kMyRegisterModelCellFrame_top 10//顶部间距
#define __kMyRegisterModelCellFrame_left 10//左边间距
#define __kMyRegisterModelCellFrame_bottom 10//底部间距
#define __kMyRegisterModelCellFrame_right 10//右边间距

#define __kMyRegisterModelCellFrame_height 30//默认高度

//注册用户数据模型Frame实现
@implementation MyRegisterModelCellFrame

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        _font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    return self;
}

#pragma mark 设置数据模型
-(void)setModel:(MyRegisterModel *)model{
    _model = model;
    //重置
    _frame = CGRectZero;
    if(_model){
        //占位文字
        _placeholder = _model.placeholder;
        //是否为必填
        _isRequired = _model.isRequired;
        //是否为电子邮箱地址
        _isEmail = _model.isEmail;
        
        //
        CGFloat maxWidth = SCREEN_WIDTH - __kMyRegisterModelCellFrame_right, x = __kMyRegisterModelCellFrame_left, y = __kMyRegisterModelCellFrame_top;
        //
        _frame = CGRectMake(x, y, maxWidth - x, __kMyRegisterModelCellFrame_height);
        //行高
        _cellHeight = CGRectGetMaxY(_frame) + __kMyRegisterModelCellFrame_bottom;
    }
}
@end
