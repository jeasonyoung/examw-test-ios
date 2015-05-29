//
//  PaperItemModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/23.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemModel.h"

#define __kPaperItemModel_keys_id @"id"//试题ID
#define __kPaperItemModel_keys_type @"type"//试题类型
#define __kPaperItemModel_keys_content @"content"//试题内容
#define __kPaperItemModel_keys_answer @"answer"//试题答案
#define __kPaperItemModel_keys_analysis @"analysis"//试题解析
#define __kPaperItemModel_keys_level @"level"//试题难度值
#define __kPaperItemModel_keys_order @"orderNo"//试题排序号
#define __kPaperItemModel_keys_count @"count"//包含试题总数
#define __kPaperItemModel_keys_children @"children"//子试题集合

#define __kPaperItemModel_itemTypes @[@"单选",@"多选",@"不定向选择",@"判断题",@"问答题",@"共享题干题",@"共享答案题"]//试题类型
#define __kPaperItemModel_judgeAnswers @[@"错误",@"正确"]//判断题答案名称

//试题数据模型实现
@implementation PaperItemModel

#pragma mark 初始化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if((self = [super init]) && dict && dict.count > 0){
        _index = 0;
        NSLog(@"试题反序列化初始化...");
        NSArray *keys = dict.allKeys;
        //试题ID
        if([keys containsObject:__kPaperItemModel_keys_id]){
            id value = [dict objectForKey:__kPaperItemModel_keys_id];
            _itemId = (value == [NSNull null] ? @"" : value);
        }
        //试题类型
        if([keys containsObject:__kPaperItemModel_keys_type]){
            id value = [dict objectForKey:__kPaperItemModel_keys_type];
            _itemType = (value == [NSNull null] ? 0 : [(NSNumber *)value integerValue]);
        }
        //试题内容
        if([keys containsObject:__kPaperItemModel_keys_content]){
            id value = [dict objectForKey:__kPaperItemModel_keys_content];
            _itemContent = (value == [NSNull null] ? @"" : value);
        }
        //试题答案
        if([keys containsObject:__kPaperItemModel_keys_answer]){
            id value = [dict objectForKey:__kPaperItemModel_keys_answer];
            _itemAnswer = (value == [NSNull null] ? @"" : value);
        }
        //试题解析
        if([keys containsObject:__kPaperItemModel_keys_analysis]){
            id value = [dict objectForKey:__kPaperItemModel_keys_analysis];
            _itemAnalysis = (value == [NSNull null] ? @"" : value);
        }
        //试题难度值
        if([keys containsObject:__kPaperItemModel_keys_level]){
            id value = [dict objectForKey:__kPaperItemModel_keys_level];
            _itemLevel = (value == [NSNull null] ? 0 : [(NSNumber *)value integerValue]);
        }
        //试题排序号
        if([keys containsObject:__kPaperItemModel_keys_order]){
            id value = [dict objectForKey:__kPaperItemModel_keys_order];
            _order = (value == [NSNull null] ? 0 : [(NSNumber *)value integerValue]);
        }
        //包含试题总数
        if([keys containsObject:__kPaperItemModel_keys_count]){
            id value = [dict objectForKey:__kPaperItemModel_keys_count];
            _count = (value == [NSNull null] ? 0 : [(NSNumber *)value integerValue]);
        }
        //子试题集合
        if([keys containsObject:__kPaperItemModel_keys_children]){
            id value = [dict objectForKey:__kPaperItemModel_keys_children];
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
            PaperItemModel *model = [[PaperItemModel alloc]initWithDict:dict];
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
    NSMutableArray *childArrays = nil;
    if(_children && _children.count > 0){
        childArrays = [NSMutableArray arrayWithCapacity:_children.count];
        for(PaperItemModel *model in _children){
            if(!model)continue;
            NSDictionary *dict = [model serialize];
            if(dict && dict.count > 0){
                [childArrays addObject:dict];
            }
        }
    }
    //序列化
    return @{__kPaperItemModel_keys_id : (_itemId ? _itemId : @""),
             __kPaperItemModel_keys_type : [NSNumber numberWithInteger:_itemType],
             __kPaperItemModel_keys_content : (_itemContent ? _itemContent : @""),
             __kPaperItemModel_keys_answer : (_itemAnswer ? _itemAnswer : @""),
             __kPaperItemModel_keys_analysis : (_itemAnalysis ? _itemAnalysis : @""),
             __kPaperItemModel_keys_level : [NSNumber numberWithInteger:_itemLevel],
             __kPaperItemModel_keys_order : [NSNumber numberWithInteger:_order],
             __kPaperItemModel_keys_count : [NSNumber numberWithInteger:_count],
             __kPaperItemModel_keys_children : (childArrays ? [childArrays copy] : @[])};
}

#pragma mark 序列化为JSON字符串
-(NSString *)serializeJSON{
    NSLog(@"准备将试题序列化为JSON字符串...");
    NSDictionary *dict = [self serialize];
    if(dict && [NSJSONSerialization isValidJSONObject:dict]){
        NSError *err;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&err];
        if(err){
            NSLog(@"试题转为JSON错误=>%@",err);
            return nil;
        }
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

#pragma mark 题型名称
+(NSString *)nameWithItemType:(NSUInteger)itemType{
    if(itemType > 0 && itemType <= __kPaperItemModel_itemTypes.count){
        NSString *name = [__kPaperItemModel_itemTypes objectAtIndex:(itemType - 1)];
        NSLog(@"加载题型[%d]的名称[%@]...", (int)itemType, name);
        return name;
    }
    return nil;
}

#pragma mark 判断题答案名称
+(NSString *)nameWithItemJudgeAnswer:(NSUInteger)itemJudgeAnswer{
    if(itemJudgeAnswer < __kPaperItemModel_judgeAnswers.count){
        NSString *name = [__kPaperItemModel_judgeAnswers objectAtIndex:itemJudgeAnswer];
        NSLog(@"加载判断题答案[%d]的名称[%@]...", (int)itemJudgeAnswer, name);
        return name;
    }
    return nil;
}
@end
