//
//  ProductData.m
//  ExamApp
//
//  Created by jeasonyoung on 15/4/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ProductData.h"

#define __kProductData_code @"id"//产品ID
#define __kProductData_name @"name"//产品名称
#define __kProductData_areaName @"areaName"//所属地区
#define __kProductData_price @"price"//产品价格
#define __kProductData_discount @"discount"//产品优惠价格
#define __kProductData_paperTotal @"paperTotal"//试卷总数
#define __kProductData_itemTotal @"itemTotal"//试题总数
//产品数据实现
@implementation ProductData
#pragma mark 初始化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if((self = [super init]) && dict && dict.count > 0){
        //产品ID
        if([dict.allKeys containsObject:__kProductData_code]){
            _code = [dict objectForKey:__kProductData_code];
        }
        //产品名称
        if([dict.allKeys containsObject:__kProductData_name]){
            _name = [dict objectForKey:__kProductData_name];
        }
        //所属地区
        if([dict.allKeys containsObject:__kProductData_areaName]){
            _areaName = [dict objectForKey:__kProductData_areaName];
        }
        //产品价格
        if([dict.allKeys containsObject:__kProductData_price]){
           _price = [dict objectForKey:__kProductData_price];
        }
        //产品优惠价格
        if([dict.allKeys containsObject:__kProductData_discount]){
            _discount = [dict objectForKey:__kProductData_discount];
        }
        //试卷总数
        if([dict.allKeys containsObject:__kProductData_paperTotal]){
            NSNumber *total = [dict objectForKey:__kProductData_paperTotal];
            _paperTotal = total.integerValue;
        }
        //试题总数
        if([dict.allKeys containsObject:__kProductData_itemTotal]){
            NSNumber *total = [dict objectForKey:__kProductData_itemTotal];
            _itemTotal = total.integerValue;
        }
    }
    return self;
}
#pragma mark 序列化
-(NSDictionary *)serializeJSON{
    return @{__kProductData_code:(_code ? _code : @""),
             __kProductData_name:(_name ? _name : @""),
             __kProductData_areaName:(_areaName ? _areaName : @""),
             __kProductData_price:(_price ? _price : [NSNumber numberWithFloat:0]),
             __kProductData_discount:(_discount ? _discount : [NSNumber numberWithFloat:0]),
             __kProductData_paperTotal:[NSNumber numberWithInteger:_paperTotal],
             __kProductData_itemTotal:[NSNumber numberWithInteger:_itemTotal]};
}
#pragma mark 重构输出字符串
-(NSString *)description{
    NSDictionary *dict = [self serializeJSON];
    NSError *err = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&err];
    if(err){
        return [super description];
    }
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}
@end
