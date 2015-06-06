//
//  MoreMenuModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MoreMenuModelCellFrame.h"
#import "MoreMenuModel.h"
#import "AppConstants.h"

#define __kMoreMenuModelCellFrame_top 10//顶部间距
#define __kMoreMenuModelCellFrame_left 10//左边间距
#define __kMoreMenuModelCellFrame_bottom 10//底部间距
#define __kMoreMenuModelCellFrame_right 10//右边间距

#define __kMoreMenuModelCellFrame_marginH 10//水平间距

#define __kMoreMenuModelCellFrame_iconWidth 20//图标宽度
#define __kMoreMenuModelCellFrame_iconHeight 20//图标高度

//更多菜单数据模型实现
@implementation MoreMenuModelCellFrame

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        _titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    return self;
}

//设置数据模型
-(void)setModel:(MoreMenuModel *)model{
    _model = model;
    //重置
    _iconFrame = _titleFrame = CGRectZero;
    if(!_model)return;
    //
    CGFloat maxWith = SCREEN_WIDTH - __kMoreMenuModelCellFrame_right, x = __kMoreMenuModelCellFrame_left,
    y = __kMoreMenuModelCellFrame_top;
    //图标
    if(_model.iconName && _model.iconName.length > 0){
        _icon = [UIImage imageNamed:_model.iconName];
        _iconFrame = CGRectMake(x, y, __kMoreMenuModelCellFrame_iconWidth, __kMoreMenuModelCellFrame_iconHeight);
        x = CGRectGetMaxX(_iconFrame) + __kMoreMenuModelCellFrame_marginH;
    }
    //标题
    _title = _model.name;
    if(_title && _title.length > 0){
        CGSize titleSize = [_title boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                options:STR_SIZE_OPTIONS
                                             attributes:@{NSFontAttributeName : _titleFont}
                                                context:nil].size;
        //
        _titleFrame = CGRectMake(x, y, maxWith - x, titleSize.height);
        if(!CGRectEqualToRect(_iconFrame, CGRectZero)){//图标存在
            if(titleSize.height > CGRectGetHeight(_iconFrame)){//文字高于图标，图标下移
                //行高
                _cellHeight = CGRectGetMaxY(_titleFrame) + __kMoreMenuModelCellFrame_bottom;
                //下移偏量
                CGFloat padding = (titleSize.height - CGRectGetHeight(_iconFrame))/2;
                //下移图标
                _iconFrame.origin.y += padding;
            }else{//图标高于文字，文字下移
                //行高
                _cellHeight = CGRectGetMaxY(_iconFrame) + __kMoreMenuModelCellFrame_bottom;
                //下移偏量
                CGFloat padding = (CGRectGetHeight(_iconFrame) - titleSize.height)/2;
                //下移文字
                _titleFrame.origin.y += padding;
            }
        }else{
            _cellHeight = CGRectGetMaxY(_titleFrame) + __kMoreMenuModelCellFrame_bottom;
        }
    }
}

@end
