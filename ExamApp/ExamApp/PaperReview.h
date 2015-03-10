//
//  PaperPreview.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"
//试卷
@interface PaperReview: NSObject<JSONSerialize>
//试卷ID
@property(nonatomic,copy)NSString *code;
//试卷名称
@property(nonatomic,copy)NSString *name;
//试卷描述信息
@property(nonatomic,copy)NSString *desc;
//试卷来源
@property(nonatomic,copy)NSString *sourceName;
//所属地区
@property(nonatomic,copy)NSString *areaName;
//试卷类型
@property(nonatomic,assign)NSInteger type;
//考试时长
@property(nonatomic,assign)NSInteger time;
//使用年份
@property(nonatomic,assign)NSInteger year;
//试题数
@property(nonatomic,assign)NSInteger total;
//试卷总分
@property(nonatomic,copy)NSNumber *score;
//试卷结构
@property(nonatomic,copy)NSArray *structures;
//初始化
-(instancetype)initWithDictionary:(NSDictionary *)dict;
//初始化
-(instancetype)initWithJSON:(NSString *)json;
//序列化为JSON字符串
-(NSString *)serialize;
@end
//试卷结构
@interface PaperStructure : NSObject<JSONSerialize>
//结构ID
@property(nonatomic,copy)NSString *code;
//结构名称
@property(nonatomic,copy)NSString *title;
//结构描述
@property(nonatomic,copy)NSString *desc;
//题型名称
@property(nonatomic,copy)NSString *typeName;
//题型值
@property(nonatomic,assign)NSInteger type;
//试题总数
@property(nonatomic,assign)NSInteger total;
//每题分数
@property(nonatomic,copy)NSNumber *score;
//每题最少得分
@property(nonatomic,assign)NSNumber *min;
//分数比例
@property(nonatomic,assign)NSNumber *ratio;
//排序号
@property(nonatomic,assign)NSInteger orderNo;
//试题集合
@property(nonatomic,copy)NSArray *items;
//子结构数组集合
@property(nonatomic,copy)NSArray *children;
//初始化
-(instancetype)initWithDictionary:(NSDictionary *)dict;
//初始化
-(instancetype)initWithJSON:(NSString *)json;
//反序列化
+(NSArray *)deSerializeWithArray:(NSArray *)array;
//序列化为JSON字符串
-(NSString *)serialize;
@end
//试题题型
typedef NS_ENUM(NSInteger,PaperItemType){
    //单选
    PaperItemTypeSingle = 0x01,
    //多选
    PaperItemTypeMulty = 0x02,
    //不定向选
    PaperItemTypeUncertain = 0x03,
    //判断题
    PaperItemTypeJudge = 0x04,
    //问答题
    PaperItemTypeQanda = 0x05,
    //共享题干题
    PaperItemTypeShareTitle = 0x06,
    //共享答案题
    PaperItemTypeShareAnswer = 0x07
};
//试卷试题
@interface PaperItem : NSObject<JSONSerialize>
//试题ID
@property(nonatomic,copy)NSString *code;
//题型名称
@property(nonatomic,copy)NSString *typeName;
//题型值
@property(nonatomic,assign)NSInteger type;
//试题内容
@property(nonatomic,copy)NSString *content;
//试题答案
@property(nonatomic,copy)NSString *answer;
//试题解析
@property(nonatomic,copy)NSString *analysis;
//试题难度值
@property(nonatomic,assign)NSInteger level;
//试题排序号
@property(nonatomic,assign)NSInteger orderNo;
//包含试题数目
@property(nonatomic,assign)NSInteger count;
//子试题集合
@property(nonatomic,copy)NSArray *children;
//初始化
-(instancetype)initWithDictionary:(NSDictionary *)dict;
//初始化
-(instancetype)initWithJSON:(NSString *)json;
//反序列化
+(NSArray *)deSerializeWithArray:(NSArray *)array;
//序列化为JSON字符串
-(NSString *)serialize;
@end
