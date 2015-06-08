//
//  MyProductRegModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyProductRegModelCellFrame.h"
#import "AppConstants.h"
#import "MyProductRegModel.h"

#define __kMyProductRegModelCellFrame_top 10//顶部间距
#define __kMyProductRegModelCellFrame_bottom 10//底部间距
#define __kMyProductRegModelCellFrame_left 10//左边间距
#define __kMyProductRegModelCellFrame_right 10//右边间距

#define __kMyProductRegModelCellFrame_marginV 10//纵向间距

#define __kMyProductRegModelCellFrame_height 30//高度

//产品注册数据模型Frame实现
@implementation MyProductRegModelCellFrame

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        //考试名称字体
        _examNameFont = [AppConstants globalListThirdFont];
        //[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        //产品名称字体
        _productNameFont = [AppConstants globalListFont];
        //[UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        //注册码字体
        _productRegCodeFont = [AppConstants globalListSubFont];
        //[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    return self;
}

#pragma mark 设置数据模型
-(void)setModel:(MyProductRegModel *)model{
    _model = model;
    //重置
    _examNameFrame = _productNameFrame = _productRegCodeFrame = CGRectZero;
    if(_model){
        CGFloat maxWith = SCREEN_WIDTH - __kMyProductRegModelCellFrame_right,
        x = __kMyProductRegModelCellFrame_left,y = __kMyProductRegModelCellFrame_top;
        
        //考试名称(第1行)
        _examName = _model.examName;
        if(_examName && _examName.length > 0){
            CGSize examSize = [_examName boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                      options:STR_SIZE_OPTIONS
                                                   attributes:@{NSFontAttributeName : _examNameFont}
                                                      context:nil].size;
            _examNameFrame = CGRectMake(x, y, maxWith - x, examSize.height);
            y = CGRectGetMaxY(_examNameFrame) + __kMyProductRegModelCellFrame_marginV;
        }
        //产品名称(第2行)
        _productName = _model.productName;
        if(_productName && _productName.length > 0){
            CGSize productSize = [_productName boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                            options:STR_SIZE_OPTIONS
                                                         attributes:@{NSFontAttributeName : _productNameFont}
                                                            context:nil].size;
            _productNameFrame = CGRectMake(x, y, maxWith - x, productSize.height);
            y = CGRectGetMaxY(_productNameFrame) + __kMyProductRegModelCellFrame_marginV;
        }
        //注册码(第3行)
        _productRegCodePlaceholder = @"请输入产品注册码";
        _productRegCode = _model.productRegCode;
        _productRegCodeFrame = CGRectMake(x, y, maxWith - x, __kMyProductRegModelCellFrame_height);
        y = CGRectGetMaxY(_productRegCodeFrame) + __kMyProductRegModelCellFrame_marginV;
        //按钮
        CGFloat width = (maxWith - x)/2;
        CGFloat padding = (maxWith - x - width)/2;
        _btnRegisterFrame = CGRectMake(x + padding, y + __kMyProductRegModelCellFrame_marginV,
                                       width, __kMyProductRegModelCellFrame_height);
        //行高
        _cellHeight = CGRectGetMaxY(_btnRegisterFrame) + __kMyProductRegModelCellFrame_bottom;
    }
}
@end
