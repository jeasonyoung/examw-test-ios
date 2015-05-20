//
//  ExamModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/18.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ExamModel.h"
#import "ProductModel.h"

#define __kExamModel_keys_id @"id"//考试ID
#define __kExamModel_keys_code @"code"//考试代码
#define __kExamModel_keys_name @"name"//考试名称
#define __kExamModel_keys_abbr @"abbr"//考试EN简称
#define __kExamModel_keys_products @"products"//产品数据集合

//考试数据模型实现
@implementation ExamModel
#pragma mark 初始化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if((self = [super init]) && dict && (dict.count > 0)){
        NSArray *keys = dict.allKeys;
        //考试ID
        if([keys containsObject:__kExamModel_keys_id]){
            id value = [dict objectForKey:__kExamModel_keys_id];
            _Id = (value == [NSNull null] ? @"" : value);
        }
        //考试代码
        if([keys containsObject:__kExamModel_keys_code]){
            id value = [dict objectForKey:__kExamModel_keys_code];
            _code = (value == [NSNull null] ? @0 : value);
        }
        //考试名称
        if([keys containsObject:__kExamModel_keys_name]){
            id value = [dict objectForKey:__kExamModel_keys_name];
            _name = (value == [NSNull null] ? @"" : value);
        }
        //考试EN简称
        if([keys containsObject:__kExamModel_keys_abbr]){
            id value = [dict objectForKey:__kExamModel_keys_abbr];
            _abbr = (value == [NSNull null] ? @"" : value);
        }
        //产品数据集合
        if([keys containsObject:__kExamModel_keys_products]){
            NSArray *arrays = [dict objectForKey:__kExamModel_keys_products];
            if(arrays && arrays.count > 0){
                NSMutableArray *productsArrays = [NSMutableArray arrayWithCapacity:arrays.count];
                for(NSDictionary *dict in arrays){
                    if(dict && dict.count > 0){
                        ProductModel *pm = [[ProductModel alloc]initWithDict:dict];
                        if(pm){
                            [productsArrays addObject:pm];
                        }
                    }
                }
                //
                if(productsArrays && productsArrays.count > 0){
                    _products = productsArrays;
                }
            }
        }
        NSLog(@"完成反序列化考试:%@",_name);
    }
    return self;
}
//序列化考试数据
-(NSDictionary *)serialize{
    NSLog(@"序列化考试:%@",_name);
    NSMutableArray *productsArrays = [NSMutableArray arrayWithCapacity:(_products ? _products.count : 0)];
    if(_products && _products.count > 0){
        for(ProductModel *p in _products){
            if(!p) continue;
            NSDictionary *dict = [p serialize];
            if(!dict || dict.count == 0) continue;
            [productsArrays addObject:dict];
        }
    }
    //
    return @{
             __kExamModel_keys_id:(_Id ? _Id : @""),
             __kExamModel_keys_code:(_code ? _code : @0),
             __kExamModel_keys_name:(_name ? _name : @""),
             __kExamModel_keys_abbr:(_abbr ? _abbr : @""),
             __kExamModel_keys_products:productsArrays
            };
}
@end