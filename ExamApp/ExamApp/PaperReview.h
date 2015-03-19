//
//  PaperPreview.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/28.
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
    //正确
    PaperItemJudgeAnswerWrong = 0x00,
    //错误
    PaperItemJudgeAnswerRight = 0x01
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
@property(nonatomic,copy,readonly)NSArray *children;
//初始化
-(instancetype)initWithDictionary:(NSDictionary *)dict;
//初始化
-(instancetype)initWithJSON:(NSString *)json;
//反序列化
+(NSArray *)deSerializeWithArray:(NSArray *)array;
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
@property(nonatomic,copy)NSNumber *min;
//分数比例
@property(nonatomic,copy)NSNumber *ratio;
//排序号
@property(nonatomic,assign)NSInteger orderNo;
//试题集合
@property(nonatomic,copy,readonly)NSArray *items;
//子结构数组集合
@property(nonatomic,copy,readonly)NSArray *children;
//初始化
-(instancetype)initWithDictionary:(NSDictionary *)dict;
//初始化
-(instancetype)initWithJSON:(NSString *)json;
//反序列化
+(NSArray *)deSerializeWithArray:(NSArray *)array;
//序列化为JSON字符串
-(NSString *)serialize;
@end

//试题索引
@interface PaperItemOrderIndexPath : NSObject
//总序号
@property(nonatomic,assign,readonly)NSInteger order;
//所属大题代码
@property(nonatomic,copy,readonly)NSString *structureCode;
//所属大题标题
@property(nonatomic,copy,readonly)NSString *structureTitle;
//试题
@property(nonatomic,copy,readonly)PaperItem *item;
//试题内索引(共享题)
@property(nonatomic,assign,readonly)NSInteger index;
//初始化
-(instancetype)initWithOrder:(NSInteger)order
               StructureCode:(NSString *)code
              StructureTitle:(NSString *)title
                        Item:(PaperItem *)item
                       Index:(NSInteger)index;
//静态初始化
+(instancetype)paperOrder:(NSInteger)order
            StructureCode:(NSString *)code
           StructureTitle:(NSString *)title
                     Item:(PaperItem *)item
                    Index:(NSInteger)index;
@end

//试卷类型
typedef NS_ENUM(int, PaperType) {
    //真题
    PaperTypeReal = 1,
    //模拟题
    PaperTypeSimu = 2,
    //预测题
    PaperTypeForecas = 3,
    //练习题
    PaperTypePractice = 4,
    //章节练习
    PaperTypeChapter = 5,
    //每日一练
    PaperTypeDaily = 6
};
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
@property(nonatomic,copy,readonly)NSArray *structures;
//初始化
-(instancetype)initWithDictionary:(NSDictionary *)dict;
//初始化
-(instancetype)initWithJSON:(NSString *)json;
//按顺序加载答题卡序号
-(void)loadAnswersheet:(void(^)(NSString *text,NSArray *indexPaths))structures;
//按索引加载试题(索引从0开始)
-(void)loadItemAtOrder:(NSInteger)order ItemBlock:(void(^)(PaperItemOrderIndexPath *indexPath))block;
//根据试题ID加载题序
-(NSInteger)findOrderAtItemCode:(NSString *)itemCode;
//根据结构ID查找结构
-(void)findStructureAtStructureCode:(NSString *)code StructureBlock:(void(^)(PaperStructure *ps))block;
//序列化为JSON字符串
-(NSString *)serialize;
@end
