//
//  ProductDataRect.h
//  ExamApp
//
//  Created by jeasonyoung on 15/4/15.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ProductData;
//产品数据尺寸
@interface ProductDataCellFrame : NSObject
//产品Frame
@property(nonatomic,assign,readonly)CGRect productFrame;
//产品名称
@property(nonatomic,copy,readonly)NSString *product;
//产品字体
@property(nonatomic,copy,readonly)UIFont *productFont;
//地区Frame
@property(nonatomic,assign,readonly)CGRect areaFrame;
//地区
@property(nonatomic,copy,readonly)NSString *area;
//地区字体
@property(nonatomic,copy,readonly)UIFont *areaFont;
//原价Frame
@property(nonatomic,assign,readonly)CGRect priceFrame;
//原价
@property(nonatomic,copy,readonly)NSMutableAttributedString *price;
//优惠价Frame
@property(nonatomic,assign,readonly)CGRect discountFrame;
//优惠价
@property(nonatomic,copy,readonly)NSMutableAttributedString *discount;
//试卷数Frame
@property(nonatomic,assign,readonly)CGRect papersFrame;
//试卷数
@property(nonatomic,copy,readonly)NSMutableAttributedString *papers;
//试题数Frame
@property(nonatomic,assign,readonly)CGRect itemsFrame;
//试题数
@property(nonatomic,copy,readonly)NSMutableAttributedString *items;
//行高
@property(nonatomic,assign,readonly)CGFloat rowHeight;
//产品数据
@property(nonatomic,copy)ProductData *data;
@end
