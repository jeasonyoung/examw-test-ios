//
//  PaperStructureModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/23.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"

//试卷结构数据模型
@interface PaperStructureModel : NSObject<JSONSerialize>

//结构ID
@property(nonatomic,copy,readonly)NSString *code;

//结构名称
@property(nonatomic,copy,readonly)NSString *title;

//结构描述
@property(nonatomic,copy,readonly)NSString *desc;

//题型值
@property(nonatomic,assign,readonly)NSInteger type;

//试题总数
@property(nonatomic,assign,readonly)NSInteger total;

//每题分数
@property(nonatomic,copy,readonly)NSNumber *score;

//每题最少得分
@property(nonatomic,copy,readonly)NSNumber *min;

//分数比例
@property(nonatomic,copy,readonly)NSNumber *ratio;

//排序号
@property(nonatomic,assign,readonly)NSInteger order;

//试题集合
@property(nonatomic,copy,readonly)NSArray *items;

//子结构数组集合
@property(nonatomic,copy,readonly)NSArray *children;

//从JSON的Arrays的反序列化为对象数组
-(NSArray *)deserializeWithJSONArrays:(NSArray *)arrays;

@end
