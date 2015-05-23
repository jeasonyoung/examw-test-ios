//
//  PaperStructureModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/23.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperStructureModel.h"
#import "PaperItemModel.h"

#define __kPaperStructureModel_keys_code @"id"//试卷结构ID
#define __kPaperStructureModel_keys_title @"title"//试卷结构标题
#define __kPaperStructureModel_keys_desc @"description"//试卷结构描述
#define __kPaperStructureModel_keys_type @"type"//题型
#define __kPaperStructureModel_keys_total @"total"//试题总数
#define __kPaperStructureModel_keys_score @"score"//每题得分
#define __kPaperStructureModel_keys_min @"min"//每题最少得分
#define __kPaperStructureModel_keys_ratio @"ratio"//分数比例
#define __kPaperStructureModel_keys_order @"orderNo"//排序号
#define __kPaperStructureModel_keys_items @"items"//试题集合
#define __kPaperStructureModel_keys_children @"children"//子结构数组集合

//试卷结构数据模型实现
@implementation PaperStructureModel

#pragma mark 初始化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if((self = [super init]) && dict && dict.count > 0){
        NSLog(@"试卷结构反序列化...");
        NSArray *keys = dict.allKeys;
        //试卷结构ID
        if([keys containsObject:__kPaperStructureModel_keys_code]){
            id value = [dict objectForKey:__kPaperStructureModel_keys_code];
            _code = (value == [NSNull null] ? @"" : value);
        }
        //试卷结构标题
        if([keys containsObject:__kPaperStructureModel_keys_title]){
            id value = [dict objectForKey:__kPaperStructureModel_keys_title];
            _title = (value == [NSNull null] ? @"" : value);
        }
        //试卷结构描述
        if([keys containsObject:__kPaperStructureModel_keys_desc]){
            id value = [dict objectForKey:__kPaperStructureModel_keys_desc];
            _desc = (value == [NSNull null] ? @"" : value);
        }
        //题型
        if([keys containsObject:__kPaperStructureModel_keys_type]){
            id value = [dict objectForKey:__kPaperStructureModel_keys_type];
            _type = (value == [NSNull null] ? 0 : [(NSNumber *)value integerValue]);
        }
        //试题总数
        if([keys containsObject:__kPaperStructureModel_keys_total]){
            id value = [dict objectForKey:__kPaperStructureModel_keys_total];
            _total = (value == [NSNull null] ? 0 : [(NSNumber *)value integerValue]);
        }
        //每题得分
        if([keys containsObject:__kPaperStructureModel_keys_score]){
            id value = [dict objectForKey:__kPaperStructureModel_keys_score];
            _score = (value == [NSNull null] ? @0 : value);
        }
        //每题最少得分
        if([keys containsObject:__kPaperStructureModel_keys_min]){
            id value = [dict objectForKey:__kPaperStructureModel_keys_min];
            _min = (value == [NSNull null] ? @0 : value);
        }
        //分数比例
        if([keys containsObject:__kPaperStructureModel_keys_ratio]) {
            id value = [dict objectForKey:__kPaperStructureModel_keys_ratio];
            _ratio = (value == [NSNull null] ? @0 : value);
        }
        //排序号
        if([keys containsObject:__kPaperStructureModel_keys_order]) {
            id value = [dict objectForKey:__kPaperStructureModel_keys_order];
            _order = (value == [NSNull null] ? 0 : [(NSNumber *)value integerValue]);
        }
        //试题集合
        if([keys containsObject:__kPaperStructureModel_keys_items]){
            id value = [dict objectForKey:__kPaperStructureModel_keys_items];
            if((value != [NSNull null]) && [value isKindOfClass:[NSArray class]]){
                PaperItemModel *model = [[PaperItemModel alloc]init];
                _items = [model deserializeWithJSONArrays:((NSArray *)value)];
            }
        }
        //子结构数组集合
        if([keys containsObject:__kPaperStructureModel_keys_children]){
            id value = [dict objectForKey:__kPaperStructureModel_keys_children];
            if((value != [NSNull null]) && [value isKindOfClass:[NSArray class]]){
                _children = [self deserializeWithJSONArrays:((NSArray *)value)];
            }
        }
    }
    return self;
}

#pragma mark 从JSON的Arrays的反序列化为对象数组
-(NSArray *)deserializeWithJSONArrays:(NSArray *)arrays{
    if(arrays && arrays.count > 0){
        NSLog(@"试题从JSONArrays的反序列化为对象数组...");
        NSMutableArray *itemArrays = [NSMutableArray arrayWithCapacity:arrays.count];
        for(NSDictionary *dict in arrays){
            if(!dict || dict.count == 0) continue;
            PaperStructureModel *model = [[PaperStructureModel alloc]initWithDict:dict];
            if(model){
                [itemArrays addObject:model];
            }
        }
        return (itemArrays.count == 0) ? nil : [itemArrays copy];
    }
    return nil;
}

#pragma mark 序列化
-(NSDictionary *)serialize{
    NSLog(@"试题序列化...");
    NSMutableArray *childArrays = nil, *itemArrays = nil;
    if(_children && _children.count > 0){//子试卷结构
        childArrays = [NSMutableArray arrayWithCapacity:_children.count];
        for(PaperStructureModel *model in _children){
            if(!model)continue;
            NSDictionary *dict = [model serialize];
            if(dict && dict.count > 0){
                [childArrays addObject:dict];
            }
        }
    }
    if(_items && _items.count > 0){//试题集合
        itemArrays = [NSMutableArray arrayWithCapacity:_items.count];
        for(PaperItemModel *model in _items){
            if(!model) continue;
            NSDictionary *dict = [model serialize];
            if(dict && dict.count > 0){
                [itemArrays addObject:dict];
            }
        }
    }
    //
    return @{__kPaperStructureModel_keys_code : (_code ? _code : @""),
             __kPaperStructureModel_keys_title : (_title ? _title : @""),
             __kPaperStructureModel_keys_desc : (_desc ? _desc : @""),
             __kPaperStructureModel_keys_type : [NSNumber numberWithInteger:_type],
             __kPaperStructureModel_keys_total : [NSNumber numberWithInteger:_total],
             __kPaperStructureModel_keys_score : (_score ? _score : @0),
             __kPaperStructureModel_keys_min : (_min ? _min : @0),
             __kPaperStructureModel_keys_ratio : (_ratio ? _ratio : @0),
             __kPaperStructureModel_keys_order : [NSNumber numberWithInteger:_order],
             __kPaperStructureModel_keys_items : ((!itemArrays || itemArrays.count == 0) ? @[] : itemArrays),
             __kPaperStructureModel_keys_children : ((!childArrays || childArrays.count == 0) ? @[] : [childArrays copy])};
}

@end
