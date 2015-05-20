//
//  ProductModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/20.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DataModelCellFrame.h"
#import "ProductModel.h"

//产品数据模型CellFrame
@interface ProductModelCellFrame : NSObject<DataModelCellFrame>
//产品名称
@property(nonatomic,copy,readonly)NSString *name;
//产品名称字体
@property(nonatomic,readonly)UIFont *nameFont;
//产品名称Frame
@property(nonatomic,assign,readonly)CGRect nameFrame;

//产品简介
@property(nonatomic,copy,readonly)NSString *content;
//产品简介字体
@property(nonatomic,readonly)UIFont *contentFont;
//产品简介Frame
@property(nonatomic,assign,readonly)CGRect contentFrame;

//所属地区
@property(nonatomic,copy,readonly)NSString *area;
//所属地区字体
@property(nonatomic,readonly)UIFont *areaFont;
//所属地区Frame
@property(nonatomic,assign,readonly)CGRect areaFrame;

//原价
@property(nonatomic,copy,readonly)NSString *originalPrice;
//原价字体
@property(nonatomic,readonly)UIFont *originalPriceFont;
//原价Frame
@property(nonatomic,assign,readonly)CGRect originalPriceFrame;

//优惠价
@property(nonatomic,copy,readonly)NSString *discountPrice;
//优惠价字体
@property(nonatomic,readonly)UIFont *discountPriceFont;
//优惠价Frame
@property(nonatomic,assign,readonly)CGRect discountPriceFrame;

//试卷总数
@property(nonatomic,copy,readonly)NSString *papersTotal;
//试卷总数字体
@property(nonatomic,readonly)UIFont *papersTotalFont;
//试卷总数Frame
@property(nonatomic,assign,readonly)CGRect papersTotalFrame;

//试题总数
@property(nonatomic,copy,readonly)NSString *itemsTotal;
//试题总数字体
@property(nonatomic,readonly)UIFont *itemsTotalFont;
//试题总数Frame
@property(nonatomic,assign,readonly)CGRect itemsTotalFrame;

//行高
@property(nonatomic,assign,readonly)CGFloat cellHeight;

//产品数据
@property(nonatomic,copy)ProductModel *model;
@end