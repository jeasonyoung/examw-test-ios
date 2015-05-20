//
//  ProductModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/20.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ProductModelCellFrame.h"

#import "AppConstants.h"

#define __kProductModelCellFrame_top 10//顶部间距
#define __kProductModelCellFrame_bottom 10//底部间距
#define __kProductModelCellFrame_left 10//左边间距
#define __kProductModelCellFrame_right 5//右边间距
#define __kProductModelCellFrame_marginV 5//纵向间距
#define __kProductModelCellFrame_marginH 10//横向间距

#define __kProductModelCellFrame_area @"地区:%@"//所属地区
#define __kProductModelCellFrame_papers @"试卷数:%d"//试卷数
#define __kProductModelCellFrame_items @"试题数:%d"//试题数
#define __kProductModelCellFrame_originalPrice @"原价:%.1f"//原价
#define __kProductModelCellFrame_discountPrice @"优惠价:%.1f"//优惠价
//产品数据模型CellFrame实现
@implementation ProductModelCellFrame

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        //产品名称字体
        _nameFont = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        //产品简介字体
        _contentFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        //所属地区字体
        _areaFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        //原价字体
        _originalPriceFont = _areaFont;
        //优惠价字体
        _discountPriceFont = _areaFont;
        //试卷总数
        _papersTotalFont = _areaFont;
        //试题总数
        _itemsTotalFont = _areaFont;
    }
    return self;
}

