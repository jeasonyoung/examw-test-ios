//
//  TitleModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "TitleModelCellFrame.h"
#import "TitleModel.h"
#import "AppConstants.h"

#define __kTitleModelCellFrame_top 10//顶部间距
#define __kTitleModelCellFrame_left 10//左边间距
#define __kTitleModelCellFrame_bottom 10//底部间距
#define __kTitleModelCellFrame_right 10//右边间距

//标题数据模型实现
@implementation TitleModelCellFrame

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        _titleFont = [AppConstants globalListFont];
        //[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    return self;
}

#pragma mark 设置数据模型
-(void)setModel:(TitleModel *)model{
    _model = model;
    //重置
    _titleFrame = CGRectZero;
    if(_model){
        _title = _model.title;
        if(_title && _title.length > 0){
            CGFloat maxWidth = SCREEN_WIDTH - __kTitleModelCellFrame_right,
            x = __kTitleModelCellFrame_left,y = __kTitleModelCellFrame_top;
            //
            CGSize titleSize = [_title boundingRectWithSize:CGSizeMake(maxWidth - x, CGFLOAT_MAX)
                                                    options:STR_SIZE_OPTIONS
                                                 attributes:@{NSFontAttributeName : _titleFont}
                                                    context:nil].size;
            _titleFrame = CGRectMake(x, y, maxWidth - x, titleSize.height);
            //行高
            _cellHeight = CGRectGetMaxY(_titleFrame) + __kTitleModelCellFrame_bottom;
        }
    }
}

@end
