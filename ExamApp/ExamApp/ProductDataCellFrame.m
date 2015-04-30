//
//  ProductDataRect.m
//  ExamApp
//
//  Created by jeasonyoung on 15/4/15.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import "AppConstants.h"
#import "ProductDataCellFrame.h"
#import "ProductData.h"

#import "NSString+Size.h"
#import "UIColor+Hex.h"

#define __kProductDataCellFrame_top 5//顶部间距
#define __kProductDataCellFrame_bottom 5//底部间距
#define __kProductDataCellFrame_left 5//左边间距
#define __kProductDataCellFrame_right 5//右边间距

#define __kProductDataCellFrame_marginMin 3//
#define __kProductDataCellFrame_marginMax 10//

#define __kProductDataCellFrame_productFontSize __kAppConstants_fontSize//标题字体
#define __kProductDataCellFrame_fontSize (__kAppConstants_fontSize-2)//内容字体

#define __kProductDataCellFrame_area @"所属地区:%@"//所属地区
#define __kProductDataCellFrame_price @"原价:%.1f"//
#define __kProductDataCellFrame_priceColor 0xFF0000//
#define __kProductDataCellFrame_discount @"优惠价:%.1f"//
#define __kProductDataCellFrame_discount_loc 4//
#define __kProductDataCellFrame_papers @"试卷总数:%d"//
#define __kProductDataCellFrame_papers_loc 5//
#define __kProductDataCellFrame_items @"试题总数:%d"
#define __kProductDataCellFrame_items_loc 5//
#define __kProductDataCellFrame_numFontColor 0x32CD32//

