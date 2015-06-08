//
//  PaperItemOptModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemOptModelCellFrame.h"
#import "PaperItemOptModel.h"
#import "PaperItemModel.h"

#import "EMStringStylingConfiguration.h"
#import "NSString+EMAdditions.h"

#import "AppConstants.h"

#define __kPaperItemOptModelCellFrame_top 10//顶部间距
#define __kPaperItemOptModelCellFrame_bottom 10//底部间距
#define __kPaperItemOptModelCellFrame_left 10//左边间距
#define __kPaperItemOptModelCellFrame_right 5//右边间距

#define __kPaperItemOptModelCellFrame_marginH 2//横向间距

#define __kPaperItemOptModelCellFrame_opt_singleNormal @"option_single_normal.png"//单选
#define __kPaperItemOptModelCellFrame_opt_singleSelected @"option_single_selected.png"//单选选中
#define __kPaperItemOptModelCellFrame_opt_multyNormal @"option_multy_normal.png"//多选
#define __kPaperItemOptModelCellFrame_opt_multySelected @"option_multy_selected.png"//多选选中
#define __kPaperItemOptModelCellFrame_opt_error @"option_error.png"//错误
#define __kPaperItemOptModelCellFrame_opt_right @"option_right.png"//正确

#define __kPaperItemOptModelCellFrame_opt_iconWith 22//icon的宽
#define __kPaperItemOptModelCellFrame_opt_iconHeight 22//icon的高

//试题选项数据模型成员变量
@interface PaperItemOptModelCellFrame (){
    UIFont *_font;
}
@end
//试题选项数据模型实现
@implementation PaperItemOptModelCellFrame

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        //字体
        _font = [AppConstants globalPaperItemFont];
    }
    return self;
}

#pragma mark 设置数据模型
-(void)setModel:(PaperItemOptModel *)model{
    _model = model;
    _isSelected = NO;
    _iconFrame = _contentFrame = CGRectZero;
    if(!_model || !_model.content)return;
    NSLog(@"设置试题选项数据模型[%@]...",_model);
    //判断是否被选中
    if(_model.Id && _model.myAnswers && _model.myAnswers.length > 0){
        NSRange range = [_model.myAnswers rangeOfString:_model.Id];
        _isSelected = (range.location != NSNotFound);
    }
    CGFloat x = __kPaperItemOptModelCellFrame_left,y = __kPaperItemOptModelCellFrame_top,
        maxWith = SCREEN_WIDTH - __kPaperItemOptModelCellFrame_right;
    //选项图标
    [self setupOptIconWithPoint:CGPointMake(x, y)];
    CGFloat maxHeight = __kPaperItemOptModelCellFrame_opt_iconHeight;
    //内容
    NSMutableAttributedString *contentAttri = [[NSMutableAttributedString alloc] initWithAttributedString:[_model.content attributedString]];
    NSRange allRange = NSMakeRange(0, contentAttri.length);
    [contentAttri addAttribute:NSFontAttributeName value:_font range:allRange];
    _content = contentAttri;
    //内容尺寸
    x = (CGRectEqualToRect(_iconFrame, CGRectZero) ? x : CGRectGetMaxX(_iconFrame) +__kPaperItemOptModelCellFrame_marginH);
    CGSize contentSize = [_content boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                options:STR_SIZE_OPTIONS
                                                context:nil].size;
    if(maxHeight < contentSize.height){
        maxHeight = contentSize.height;
    }
    _contentFrame = CGRectMake(x, y, contentSize.width, contentSize.height);
    //行高
    _cellHeight =  y + maxHeight + __kPaperItemOptModelCellFrame_bottom;
}
//选项图标
-(void)setupOptIconWithPoint:(CGPoint)p{
    if(_model.itemType == PaperItemTypeSingle){//单选
        _icon = [UIImage imageNamed:__kPaperItemOptModelCellFrame_opt_singleNormal];
    }else{//多选
        _icon = [UIImage imageNamed:__kPaperItemOptModelCellFrame_opt_multyNormal];
    }
    //选中
    if(_isSelected){
        _icon = [UIImage imageNamed:(_model.itemType == PaperItemTypeSingle ? __kPaperItemOptModelCellFrame_opt_singleSelected : __kPaperItemOptModelCellFrame_opt_multySelected)];
     
        //显示答案
        if(_model.display && _model.Id && _model.rightAnswers){
            BOOL isRight = NO;
            //是否选对
            if(_model.rightAnswers){
                NSRange range = [_model.rightAnswers rangeOfString:_model.Id];
                isRight = (range.location != NSNotFound);
            }
            if(isRight){//选对
                _icon = [UIImage imageNamed:__kPaperItemOptModelCellFrame_opt_right];
            }else{//选错
                _icon = [UIImage imageNamed:__kPaperItemOptModelCellFrame_opt_error];
            }
        }
    }
    //尺寸
    _iconFrame = CGRectMake(p.x, p.y, __kPaperItemOptModelCellFrame_opt_iconWith, __kPaperItemOptModelCellFrame_opt_iconHeight);
}
@end
