//
//  AnswerCardSectionModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AnswerCardSectionModelCellFrame.h"
#import "AnswerCardSectionModel.h"

#import "AppConstants.h"

#define __kAnswerCardSectionModelCellFrame_top 10//顶部间距
#define __kAnswerCardSectionModelCellFrame_bottom 10//底部间距
#define __kAnswerCardSectionModelCellFrame_left 10//左边间距
#define __kAnswerCardSectionModelCellFrame_right 5//右边间距
#define __kAnswerCardSectionModelCellFrame_marginV 8//纵向间距

//答题卡分组数据模型CellFrame实现
@implementation AnswerCardSectionModelCellFrame

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        //标题字体
        _titleFont = [AppConstants globalListFont];
        //描述字体
        _descFont = [AppConstants globalListSubFont];
    }
    return self;
}

#pragma mark 设置数据模型
-(void)setModel:(AnswerCardSectionModel *)model{
    _model = model;
    //重置
    _titleFrame = _descFrame = CGRectZero;
    if(!_model)return;
    NSLog(@"设置答题卡分组数据模型Cell Frame...");
    CGFloat width = SCREEN_WIDTH;
    CGFloat x = __kAnswerCardSectionModelCellFrame_left,y = __kAnswerCardSectionModelCellFrame_top,
            maxWidth = width - __kAnswerCardSectionModelCellFrame_right;
    //标题
    _title = _model.title;
    if(_title && _title.length > 0){
        CGSize titleSize = [_title boundingRectWithSize:CGSizeMake(maxWidth - x, CGFLOAT_MAX)
                                                options:STR_SIZE_OPTIONS
                                             attributes:@{NSFontAttributeName : _titleFont}
                                                context:nil].size;
        _titleFrame = CGRectMake(x, y, titleSize.width, titleSize.height);
        y = CGRectGetMaxY(_titleFrame);
    }
    //描述
    _desc = _model.desc;
    if(_desc && _desc.length > 0){
        y = (y <= __kAnswerCardSectionModelCellFrame_top ? y : y +  __kAnswerCardSectionModelCellFrame_marginV);
        CGSize descSize = [_desc boundingRectWithSize:CGSizeMake(maxWidth - x, CGFLOAT_MAX)
                                              options:STR_SIZE_OPTIONS
                                           attributes:@{NSFontAttributeName : _descFont}
                                              context:nil].size;
        _descFrame = CGRectMake(x, y, descSize.width, descSize.height);
        y = CGRectGetMaxY(_descFrame);
    }
    //尺寸
    _cellSize = CGSizeMake(width, y + __kAnswerCardSectionModelCellFrame_bottom);
}

@end
