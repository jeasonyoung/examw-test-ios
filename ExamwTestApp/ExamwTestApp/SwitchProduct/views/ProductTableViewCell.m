//
//  ProductTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/20.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ProductTableViewCell.h"

#import "UIColor+Hex.h"

//产品TableViewCell成员变量
@interface ProductTableViewCell (){
    UILabel *_lbName,*_lbContent,*_lbArea,*_lbOriginalPrice,*_lbDiscountPrice,
    *_lbPapersTotal,*_lbItemsTotal;
}
@end
//产品TableViewCell实现
@implementation ProductTableViewCell

#pragma mark 重载初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //产品名称
        _lbName = [[UILabel alloc]init];
        _lbName.textAlignment = NSTextAlignmentLeft;
        _lbName.numberOfLines = 0;
        //产品简介
        _lbContent = [[UILabel alloc]init];
        _lbContent.textAlignment = NSTextAlignmentLeft;
        _lbContent.numberOfLines = 0;
        //所属地区
        _lbArea = [[UILabel alloc]init];
        _lbArea.textAlignment = NSTextAlignmentLeft;
        //_lbArea.numberOfLines = 0;
        //试卷数
        _lbPapersTotal = [[UILabel alloc]init];
        _lbPapersTotal.textAlignment = NSTextAlignmentLeft;
        //试题数
        _lbItemsTotal = [[UILabel alloc]init];
        _lbItemsTotal.textAlignment = NSTextAlignmentLeft;
        //原价
        _lbOriginalPrice = [[UILabel alloc]init];
        _lbOriginalPrice.textAlignment = NSTextAlignmentLeft;
        _lbOriginalPrice.textColor = [UIColor colorWithHex:0xFF6347];
        //优惠价
        _lbDiscountPrice = [[UILabel alloc]init];
        _lbDiscountPrice.textAlignment = NSTextAlignmentLeft;
        _lbDiscountPrice.textColor = [UIColor colorWithHex:0x008B45];
        //
        [self.contentView addSubview:_lbName];
        [self.contentView addSubview:_lbContent];
        [self.contentView addSubview:_lbArea];
        [self.contentView addSubview:_lbPapersTotal];
        [self.contentView addSubview:_lbItemsTotal];
        [self.contentView addSubview:_lbOriginalPrice];
        [self.contentView addSubview:_lbDiscountPrice];
    }
    return self;
}

#pragma mark 加载数据
-(void)loadModelCellFrame:(ProductModelCellFrame *)cellFrame{
    NSLog(@"加载数据[%@]...",cellFrame);
    if(!cellFrame)return;
    //产品名称
    _lbName.text = cellFrame.name;
    _lbName.font = cellFrame.nameFont;
    _lbName.frame = cellFrame.nameFrame;
    //产品简介
    _lbContent.text = cellFrame.content;
    _lbContent.font = cellFrame.contentFont;
    _lbContent.frame = cellFrame.contentFrame;
    //所属地区
    _lbArea.text = cellFrame.area;
    _lbArea.font = cellFrame.areaFont;
    _lbArea.frame = cellFrame.areaFrame;
    //试卷数
    _lbPapersTotal.text = cellFrame.papersTotal;
    _lbPapersTotal.font = cellFrame.papersTotalFont;
    _lbPapersTotal.frame = cellFrame.papersTotalFrame;
    //试题数
    _lbItemsTotal.text = cellFrame.itemsTotal;
    _lbItemsTotal.font = cellFrame.itemsTotalFont;
    _lbItemsTotal.frame = cellFrame.itemsTotalFrame;
    //原价
    //_lbOriginalPrice.text = cellFrame.originalPrice;
    _lbOriginalPrice.font = cellFrame.originalPriceFont;
    _lbOriginalPrice.frame = cellFrame.originalPriceFrame;
    NSString *oriPrice = cellFrame.originalPrice;
    if(oriPrice && oriPrice.length > 0){
        NSMutableAttributedString *oriAttri = [[NSMutableAttributedString alloc]initWithString:oriPrice];
        //中划线
        [oriAttri addAttribute:NSStrikethroughStyleAttributeName
                         value:@(NSUnderlinePatternSolid|NSUnderlineStyleSingle)
                         range:NSMakeRange(0, oriPrice.length)];
        _lbOriginalPrice.attributedText = oriAttri;
    }
    //优惠价
    _lbDiscountPrice.text = cellFrame.discountPrice;
    _lbDiscountPrice.font = cellFrame.discountPriceFont;
    _lbDiscountPrice.frame = cellFrame.discountPriceFrame;
}

#pragma mark 重载选中
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
