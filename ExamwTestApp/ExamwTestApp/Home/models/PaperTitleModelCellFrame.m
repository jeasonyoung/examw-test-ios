//
//  PaperTitleModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperTitleModelCellFrame.h"

#import "PaperTitleModel.h"
#import "AppConstants.h"


#define __kPaperTitleModelCellFrame_top 10//顶部间距
#define __kPaperTitleModelCellFrame_bottom 10//底部间距
#define __kPaperTitleModelCellFrame_left 10//左边间距
#define __kPaperTitleModelCellFrame_right 5//右边间距
#define __kPaperTitleModelCellFrame_marginV 5//纵向间距
//#define __kPaperTitleModelCellFrame_marginH 15//横向间距

#define __kPaperTitleModelCellFrame_subjectFormat @"科目:%@"//

//试卷标题模型CellFrame实现
@implementation PaperTitleModelCellFrame

#pragma mark 初始化
-(instancetype)init{
    if(self = [super init]){
        //设置试卷标题字体
        _titleFont = [AppConstants globalListFont];
        //设置所属科目字体
        _subjectFont = [AppConstants globalListSubFont];
    }
    return self;
}

#pragma mark 设置数据模型
-(void)setModel:(PaperTitleModel *)model{
    _model = model;
    //重置
    _titleFrame = _subjectFrame = CGRectZero;
    if(!_model)return;
    
    CGFloat x = __kPaperTitleModelCellFrame_left, y = __kPaperTitleModelCellFrame_top,
    maxWith = SCREEN_WIDTH - __kPaperTitleModelCellFrame_right;
    //试卷标题
    _title = _model.title;
    if(_title && _title.length > 0){
        CGSize titleSize = [_title boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                options:STR_SIZE_OPTIONS
                                             attributes:@{NSFontAttributeName : _titleFont}
                                                context:nil].size;
        _titleFrame = CGRectMake(x, y, titleSize.width, titleSize.height);
        y = CGRectGetMaxY(_titleFrame);
    }
    //所属科目
    if(_model.subject && _model.subject.length > 0){
        _subject = [NSString stringWithFormat:__kPaperTitleModelCellFrame_subjectFormat,_model.subject];
        CGSize subjectSize = [_subject boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                    options:STR_SIZE_OPTIONS
                                                 attributes:@{NSFontAttributeName : _subjectFont}
                                                    context:nil].size;
        y = (y <= __kPaperTitleModelCellFrame_top ? __kPaperTitleModelCellFrame_top : y + __kPaperTitleModelCellFrame_marginV);
        _subjectFrame = CGRectMake(x, y, subjectSize.width, subjectSize.height);
        y = CGRectGetMaxY(_subjectFrame);
    }
    //行高
    _cellHeight = y + __kPaperTitleModelCellFrame_bottom;
}

@end
