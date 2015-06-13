//
//  PaperItemModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/23.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"

//试题题型
typedef NS_ENUM(NSUInteger,PaperItemType){
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
//判断题答案枚举
typedef NS_ENUM(NSUInteger, PaperItemJudgeAnswer){
    //错误
    PaperItemJudgeAnswerWrong = 0x00,
    //正确
    PaperItemJudgeAnswerRight = 0x01
};

//试题数据模型
@interface PaperItemModel : NSObject<JSONSerialize>

//所属试卷结构ID
@property(nonatomic,copy)NSString *structureId;

//所属试卷结构名称
@property(nonatomic,copy)NSString *structureTitle;

//每题分数
@property(nonatomic,copy)NSNumber *structureScore;

//每题最少得分
@property(nonatomic,copy)NSNumber *structureMin;

//试题ID
@property(nonatomic,copy,readonly)NSString *itemId;

//试题记录ID
@property(nonatomic,copy)NSString *itemRecordId;

//所属试卷记录ID
@property(nonatomic,copy)NSString *paperRecordId;

//题型
@property(nonatomic,assign,readonly)NSUInteger itemType;

//试题内容
@property(nonatomic,copy,readonly)NSString *itemContent;
//试题内容图片URLs
@property(nonatomic,copy,readonly)NSArray *itemContentImgUrls;

//试题答案
@property(nonatomic,copy,readonly)NSString *itemAnswer;

//试题解析
@property(nonatomic,copy,readonly)NSString *itemAnalysis;
//试题解析图片集合
@property(nonatomic,copy,readonly)NSArray *itemAnalysisImgUrls;

//试题难度值
@property(nonatomic,assign,readonly)NSUInteger itemLevel;

//试题排序号
@property(nonatomic,assign,readonly)NSInteger order;

//包含试题数目
@property(nonatomic,assign,readonly)NSUInteger count;

//试题索引
@property(nonatomic,assign)NSUInteger index;

//子试题集合
@property(nonatomic,copy,readonly)NSArray *children;

//将JSON反序列化处理
-(instancetype)initWithJSON:(NSString *)json;

//从JSON的Arrays的反序列化为对象数组
-(NSArray *)deserializeWithJSONArrays:(NSArray *)arrays;

//序列化为JSON字符串
-(NSString *)serializeJSON;

//题型名称
+(NSString *)nameWithItemType:(NSUInteger)itemType;

//判断题答案名称
+(NSString *)nameWithItemJudgeAnswer:(NSUInteger)itemJudgeAnswer;
@end