//#define __kProductDataCellFrame_width (320-__kProductDataCellFrame_left-__kProductDataCellFrame_right)//行宽
//产品数据尺寸成员变量
@interface ProductDataCellFrame (){
    UIFont *_font;
    UIColor *_numFontColor;
}
@end
//产品数据尺寸实现
@implementation ProductDataCellFrame
#pragma mark 重载构造函数
-(instancetype)init{
    if(self = [super init]){
        _font = [UIFont systemFontOfSize:__kProductDataCellFrame_fontSize];
        _numFontColor = [UIColor colorWithHex:__kProductDataCellFrame_numFontColor];
    }
    return self;
}
//产品数据赋值
-(void)setData:(ProductData *)data{
    _data = data;
    //
    NSNumber *ty = [NSNumber numberWithFloat:__kProductDataCellFrame_top];
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds) - __kProductDataCellFrame_left - __kProductDataCellFrame_right;
    //产品
    [self setupProductFrameWithWidth:width OutY:&ty];
    //所属地区
    [self setupAreaFrameWithWidth:width OutY:&ty];
    //原价与优惠价
    [self setupPriceDiscountFrameWithWidth:width OutY:&ty];
    //试卷与试题
    [self setupPapersItemsFrameWithWidth:width OutY:&ty];
    //行高
    _rowHeight = ty.floatValue + __kProductDataCellFrame_bottom;
}
//产品标题
-(void)setupProductFrameWithWidth:(CGFloat)width OutY:(NSNumber **)ty{
    //产品字体
    _productFont = [UIFont boldSystemFontOfSize:__kProductDataCellFrame_productFontSize];
    //产品标题
    _product = (_data && _data.name) ? _data.name : @"";
    //产品标题尺寸
    CGSize p_size = [_product sizeWithFont:_productFont
                         constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];
    //frame
    _productFrame = CGRectMake(__kProductDataCellFrame_left, (*ty).floatValue, width, p_size.height);
    //输出y
    *ty = [NSNumber numberWithFloat:CGRectGetMaxY(_productFrame)];
}
//所属地区
-(void)setupAreaFrameWithWidth:(CGFloat)width OutY:(NSNumber **)ty{
    //地区名称
    _area = [NSString stringWithFormat:__kProductDataCellFrame_area,((_data && _data.areaName) ? _data.areaName : @"")];
    //地区字体
    _areaFont = _font;
    //地区尺寸
    CGSize size = [_area sizeWithFont:_areaFont
                    constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
    //frame
    _areaFrame = CGRectMake(__kProductDataCellFrame_left, (*ty).floatValue + __kProductDataCellFrame_marginMin, width, size.height);
    //输出y
    *ty = [NSNumber numberWithFloat:CGRectGetMaxY(_areaFrame)];
}
//原价与优惠价
-(void)setupPriceDiscountFrameWithWidth:(CGFloat)width OutY:(NSNumber **)ty{
    CGFloat y = (*ty).floatValue + __kProductDataCellFrame_marginMin,maxHeight = 0;
    //原价
    NSString *priceText=[NSString stringWithFormat:__kProductDataCellFrame_price,((_data && _data.price) ? _data.price.floatValue : 0)];
    //设置原价尺寸
    CGSize priceSize = [priceText sizeWithFont:_font
                             constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
    maxHeight = priceSize.height;
    //原价frame
    _priceFrame = CGRectMake(__kProductDataCellFrame_left, y, priceSize.width, priceSize.height);
    _price = [[NSMutableAttributedString alloc]initWithString:priceText];
    //设置字体
    [_price addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, priceText.length)];
    //设置颜色
    [_price addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:__kProductDataCellFrame_priceColor] range:NSMakeRange(0, priceText.length)];
    //设置中划线
    [_price addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid|NSUnderlineStyleSingle) range:NSMakeRange(0, priceText.length)];
    
    
    //优惠价
    NSString *discountText = [NSString stringWithFormat:__kProductDataCellFrame_discount,((_data && _data.discount) ? _data.discount.floatValue : 0)];
    //优惠价最大宽度
    CGFloat maxDiscountWidth = width - CGRectGetMaxX(_priceFrame) - __kProductDataCellFrame_marginMax;
    //优惠价尺寸
    CGSize discountSize = [discountText sizeWithFont:_font
                                   constrainedToSize:CGSizeMake(maxDiscountWidth, CGFLOAT_MAX)
                                       lineBreakMode:NSLineBreakByWordWrapping];
    if(maxHeight < discountSize.height){
        maxHeight = discountSize.height;
    }
    //优惠价frame
    _discountFrame = CGRectMake(CGRectGetMaxX(_priceFrame) + __kProductDataCellFrame_marginMax, y, discountSize.width, discountSize.height);
    _discount = [[NSMutableAttributedString alloc]initWithString:discountText];
    //设置字体
    [_discount addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, discountText.length)];
    //设置颜色
    [_discount addAttribute:NSForegroundColorAttributeName value:_numFontColor
                      range:NSMakeRange(__kProductDataCellFrame_discount_loc, discountText.length - __kProductDataCellFrame_discount_loc)];
    //输出y
    *ty = [NSNumber numberWithFloat:((*ty).floatValue + maxHeight)];
}
//试卷与试题
-(void)setupPapersItemsFrameWithWidth:(CGFloat)width OutY:(NSNumber **)ty{
    CGFloat y = (*ty).floatValue + __kProductDataCellFrame_marginMin,maxHeight = 0;
    //试卷数量
    NSString *papersText = [NSString stringWithFormat:__kProductDataCellFrame_papers,(_data ? (int)_data.paperTotal : 0)];
    //试卷数量尺寸
    CGSize papersSize = [papersText sizeWithFont:_font
                               constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                   lineBreakMode:NSLineBreakByWordWrapping];
    maxHeight = papersSize.height;
    //试卷数量Frame
    _papersFrame = CGRectMake(__kProductDataCellFrame_left, y, papersSize.width, papersSize.height);
    _papers = [[NSMutableAttributedString alloc]initWithString:papersText];
    //设置字体
    [_papers addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, papersText.length)];
    //设置颜色
    [_papers addAttribute:NSForegroundColorAttributeName value:_numFontColor
                    range:NSMakeRange(__kProductDataCellFrame_papers_loc, papersText.length - __kProductDataCellFrame_papers_loc)];
    
    //试题数量
    NSString *itemsText = [NSString stringWithFormat:__kProductDataCellFrame_items,(_data ? (int)_data.itemTotal : 0)];
    //试题数量最大宽度
    CGFloat maxItemsWidth = width - CGRectGetMaxX(_papersFrame) - __kProductDataCellFrame_marginMax;
    //试题数量尺寸
    CGSize itemsSize = [itemsText sizeWithFont:_font
                             constrainedToSize:CGSizeMake(maxItemsWidth, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
    if(maxHeight < itemsSize.height){
        maxHeight = itemsSize.height;
    }
    //试题数量frame
    _itemsFrame = CGRectMake(CGRectGetMaxX(_papersFrame) + __kProductDataCellFrame_marginMax, y, itemsSize.width, itemsSize.height);
    _items = [[NSMutableAttributedString alloc]initWithString:itemsText];
    //设置字体
    [_items addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, itemsText.length)];
    //设置颜色
    [_items addAttribute:NSForegroundColorAttributeName value:_numFontColor
                    range:NSMakeRange(__kProductDataCellFrame_items_loc, itemsText.length - __kProductDataCellFrame_items_loc)];
    //输出y
    *ty = [NSNumber numberWithFloat:((*ty).floatValue + maxHeight)];
}
@end
