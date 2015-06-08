//
//  MyModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MySubjectModelCellFrame.h"
#import "MySubjectModel.h"

#import "AppConstants.h"

#define __kMySubjectModelCellFrame_top 10//顶部间距
#define __kMySubjectModelCellFrame_left 10//左边间距
#define __kMySubjectModelCellFrame_bottom 10//底部间距
#define __kMySubjectModelCellFrame_right 10//右边间距

#define __kMySubjectModelCellFrame_marginH 5//横向间距

#define __kMySubjectModelCellFrame_icon @"iconSubject.png"//默认图标
#define __kMySubjectModelCellFrame_iconWidth 20//图标宽度
#define __kMySubjectModelCellFrame_iconHeight 20//图标高度

//我的列表数据模型CellFrame实现
@implementation MySubjectModelCellFrame

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        _subjectFont = [AppConstants globalListFont];
        //[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _totalFont = [AppConstants globalListSubFont];
        //[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    }
    return self;
}

#pragma mark 设置数据模型
-(void)setModel:(MySubjectModel *)model{
    _model = model;
    //重置
    _iconFrame = _subjectFrame = _totalFrame = CGRectZero;
    if(!_model)return;
    //
    CGFloat width = SCREEN_WIDTH, maxWidth = width - __kMySubjectModelCellFrame_right,
        x = __kMySubjectModelCellFrame_left, y = __kMySubjectModelCellFrame_top,maxY = 0;
    //图标
    if(!_model.iconName || _model.iconName.length == 0){
        _icon = [UIImage imageNamed:__kMySubjectModelCellFrame_icon];
    }else{
        _icon = [UIImage imageNamed:_model.iconName];
    }
    _iconFrame = CGRectMake(x, y, __kMySubjectModelCellFrame_iconWidth, __kMySubjectModelCellFrame_iconHeight);
    x = CGRectGetMaxX(_iconFrame) + __kMySubjectModelCellFrame_marginH;
    //科目
    _subject = _model.subject;
    if(_subject && _subject.length > 0){
        CGSize subjectSize = [_subject boundingRectWithSize:CGSizeMake(maxWidth - x, CGFLOAT_MAX)
                                                    options:STR_SIZE_OPTIONS
                                                 attributes:@{NSFontAttributeName : _subjectFont}
                                                    context:nil].size;
        if(CGRectGetHeight(_iconFrame) > subjectSize.height){//图标高于科目文字，文字须纵向居中
            y += (CGRectGetHeight(_iconFrame) - subjectSize.height)/2;
            maxY =  CGRectGetMaxY(_iconFrame);
        }else{//文字高于图标则，图标须纵向居中
            _iconFrame.origin.y += (subjectSize.height - CGRectGetHeight(_iconFrame))/2;
            maxY = y + subjectSize.height;
        }
        _subjectFrame = CGRectMake(x, y, subjectSize.width, subjectSize.height);
        x = CGRectGetMaxX(_subjectFrame) + __kMySubjectModelCellFrame_marginH;
    }
    //统计
    _total = [NSString stringWithFormat:@"%d",(int)_model.total];
    CGSize totalSize = [_total boundingRectWithSize:CGSizeMake(maxWidth - x, CGFLOAT_MAX)
                                            options:STR_SIZE_OPTIONS
                                         attributes:@{NSFontAttributeName : _totalFont}
                                            context:nil].size;
    if(CGRectGetHeight(_subjectFrame) > totalSize.height){//科目高于统计
        y += (CGRectGetHeight(_subjectFrame) - totalSize.height)/2;
    }
    _totalFrame = CGRectMake(x, y, totalSize.width, totalSize.height);
    
    //行高
    _cellHeight = maxY + __kMySubjectModelCellFrame_bottom;
}

@end
