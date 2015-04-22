//
//  ProductTableViewCell.m
//  ExamApp
//
//  Created by jeasonyoung on 15/4/8.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ProductTableViewCell.h"
#import "ProductDataCellFrame.h"
//产品列表数据成员变量
@interface ProductTableViewCell (){
    UILabel *_lbProduct,*_lbArea,*_lbPrice,*_lbDiscount, *_lbPapers,*_lbItems;
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
    _lbProduct = [[UILabel alloc]init];
    _lbProduct.numberOfLines = 0;
    _lbProduct.textAlignment = NSTextAlignmentLeft;
    
    //所属地区
    _lbArea = [[UILabel alloc]init];
    _lbArea.numberOfLines = 0;
    _lbArea.textAlignment = NSTextAlignmentLeft;
    
    //原价
    _lbPrice = [[UILabel alloc]init];
    _lbPrice.textAlignment = NSTextAlignmentLeft;
    
    //优惠价
    _lbDiscount = [[UILabel alloc]init];
    _lbDiscount.textAlignment = NSTextAlignmentLeft;
    
    //试卷总数
    _lbPapers = [[UILabel alloc]init];
    _lbPapers.textAlignment = NSTextAlignmentLeft;
    
    //试题总数
    _lbItems = [[UILabel alloc] init];
    _lbItems.textAlignment = NSTextAlignmentLeft;
    
    //添加到容器
    [self.contentView addSubview:_lbProduct];
    [self.contentView addSubview:_lbArea];
    [self.contentView addSubview:_lbPrice];
    [self.contentView addSubview:_lbDiscount];
    [self.contentView addSubview:_lbPapers];
    [self.contentView addSubview:_lbItems];
}

#pragma mark 选中重载
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark 加载数据
-(void)loadDataWithProduct:(ProductDataCellFrame *)cellData{
    if(!cellData)return;
    
    //产品名称
    _lbProduct.frame = cellData.productFrame;
    _lbProduct.font = cellData.productFont;
    _lbProduct.text = cellData.product;
    
    //所属地区
    _lbArea.frame = cellData.areaFrame;
    _lbArea.font = cellData.areaFont;
    _lbArea.text = cellData.area;
    
    //原价
    _lbPrice.frame = cellData.priceFrame;
    _lbPrice.attributedText = cellData.price;
    
    //优惠价
    _lbDiscount.frame = cellData.discountFrame;
    _lbDiscount.attributedText = cellData.discount;
    
    //试卷数量
    _lbPapers.frame = cellData.papersFrame;
    _lbPapers.attributedText = cellData.papers;
    
    //试题数量
    _lbItems.frame = cellData.itemsFrame;
    _lbItems.attributedText = cellData.items;
}
@end
