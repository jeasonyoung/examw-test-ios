//
//  ProductData.h
//  ExamApp
//
//  Created by jeasonyoung on 15/4/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"
//产品数据
@interface ProductData : NSObject<JSONSerialize>
//产品ID
@property(nonatomic,copy)NSString *code;
//产品名称
@property(nonatomic,copy)NSString *name;
//所属地区
@property(nonatomic,copy)NSString *areaName;
//产品原价
@property(nonatomic,copy)NSNumber *price;
//产品优惠价
@property(nonatomic,copy)NSNumber *discount;
//试卷总数
@property(nonatomic,assign)NSInteger paperTotal;
//试题总数
@property(nonatomic,assign)NSInteger itemTotal;
//排序号
@property(nonatomic,assign)NSInteger orderNo;
//初始化
-(instancetype)initWithDict:(NSDictionary *)dict;
@end
