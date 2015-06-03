//
//  PaperSegmentModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/1.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperSegmentModelCellFrame.h"
#import "PaperSegmentModel.h"
#import "AppConstants.h"

#define __kPaperSegmentModelCellFrame_top 10//顶部间距
#define __kPaperSegmentModelCellFrame_bottom 10//底部间距
#define __kPaperSegmentModelCellFrame_left 10//左边间距
#define __kPaperSegmentModelCellFrame_right 10//右边间距

#define __kPaperSegmentModelCellFrame_marginH 2//水平间距
//试卷分段数据模型CellFrame实现
@implementation PaperSegmentModelCellFrame
-(instancetype)init{
    if(self = [super init]){
        _subjectFont = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _totalFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    }
    return self;
}

#pragma mark  设置数据模型
-(void)setModel:(PaperSegmentModel *)model{
    _model = model;
    _subjectFrame = _totalFrame = CGRectZero;
    //
    if(!_model)return;
    NSLog(@"设置试卷分段数据...");
    _subject = _model.subjectName;
    CGFloat width = SCREEN_WIDTH, x = __kPaperSegmentModelCellFrame_left, y = __kPaperSegmentModelCellFrame_top,
    maxWidth = width = __kPaperSegmentModelCellFrame_right, maxHeight = 0;
    //科目
    if(_subject && _subject.length > 0){
        CGSize subjectSize = [_subject boundingRectWithSize:CGSizeMake(maxWidth - x, CGFLOAT_MAX)
                                                    options:STR_SIZE_OPTIONS
                                                 attributes:@{NSFontAttributeName : _subjectFont}
                                                    context:nil].size;
        if(maxHeight < subjectSize.height){
            maxHeight = subjectSize.height;
        }
        _subjectFrame = CGRectMake(x, y, subjectSize.width, subjectSize.height);
        x = CGRectGetMaxX(_subjectFrame) + __kPaperSegmentModelCellFrame_marginH;
    }
    //统计
    _total = [NSString stringWithFormat:@"(%d)", _model.total];
    CGSize totalSize = [_total boundingRectWithSize:CGSizeMake(maxWidth - x, CGFLOAT_MAX)
                                            options:STR_SIZE_OPTIONS
                                         attributes:@{NSFontAttributeName : _totalFont}
                                            context:nil].size;
    if(maxHeight < totalSize.height){
        maxHeight = totalSize.height;
    }
    _totalFrame = CGRectMake(x, y + (maxHeight - totalSize.height)/2, totalSize.width, totalSize.height);
    //}
    //行高
    _cellHeight =  y + maxHeight + __kPaperSegmentModelCellFrame_bottom;
}

@end
