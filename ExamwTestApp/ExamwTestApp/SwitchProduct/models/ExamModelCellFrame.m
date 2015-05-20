//
//  ExamModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ExamModelCellFrame.h"
#import "AppConstants.h"


#define __kExamModelCellFrame_top 10//顶部间距
#define __kExamModelCellFrame_bottom 10//底部间距
#define __kExamModelCellFrame_left 10//左边间距
#define __kExamModelCellFrame_right 5//右边间距

//考试CellFrame成员变量
@interface ExamModelCellFrame (){
}
@end
//考试CellFrame实现
@implementation ExamModelCellFrame
#pragma mark 重构初始化
-(instancetype)init{
    if(self = [super init]){
        //设置考试名称字体
        _nameFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
    return self;
}

#pragma mark 设置考试数据模型
-(void)setModel:(ExamModel *)model{
    _model = model;
    //重置
    _nameFrame = CGRectZero;
    _cellHeight = 0;
    
    if(!_model)return;
    //设置考试名称
    _name = _model.name;
    //
    if(_name && _name.length > 0){
        CGFloat maxWith = SCREEN_WIDTH - __kExamModelCellFrame_left - __kExamModelCellFrame_right;
        CGSize nameSize = [_name boundingRectWithSize:CGSizeMake(maxWith, CGFLOAT_MAX)
                                              options:STR_SIZE_OPTIONS
                                           attributes:@{NSFontAttributeName:_nameFont}
                                              context:nil].size;
        //
        _nameFrame = CGRectMake(__kExamModelCellFrame_left, __kExamModelCellFrame_top,
                                nameSize.width, nameSize.height);
        //
        _cellHeight = CGRectGetMaxY(_nameFrame) + __kExamModelCellFrame_bottom;
    }
}
@end
