//
//  PaperInfoModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperInfoModelCellFrame.h"
#import "PaperInfoModel.h"

#import "AppConstants.h"

#define __kPaperInfoModelCellFrame_top 10//顶部间距
#define __kPaperInfoModelCellFrame_bottom 10//底部间距
#define __kPaperInfoModelCellFrame_left 10//左边间距
#define __kPaperInfoModelCellFrame_right 5//右边间距
#define __kPaperInfoModelCellFrame_marginV 5//纵向间距
#define __kPaperInfoModelCellFrame_marginH 15//横向间距

#define __kPaperInfoModelCellFrame_subjectFormate @"科目:%@"//
#define __kPaperInfoModelCellFrame_totalFormate @"试题:%d"//
//试卷信息数据模型的CellFrame实现
@implementation PaperInfoModelCellFrame

#pragma mark 重置初始化
-(instancetype)init{
    if(self = [super init]){
        //设置试卷标题字体
        _titleFont = [AppConstants globalListFont];
        //设置所属科目字体
        _subjectFont = [AppConstants globalListSubFont];
        //[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        //设置试题总数字体
        _totalFont = _subjectFont;
        //设置创建时间字体
        _createTimeFont = _subjectFont;
    }
    return self;
}

//设置数据模型
-(void)setModel:(PaperInfoModel *)model{
    _model = model;
    //重置
    _titleFrame = _subjectFrame = _totalFrame = _createTimeFrame = CGRectZero;
    //
    if(!_model)return;
    NSLog(@"设置试卷信息数据模型...");
    CGFloat maxWith = SCREEN_WIDTH - __kPaperInfoModelCellFrame_right;
    //
    CGFloat x = __kPaperInfoModelCellFrame_left, y = __kPaperInfoModelCellFrame_top;
    //试卷标题(第1行)
    _title = _model.name;
    if(_title && _title.length > 0){
        CGSize titleSize = [_title boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                options:STR_SIZE_OPTIONS
                                             attributes:@{NSFontAttributeName : _titleFont}
                                                context:nil].size;
        _titleFrame = CGRectMake(x, y, titleSize.width, titleSize.height);
        y = CGRectGetMaxY(_titleFrame);
    }
    //所属科目(第2行)
    if(_model.subject && _model.subject.length > 0){
        _subject = [NSString stringWithFormat:__kPaperInfoModelCellFrame_subjectFormate,_model.subject];
        CGSize subjectSize = [_subject boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                    options:STR_SIZE_OPTIONS
                                                 attributes:@{NSFontAttributeName : _subjectFont}
                                                    context:nil].size;
        y = (y <= __kPaperInfoModelCellFrame_top ? __kPaperInfoModelCellFrame_top : y + __kPaperInfoModelCellFrame_marginV);
        _subjectFrame = CGRectMake(x, y, subjectSize.width, subjectSize.height);
        y = CGRectGetMaxY(_subjectFrame);
    }
    //(第3行)
    y = (y <= __kPaperInfoModelCellFrame_top ? __kPaperInfoModelCellFrame_top : y + __kPaperInfoModelCellFrame_marginV);
    CGFloat maxHeight = 0;
    //试题总数
    if(_model.total > 0){
        _total = [NSString stringWithFormat:__kPaperInfoModelCellFrame_totalFormate, (int)_model.total];
        CGSize totalSize = [_total boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                options:STR_SIZE_OPTIONS
                                             attributes:@{NSFontAttributeName : _totalFont}
                                                context:nil].size;
        if(maxHeight < totalSize.height){
            maxHeight = totalSize.height;
        }
        _totalFrame = CGRectMake(x, y, totalSize.width, totalSize.height);
        x = CGRectGetMaxX(_totalFrame);
    }
    //创建时间
    _createTime = _model.createTime;
    if(_createTime && _createTime.length > 0){
        x = (x <= __kPaperInfoModelCellFrame_left ? __kPaperInfoModelCellFrame_left : x + __kPaperInfoModelCellFrame_marginH);
        if(_createTime.length > 10){
            _createTime =  [_createTime substringToIndex:10];
        }
        CGSize createTimeSize = [_createTime boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                          options:STR_SIZE_OPTIONS
                                                       attributes:@{NSFontAttributeName : _createTimeFont}
                                                          context:nil].size;
        if(maxHeight < createTimeSize.height){
            maxHeight = createTimeSize.height;
        }
        _createTimeFrame = CGRectMake(x, y, createTimeSize.width, createTimeSize.height);
    }
    //行高
    _cellHeight = y + maxHeight + __kPaperInfoModelCellFrame_bottom;
    
}
@end
