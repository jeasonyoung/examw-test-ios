//
//  PaperData.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"
#import "PaperReview.h"
//字段名称宏定义
#define __k_paperdata_fields_code @"id"//试卷ID
#define __k_paperdata_fields_title @"title"//试卷标题
#define __k_paperdata_fields_type @"type"//试卷类型
#define __k_paperdata_fields_total @"total"//试题数
#define __k_paperdata_fields_content @"content"//试卷内容
#define __k_paperdata_fields_createTime @"createTime"//创建时间
#define __k_paperdata_fields_subjectCode @"subjectCode"//所属科目代码

//试卷数据
@interface PaperData : NSObject<JSONSerialize>
//试卷ID
@property(nonatomic,copy)NSString *code;
//试卷名称
@property(nonatomic,copy)NSString *title;
//试卷类型
@property(nonatomic,assign)NSInteger type;
//试题数
@property(nonatomic,assign)NSInteger total;
//试卷内容
@property(nonatomic,copy)NSString *content;
//所属科目代码
@property(nonatomic,copy)NSString *subjectCode;
//创建时间
@property(nonatomic,copy)NSDate *createTime;
//初始化数据
-(instancetype)initWithDictionary:(NSDictionary *)dict;
//静态反序列化
+(NSArray *)deSerializeWithArray:(NSArray *)array;
@end