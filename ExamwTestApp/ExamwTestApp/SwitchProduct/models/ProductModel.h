//
//  ProductModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/18.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"
//产品数据模型
@interface ProductModel : NSObject<JSONSerialize>
//产品ID
@property(nonatomic,copy)NSString *Id;
//产品名称
@property(nonatomic,copy)NSString *name;
//所属地区
@property(nonatomic,copy)NSString *area;
//产品原价
@property(nonatomic,copy)NSNumber *price;
//产品优惠价
@property(nonatomic,copy)NSNumber *discount;
//产品介绍
@property(nonatomic,copy)NSString *content;
//试卷总数
@property(nonatomic,copy)NSNumber *papers;
//试题总数
@property(nonatomic,copy)NSNumber *items;
//排序号
@property(nonatomic,copy)NSNumber *order;
@end
