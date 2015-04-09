//
//  ProductTableViewCell.m
//  ExamApp
//
//  Created by jeasonyoung on 15/4/8.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ProductTableViewCell.h"
#import "NSString+Size.h"
#import "NSString+Hex.h"
#import "UIColor+Hex.h"

#define __kProductTableViewCell_titleFontSize 13//标题字体
#define __kProductTableViewCell_fontSize 12//内容字体

#define __kProductTableViewCell_top 5//顶部间距
#define __kProductTableViewCell_bottom 5//底部间距
#define __kProductTableViewCell_left 5//左边间距
#define __kProductTableViewCell_right 5//右边间距

#define __kProductTableViewCell_marginMin 3//
#define __kProductTableViewCell_marginMax 10//

#define __kProductTableViewCell_area @"所属地区:%@"//所属地区
#define __kProductTableViewCell_price @"原价:%.1f"//
#define __kProductTableViewCell_priceColor 0xFF0000//
#define __kProductTableViewCell_discount @"优惠价:%.1f"//
#define __kProductTableViewCell_papers @"试卷总数:%d"//
#define __kProductTableViewCell_papers_loc 5//
#define __kProductTableViewCell_items @"试题总数:%d"
#define __kProductTableViewCell_items_loc 5//
#define __kProductTableViewCell_fontColor 0x32CD32//

//产品列表数据成员变量
@interface ProductTableViewCell (){
    UILabel *_lbTitle,*_lbArea,
    *_lbPrice,*_lbDiscount,
    *_lbPapers,*_lbItems;
}
@end

