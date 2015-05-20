//
//  ProductModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/18.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ProductModel.h"

#define __kProductModel_keys_id @"id"//产品ID
#define __kProductModel_keys_name @"name"//产品名称
#define __kProductModel_keys_area @"area"//所属地区
#define __kProductModel_keys_price @"price"//产品原价
#define __kProductModel_keys_discount @"discount"//产品优惠价
#define __kProductModel_keys_content @"content"//产品介绍
#define __kProductModel_keys_papers @"papers"//试卷总数
#define __kProductModel_keys_items @"items"//试题总数
#define __kProductModel_keys_order @"order"//排序号
//产品数据模型实现
@implementation ProductModel
#pragma mark 初始化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if((self = [super init]) && dict && (dict.count > 0)){
        NSArray *keys = dict.allKeys;
        //产品ID
        if([keys containsObject:__kProductModel_keys_id]){
            id value = [dict objectForKey:__kProductModel_keys_id];
            _Id = (value == [NSNull null] ? @"" : value);
        }
        //产品名称
        if([keys containsObject:__kProductModel_keys_name]){
            id value = [dict objectForKey:__kProductModel_keys_name];
            _name = (value == [NSNull null] ? @"" : value);
        }
        //所属地区
        if([keys containsObject:__kProductModel_keys_area]){
            id value = [dict objectForKey:__kProductModel_keys_area];
            _area = (value == [NSNull null] ? @"" : value);
        }
        //产品原价
        if([keys containsObject:__kProductModel_keys_price]){
            id value = [dict objectForKey:__kProductModel_keys_price];
            _price = (value == [NSNull null] ? @0 : value);
        }
        //产品优惠价
        if([keys containsObject:__kProductModel_keys_discount]){
            id value = [dict objectForKey:__kProductModel_keys_discount];
            _discount = (value == [NSNull null] ? @0 : value);
        }
        //产品介绍
        if([keys containsObject:__kProductModel_keys_content]){
            id value = [dict objectForKey:__kProductModel_keys_content];
            _content = (value == [NSNull null] ? @"" : value);
        }
        //试卷总数
        if([keys containsObject:__kProductModel_keys_papers]){
            id value = [dict objectForKey:__kProductModel_keys_papers];
            _papers = (value == [NSNull null] ? @0 : value);
        }
        //试题总数
        if([keys containsObject:__kProductModel_keys_items]){
            id value = [dict objectForKey:__kProductModel_keys_items];
            _items = (value == [NSNull null] ? @0 : value);
        }
        //排序号
        if([keys containsObject:__kProductModel_keys_order]){
            id value = [dict objectForKey:__kProductModel_keys_order];
            _order = (value == [NSNull null] ? @0 : value);
        }
        //
        NSLog(@"完成反序列化产品数据:%@",_name);
    }
    return self;
}
#pragma mark 序列化
-(NSDictionary *)serialize{
    NSLog(@"序列化产品:%@",_name);
    return @{
             __kProductModel_keys_id:(_Id ? _Id : @""),
             __kProductModel_keys_name:(_name ? _name : @""),
             __kProductModel_keys_area:(_area ? _area : @""),
             __kProductModel_keys_price:(_price ? _price : @0),
             __kProductModel_keys_discount:(_discount ? _discount : @0),
             __kProductModel_keys_content:(_content ? _content : @""),
             __kProductModel_keys_papers:(_papers ? _papers : @0),
             __kProductModel_keys_items:(_items ? _items : @0),
             __kProductModel_keys_order:(_order ? _order : @0)
             };
}
@end