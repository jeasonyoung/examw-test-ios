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
typedef NS_ENUM(int,PaperItemType){
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
typedef NS_ENUM(int, PaperItemJudgeAnswer){
    //错误
    PaperItemJudgeAnswerWrong = 0x00,
    //正确
    PaperItemJudgeAnswerRight = 0x01
};

//试题数据模型
@interface PaperItemModel : NSObject<JSONSerialize>

//试题ID
@property(nonatomic,copy,readonly)NSString *itemId;

//题型
@property(nonatomic,assign,readonly)NSUInteger itemType;

//试题内容
@property(nonatomic,copy,readonly)NSString *itemContent;

//试题答案
@property(nonatomic,copy,readonly)NSString *itemAnswer;

//试题解析
@property(nonatomic,copy,readonly)NSString *itemAnalysis;

//试题难度值
@property(nonatomic,assign,readonly)NSUInteger itemLevel;

//试题排序号
@property(nonatomic,assign,readonly)NSInteger order;

//包含试题数目
@property(nonatomic,assign,readonly)NSUInteger count;

//子试题集合
@property(nonatomic,copy,readonly)NSArray *children;

//从JSON的Arrays的反序列化为对象数组
-(NSArray *)deserializeWithJSONArrays:(NSArray *)arrays;

//题型名称
+(NSString *)nameWithItemType:(NSUInteger)itemType;

//判断题答案名称
+(NSString *)nameWithItemJudgeAnswer:(NSUInteger)itemJudgeAnswer;
@end