//产品列表数据实现
@implementation ProductTableViewCell
#pragma mark 重构初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self setupInit];
    }
    return self;
}
//初始化
-(void)setupInit{
        //产品名称
        _lbTitle = [[UILabel alloc]init];
        _lbTitle.font = [UIFont boldSystemFontOfSize:__kProductTableViewCell_titleFontSize];
        _lbTitle.numberOfLines = 0;
        _lbTitle.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_lbTitle];
        //字体
        UIFont *font = [UIFont systemFontOfSize:__kProductTableViewCell_fontSize];
        //所属地区
        _lbArea = [[UILabel alloc]init];
        _lbArea.font = font;
        _lbArea.numberOfLines = 0;
        _lbArea.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_lbArea];
        //原价
        _lbPrice = [[UILabel alloc]init];
        _lbPrice.font = font;
        _lbPrice.textColor = [UIColor colorWithHex:__kProductTableViewCell_priceColor];
        _lbPrice.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_lbPrice];
        //优惠价
        _lbDiscount = [[UILabel alloc]init];
        _lbDiscount.font = font;
        _lbDiscount.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_lbDiscount];
        //试卷总数
        _lbPapers = [[UILabel alloc]init];
        _lbPapers.font = font;
        _lbPapers.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_lbPapers];
        //试题总数
        _lbItems = [[UILabel alloc] init];
        _lbItems.font = font;
        _lbItems.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_lbItems];
}
#pragma mark 选中重载
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
#pragma mark 加载数据
-(CGFloat)loadDataWithProduct:(ProductData *)data{
    if(data){
        CGFloat width = CGRectGetWidth(self.frame) - __kProductTableViewCell_left - __kProductTableViewCell_right;
        NSNumber *ty = [NSNumber numberWithFloat:__kProductTableViewCell_top];
        //产品名称
        [self setupWithProduct:data.name X:__kProductTableViewCell_left Width:width OutY:&ty];
        //所属地区
        [self setupWithArea:data.areaName X:__kProductTableViewCell_left Width:width OutY:&ty];
        //价格
        [self setupWithPrice:data.price Discount:data.discount X:__kProductTableViewCell_left Width:width OutY:&ty];
        //试卷数量
        [self setupWithPapers:data.paperTotal Items:data.itemTotal X:__kProductTableViewCell_left Width:width OutY:&ty];
        //重置高度
        CGRect tempFrame = self.frame;
        tempFrame.size.height = ty.floatValue + __kProductTableViewCell_bottom;
        self.frame = tempFrame;
    }
    return CGRectGetHeight(self.frame);
}
//产品名称
-(void)setupWithProduct:(NSString *)p X:(CGFloat)x Width:(CGFloat)w OutY:(NSNumber **)outY{
    if(_lbTitle && p){
        CGSize titleSize = [p sizeWithFont:_lbTitle.font
                             constrainedToSize:CGSizeMake(w, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
        _lbTitle.frame = CGRectMake(x, (*outY).floatValue, w, titleSize.height);
        _lbTitle.text = p;
        *outY = [NSNumber numberWithFloat:CGRectGetMaxY(_lbTitle.frame)];
    }
}
//所属地区
-(void)setupWithArea:(NSString *)area X:(CGFloat)x Width:(CGFloat)w OutY:(NSNumber **)outY{
    if(_lbArea && area){
        NSString *title = [NSString stringWithFormat:__kProductTableViewCell_area,area];
        CGSize titleSize = [title sizeWithFont:_lbArea.font
                                    constrainedToSize:CGSizeMake(w, CGFLOAT_MAX)
                                        lineBreakMode:NSLineBreakByWordWrapping];
        _lbArea.frame = CGRectMake(x, (*outY).floatValue + __kProductTableViewCell_marginMin, w, titleSize.height);
        _lbArea.text = title;
        *outY = [NSNumber numberWithFloat:CGRectGetMaxY(_lbArea.frame)];
    }
}
//价格
-(void)setupWithPrice:(NSNumber *)price Discount:(NSNumber *)discount X:(CGFloat)x Width:(CGFloat)w OutY:(NSNumber **)outY{
    if(_lbPrice && price && _lbDiscount && discount){
        CGFloat y = (*outY).floatValue + __kProductTableViewCell_marginMin, maxHeight = 0;
        //原价
        NSString *priceContent = [NSString stringWithFormat:__kProductTableViewCell_price,price.floatValue];
        CGSize priceContentSize = [priceContent sizeWithFont:_lbPrice.font
                                           constrainedToSize:CGSizeMake(w, CGFLOAT_MAX)
                                               lineBreakMode:NSLineBreakByWordWrapping];
        
        maxHeight = priceContentSize.height;
        _lbPrice.frame = CGRectMake(x, y, priceContentSize.width, priceContentSize.height);
        NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:priceContent];
        [attri addAttribute:NSStrikethroughStyleAttributeName
                      value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle)
                      range:NSMakeRange(0, priceContent.length)];
        _lbPrice.attributedText = attri;
        //优惠价
        w = w - CGRectGetMaxX(_lbPrice.frame) - __kProductTableViewCell_marginMin;
        NSString *discountContent = [NSString stringWithFormat:__kProductTableViewCell_discount,discount.floatValue];
        CGSize discountContentSize = [discountContent sizeWithFont:_lbDiscount.font
                                                 constrainedToSize:CGSizeMake(w, CGFLOAT_MAX)
                                                     lineBreakMode:NSLineBreakByWordWrapping];
        if(maxHeight < discountContentSize.height){
            maxHeight = discountContentSize.height;
        }
        x = CGRectGetMaxX(_lbPrice.frame) +  __kProductTableViewCell_marginMax;
        _lbDiscount.frame = CGRectMake(x, y, discountContentSize.width, discountContentSize.height);
        _lbDiscount.text = discountContent;
        
        *outY = [NSNumber numberWithFloat:(y + maxHeight)];
    }
}
//试卷数量
-(void)setupWithPapers:(NSInteger)papers Items:(NSInteger)items X:(CGFloat)x Width:(CGFloat)w OutY:(NSNumber **)outY{
    if(_lbPapers && _lbItems){
        CGFloat y = (*outY).floatValue + __kProductTableViewCell_marginMin, maxHeight = 0;
        UIColor *fontColor = [UIColor colorWithHex:__kProductTableViewCell_fontColor];
        //试卷数量
        NSString *papersContent = [NSString stringWithFormat:__kProductTableViewCell_papers, (int)papers];
        CGSize papersContentSize = [papersContent sizeWithFont:_lbPapers.font
                                             constrainedToSize:CGSizeMake(w, CGFLOAT_MAX)
                                                 lineBreakMode:NSLineBreakByWordWrapping];
        maxHeight = papersContentSize.height;
        _lbPapers.frame = CGRectMake(x, y, papersContentSize.width, papersContentSize.height);
        
        NSMutableAttributedString *papers_attri = [[NSMutableAttributedString alloc]initWithString:papersContent];
        [papers_attri addAttribute:NSForegroundColorAttributeName
                             value:fontColor
                             range:NSMakeRange(__kProductTableViewCell_papers_loc, papersContent.length - __kProductTableViewCell_papers_loc)];
        _lbPapers.attributedText = papers_attri;
        //试题数量
        w = w - CGRectGetMaxX(_lbPapers.frame) - __kProductTableViewCell_marginMin;
        NSString *itemsContent = [NSString stringWithFormat:__kProductTableViewCell_items,(int)items];
        CGSize itemsContentSize = [itemsContent sizeWithFont:_lbItems.font
                                           constrainedToSize:CGSizeMake(w, CGFLOAT_MAX)
                                               lineBreakMode:NSLineBreakByWordWrapping];
        if(maxHeight < itemsContentSize.height){
            maxHeight = itemsContentSize.height;
        }
        x = CGRectGetMaxX(_lbPapers.frame) +  __kProductTableViewCell_marginMax;
        _lbItems.frame = CGRectMake(x, y, itemsContentSize.width, itemsContentSize.height);
        NSMutableAttributedString *items_attri = [[NSMutableAttributedString alloc]initWithString:itemsContent];
        [items_attri addAttribute:NSForegroundColorAttributeName
                            value:fontColor
                            range:NSMakeRange(__kProductTableViewCell_items_loc, itemsContent.length - __kProductTableViewCell_items_loc)];
        _lbItems.attributedText = items_attri;
        
        *outY = [NSNumber numberWithFloat:(y + maxHeight)];
    }
}
@end
