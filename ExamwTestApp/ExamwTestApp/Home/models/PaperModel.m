//
//  PaperModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/23.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperModel.h"
#import "PaperStructureModel.h"

#define __kPaperModel_keys_code @"id"//试卷ID
#define __kPaperModel_keys_name @"name"//试卷名称
#define __kPaperModel_keys_desc @"description"//试卷描述信息
#define __kPaperModel_keys_source @"sourceName"//试卷来源
#define __kPaperModel_keys_area @"areaName"//所属地区
#define __kPaperModel_keys_type @"type"//试卷类型
#define __kPaperModel_keys_time @"time"//考试时长
#define __kPaperModel_keys_year @"year"//使用年份
#define __kPaperModel_keys_total @"total"//试题数
#define __kPaperModel_keys_score @"score"//试卷总分
#define __kPaperModel_keys_structures @"structures"//试卷结构

#define __kPaperModel_PaperReviewTypes @[@"历年真题",@"模拟试题",@"预测试题",@"练习题",@"章节练习",@"每日一练"]//试卷类型
//试卷数据模型实现
@implementation PaperModel

#pragma mark 初始化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if((self = [super init]) && dict && dict.count > 0){
        NSLog(@"试卷反序列化初始化...");
        NSArray *keys = dict.allKeys;
        //试卷ID
        if([keys containsObject:__kPaperModel_keys_code]){
            id value = [dict objectForKey:__kPaperModel_keys_code];
            _code = (value == [NSNull null] ? @"" : value);
        }
        //试卷名称
        if([keys containsObject:__kPaperModel_keys_name]){
            id value = [dict objectForKey:__kPaperModel_keys_name];
            _name = (value == [NSNull null] ? @"" : value);
        }
        //试卷描述信息
        if([keys containsObject:__kPaperModel_keys_desc]){
            id value = [dict objectForKey:__kPaperModel_keys_desc];
            _desc = (value == [NSNull null] ? @"" : value);
        }
        //试卷来源
        if([keys containsObject:__kPaperModel_keys_source]){
            id value = [dict objectForKey:__kPaperModel_keys_source];
            _source = (value == [NSNull null] ? @"" : value);
        }
        //所属地区
        if([keys containsObject:__kPaperModel_keys_area]){
            id value = [dict objectForKey:__kPaperModel_keys_area];
            _area = (value == [NSNull null] ? @"" : value);
        }
        //试卷类型
        if([keys containsObject:__kPaperModel_keys_type]){
            id value = [dict objectForKey:__kPaperModel_keys_type];
            _type = (value == [NSNull null] ? 0 : [(NSNumber *)value integerValue]);
        }
        //考试时长
        if([keys containsObject:__kPaperModel_keys_time]){
            id value = [dict objectForKey:__kPaperModel_keys_time];
            _time = (value == [NSNull null] ? 0 : [(NSNumber *)value integerValue]);
        }
        //使用年份
        if([keys containsObject:__kPaperModel_keys_year]){
            id value = [dict objectForKey:__kPaperModel_keys_year];
            _year = (value == [NSNull null] ? 0 : [(NSNumber *)value integerValue]);
        }
        //试题数
        if([keys containsObject:__kPaperModel_keys_total]){
            id value = [dict objectForKey:__kPaperModel_keys_total];
            _total = (value == [NSNull null] ? 0 : [(NSNumber *)value integerValue]);
        }
        //试卷总分
        if([keys containsObject:__kPaperModel_keys_score]){
            id value = [dict objectForKey:__kPaperModel_keys_score];
            _score = (value == [NSNull null] ? @0 : value);
        }
        //试卷结构
        if([keys containsObject:__kPaperModel_keys_structures]){
            id value = [dict objectForKey:__kPaperModel_keys_structures];
            if(value && [value isKindOfClass:[NSArray class]]){
                PaperStructureModel *model = [[PaperStructureModel alloc] init];
                _structures = [model deserializeWithJSONArrays:(NSArray *)value];
            }
        }
    }
    return self;
}

#pragma mark 将JSON反序列化处理
-(instancetype)initWithJSON:(NSString *)json{
    NSLog(@"将JSON反序列化=>%@",json);
    if(json && json.length > 0){
        NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
        if(data && data.length > 0){
            //JSON处理
            NSError *err;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
            if(err){
                NSLog(@"试卷数据模型JSON反序列化配置错误: %@",err);
            }else{
                return [self initWithDict:dict];
            }
        }
    }
    return nil;
}

#pragma mark 序列化
-(NSDictionary *)serialize{
    NSLog(@"试卷列序化...");
    NSMutableArray *arrays = nil;
    if(_structures && _structures.count > 0){
        arrays = [NSMutableArray arrayWithCapacity:_structures.count];
        for(PaperStructureModel *model in _structures){
            if(!model) continue;
            NSDictionary *dict = [model serialize];
            if(dict && dict.count > 0){
                [arrays addObject:dict];
            }
        }
    }
    return @{__kPaperModel_keys_code : (_code ? _code : @""),
             __kPaperModel_keys_name : (_name ? _name : @""),
             __kPaperModel_keys_desc : (_desc ? _desc : @""),
             __kPaperModel_keys_source : (_source ? _source : @""),
             __kPaperModel_keys_area : (_area ? _area : @""),
             __kPaperModel_keys_type : [NSNumber numberWithInteger:_type],
             __kPaperModel_keys_time : [NSNumber numberWithInteger:_time],
             __kPaperModel_keys_year : [NSNumber numberWithInteger:_year],
             __kPaperModel_keys_score : (_score ? _score : @0),
             __kPaperModel_keys_structures : (!arrays || arrays.count == 0) ? @[] : [arrays copy]};
}

#pragma mark 试卷类型名称
+(NSString *)nameWithPaperType:(NSUInteger)paperType{
    if(paperType > 0 && paperType <= __kPaperModel_PaperReviewTypes.count){
        NSString *name = [__kPaperModel_PaperReviewTypes objectAtIndex:(paperType - 1)];
        NSLog(@"加载试卷类型[%d]的名称[%@]...", (int)paperType, name);
        return name;
    }
    return nil;
}
@end
