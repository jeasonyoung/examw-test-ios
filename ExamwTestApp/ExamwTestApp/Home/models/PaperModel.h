//
//  PaperModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/23.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"

//试卷类型
typedef NS_ENUM(int, PaperType) {
    //真题
    PaperTypeReal = 0x01,
    //模拟题
    PaperTypeSimu = 0x02,
    //预测题
    PaperTypeForecas = 0x03,
    //练习题
    PaperTypePractice = 0x04,
    //章节练习
    PaperTypeChapter = 0x05,
    //每日一练
    PaperTypeDaily = 0x06
};

//试卷数据模型
@interface PaperModel : NSObject<JSONSerialize>

//试卷ID
@property(nonatomic,copy,readonly)NSString *code;

//试卷名称
@property(nonatomic,copy,readonly)NSString *name;

//试卷描述信息
@property(nonatomic,copy,readonly)NSString *desc;

//试卷来源
@property(nonatomic,copy,readonly)NSString *source;

//所属地区
@property(nonatomic,copy,readonly)NSString *area;

//试卷类型
@property(nonatomic,assign,readonly)NSInteger type;

//考试时长
@property(nonatomic,assign,readonly)NSInteger time;

//使用年份
@property(nonatomic,assign,readonly)NSInteger year;

//试题数
@property(nonatomic,assign,readonly)NSInteger total;

//试卷总分
@property(nonatomic,copy,readonly)NSNumber *score;

//试卷结构
@property(nonatomic,copy,readonly)NSArray *structures;

//将JSON反序列化处理
-(instancetype)initWithJSON:(NSString *)json;

//试卷类型名称
+(NSString *)nameWithPaperType:(NSUInteger)paperType;
@end
