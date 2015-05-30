//
//  AnswerCardModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AnswerCardModelCellFrame.h"
#import "AnswerCardModel.h"

#define __kAnswerCardModelCellFrame_top 5//顶部间距
#define __kAnswerCardModelCellFrame_bottom 5//底部间距
#define __kAnswerCardModelCellFrame_left 5//左边间距
#define __kAnswerCardModelCellFrame_right 5//右边间距

#define __kAnswerCardModelCellFrame_width 38//固定宽度
#define __kAnswerCardModelCellFrame_height 35//固定高度
//答题卡试题数据模型CellFrame实现
@implementation AnswerCardModelCellFrame

#pragma mark 重置初始化
-(instancetype)init{
    if(self = [super init]){
        //字体
        _orderFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
    return self;
}

#pragma mark 设置数据模型
-(void)setModel:(AnswerCardModel *)model{
    _model = model;
    _orderFrame = CGRectZero;
    if(!_model)return;
    //CGFloat x = __kAnswerCardModelCellFrame_left, y = __kAnswerCardModelCellFrame_top,
    //maxWith = __kAnswerCardModelCellFrame_width - __kAnswerCardModelCellFrame_right;
    //序号
    _order = [NSString stringWithFormat:@"%d", (int)(_model.order + 1)];
    _orderFrame = CGRectMake(0, 0, __kAnswerCardModelCellFrame_width, __kAnswerCardModelCellFrame_height);
    
//    CGSize orderSize = [_order boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
//                                            options:STR_SIZE_OPTIONS
//                                         attributes:@{NSFontAttributeName : _orderFont}
//                                            context:nil].size;
   // _orderFrame = CGRectMake(x, y, orderSize.width, orderSize.height);
    //状态
    _status = _model.status;
}

#pragma mark 固定尺寸
+(CGSize)cellSize{
    return CGSizeMake(__kAnswerCardModelCellFrame_width, __kAnswerCardModelCellFrame_height);
}
@end