#pragma mark 设置数据模型
-(void)setModel:(ProductModel *)model{
    _model = model;
    //重置初始化
    _nameFrame = _contentFrame = _areaFrame = CGRectZero;
    _originalPriceFrame = _discountPriceFrame = CGRectZero;
    _papersTotalFrame = _itemsTotalFrame = CGRectZero;
    _cellHeight = 0;
    //
    if(!_model)return;
    _name = _model.name;//产品名称
    _content = _model.content;//产品简介
    _area = _model.area;//所属地区
    //
    CGFloat x = __kProductModelCellFrame_left, y = __kProductModelCellFrame_top, maxHeight = 0,
        maxWidth = SCREEN_WIDTH - __kProductModelCellFrame_right;
    //产品名称(第1行)
    if(_name && _name.length > 0){
        CGSize nameSize = [_name boundingRectWithSize:CGSizeMake(maxWidth - x, CGFLOAT_MAX) options:STR_SIZE_OPTIONS
                                           attributes:@{NSFontAttributeName : _nameFont} context:nil].size;
        _nameFrame = CGRectMake(x, y, nameSize.width, nameSize.height);
        y = CGRectGetMaxY(_nameFrame);
    }
    //产品简介(第2行)
    if(_content && _content.length > 0){
        CGSize contentSize = [_content boundingRectWithSize:CGSizeMake(maxWidth - x, CGFLOAT_MAX) options:STR_SIZE_OPTIONS
                                                 attributes:@{NSFontAttributeName : _contentFont} context:nil].size;
        y = (y <= __kProductModelCellFrame_top ? __kProductModelCellFrame_top : y + __kProductModelCellFrame_marginV);
        _contentFrame = CGRectMake(x, y, contentSize.width, contentSize.height);
        y = CGRectGetMaxY(_contentFrame);
    }
    //所属地区(第3行)
    if(_area && _area.length > 0){
        _area = [NSString stringWithFormat:__kProductModelCellFrame_area,_area];
        CGSize areaSize = [_area boundingRectWithSize:CGSizeMake(maxWidth - x, CGFLOAT_MAX) options:STR_SIZE_OPTIONS
                                           attributes:@{NSFontAttributeName : _areaFont} context:nil].size;
        y = (y <= __kProductModelCellFrame_top ? __kProductModelCellFrame_top : y + __kProductModelCellFrame_marginV);
        _areaFrame = CGRectMake(x, y, areaSize.width, areaSize.height);
        y = CGRectGetMaxY(_areaFrame);
    }
    //固定y坐标(第4行)
    x = __kProductModelCellFrame_left;
    y = (y <= __kProductModelCellFrame_top ? __kProductModelCellFrame_top : y + __kProductModelCellFrame_marginV);
    maxHeight = 0;
    //试卷总数(第1列)
    if(_model.papers && _model.papers.integerValue > 0){
        _papersTotal = [NSString stringWithFormat:__kProductModelCellFrame_papers, _model.papers.intValue];
        //x = (x <= __kProductModelCellFrame_left ? __kProductModelCellFrame_left : x + __kProductModelCellFrame_marginH);
        CGSize papersTotalSize = [_papersTotal boundingRectWithSize:CGSizeMake(maxWidth - x, CGFLOAT_MAX)
                                                            options:STR_SIZE_OPTIONS
                                                         attributes:@{NSFontAttributeName : _papersTotalFont}
                                                            context:nil].size;
        if(maxHeight < papersTotalSize.height){
            maxHeight = papersTotalSize.height;
        }
        _papersTotalFrame = CGRectMake(x, y, papersTotalSize.width, papersTotalSize.height);
        x = CGRectGetMaxX(_papersTotalFrame);
    }
    //试题总数(第2列)
    if(_model.items && _model.items.integerValue > 0){
        _itemsTotal = [NSString stringWithFormat:__kProductModelCellFrame_items,_model.items.intValue];
        x = (x <= __kProductModelCellFrame_left ? __kProductModelCellFrame_left : x + __kProductModelCellFrame_marginH);
        CGSize itemsTotalSize = [_itemsTotal boundingRectWithSize:CGSizeMake(maxWidth - x, CGFLOAT_MAX)
                                                          options:STR_SIZE_OPTIONS
                                                       attributes:@{NSFontAttributeName : _itemsTotalFont}
                                                          context:nil].size;
        if(maxHeight < itemsTotalSize.height){
            maxHeight = itemsTotalSize.height;
        }
        _itemsTotalFrame = CGRectMake(x, y, itemsTotalSize.width, itemsTotalSize.height);
        x = CGRectGetMaxX(_itemsTotalFrame);
    }
    //原价(第3列)
    if(_model.price && _model.price.floatValue >= 0){
        _originalPrice = [NSString stringWithFormat:__kProductModelCellFrame_originalPrice, _model.price.floatValue];
        x = (x <= __kProductModelCellFrame_left ? __kProductModelCellFrame_left : x + __kProductModelCellFrame_marginH);
        CGSize originalPriceSize = [_originalPrice boundingRectWithSize:CGSizeMake(maxWidth - x, CGFLOAT_MAX)
                                                                options:STR_SIZE_OPTIONS
                                                             attributes:@{NSFontAttributeName : _originalPriceFont}
                                                                context:nil].size;
        if(maxHeight < originalPriceSize.height){
            maxHeight = originalPriceSize.height;
        }
        _originalPriceFrame = CGRectMake(x, y, originalPriceSize.width, originalPriceSize.height);
        x =  CGRectGetMaxX(_originalPriceFrame);
    }
    //优惠价(第4列)
    if(_model.discount && _model.discount.floatValue >= 0){
        _discountPrice = [NSString stringWithFormat:__kProductModelCellFrame_discountPrice,model.discount.floatValue];
        x = (x <= __kProductModelCellFrame_left ? __kProductModelCellFrame_left : x + __kProductModelCellFrame_marginH);
        CGSize discountPriceSize = [_discountPrice boundingRectWithSize:CGSizeMake(maxWidth - x, CGFLOAT_MAX)
                                                                options:STR_SIZE_OPTIONS
                                                             attributes:@{NSFontAttributeName : _discountPriceFont}
                                                                context:nil].size;
        if(maxHeight < discountPriceSize.height){
            maxHeight = discountPriceSize.height;
        }
        _discountPriceFrame = CGRectMake(x, y, discountPriceSize.width, discountPriceSize.height);
    }
    //重置行高
    _cellHeight = y + maxHeight + __kProductModelCellFrame_bottom;
}
@end
