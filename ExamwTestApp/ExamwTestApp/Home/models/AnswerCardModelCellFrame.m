//
//  AnswerCardModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AnswerCardModelCellFrame.h"
#import "AnswerCardModel.h"
#import "UIColor+Hex.h"

#define __kAnswerCardModelCellFrame_width 38//固定宽度
#define __kAnswerCardModelCellFrame_height 35//固定高度

#define __kAnswerCardModelCellFrame_hasColor 0x1E90FF//已做
#define __kAnswerCardModelCellFrame_nonColor 0xFFFFFF//未做
#define __kAnswerCardModelCellFrame_rightColor 0x008B00//做对
#define __kAnswerCardModelCellFrame_errorColor 0xFF0000//做错
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
    //序号
    _order = [NSString stringWithFormat:@"%d", (int)(_model.order + 1)];
    _orderFrame = CGRectMake(0, 0, __kAnswerCardModelCellFrame_width, __kAnswerCardModelCellFrame_height);
    //背景色
    switch (_model.status) {
        case 0:{//未做
            _orderBgColor = [UIColor colorWithHex:__kAnswerCardModelCellFrame_nonColor];
            break;
        }
        case 1:{//做对
            _orderBgColor = [UIColor colorWithHex:(_model.displayAnswer ? __kAnswerCardModelCellFrame_rightColor : __kAnswerCardModelCellFrame_hasColor)];            break;
        }
        case 2:{
            _orderBgColor = [UIColor colorWithHex:(_model.displayAnswer ? __kAnswerCardModelCellFrame_errorColor : __kAnswerCardModelCellFrame_hasColor)];
            break;
        }
    }
}

#pragma mark 固定尺寸
+(CGSize)cellSize{
    return CGSizeMake(__kAnswerCardModelCellFrame_width, __kAnswerCardModelCellFrame_height);
}
@end
