//
//  SubjectModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/16.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "SubjectModelCellFrame.h"
#import "AppConstants.h"

#define __kSubjectModelCellFrame_top 10//顶部间距
#define __kSubjectModelCellFrame_bottom 10//底部间距
#define __kSubjectModelCellFrame_left 10//左边间距
#define __kSubjectModelCellFrame_right 5//右边间距
#define __kSubjectModelCellFrame_maginMin 10//最小间距

//考试科目数据模型CellFrame实现
@implementation SubjectModelCellFrame

#pragma mark 重置初始化
-(instancetype)init{
    if(self = [super init]){
        _nameFont = [AppConstants globalListFont];
        _totalFont = [AppConstants globalListSubFont];
    }
    return self;
}

#pragma mark 设置数据模型
-(void)setModel:(SubjectModel *)model{
    _model = model;
    //重置
    _nameFrame = _totalFrame = CGRectZero;
    if(!_model)return;
    CGFloat maxWith = SCREEN_WIDTH - __kSubjectModelCellFrame_right, x = __kSubjectModelCellFrame_left,
    y = __kSubjectModelCellFrame_top, maxHeight = 0;
    //科目名称
    _name = _model.name;
    if(_name && _name.length > 0){
        CGSize nameSize = [_name boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                              options:STR_SIZE_OPTIONS
                                           attributes:@{NSFontAttributeName : _nameFont}
                                              context:nil].size;
        maxHeight = nameSize.height;
        _nameFrame = CGRectMake(x, y, nameSize.width, nameSize.height);
        x = CGRectGetMaxX(_nameFrame) + __kSubjectModelCellFrame_maginMin;
    }
    //试卷统计
    _total = [NSString stringWithFormat:@"%d", (int)_model.total];
    if(_total && _total.length > 0){
        CGSize totalSize = [_total boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                options:STR_SIZE_OPTIONS
                                             attributes:@{NSFontAttributeName : _totalFont}
                                                context:nil].size;
        _totalFrame = CGRectMake(x, y, totalSize.width, totalSize.height);
        if(maxHeight < totalSize.height){//统计高于名称
            _nameFrame.origin.y += (totalSize.height - maxHeight)/2;
            maxHeight = totalSize.height;
        }else{//名称高于等于统计
            _totalFrame.origin.y += (maxHeight - totalSize.height)/2;
        }
    }
    //行高
    _cellHeight = y + maxHeight + __kSubjectModelCellFrame_bottom;
}
@end
