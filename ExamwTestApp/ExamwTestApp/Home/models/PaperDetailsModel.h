//
//  PaperDetailsModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>

//试卷明细数据模型
@interface PaperDetailsModel : NSObject

//试卷描述
@property(nonatomic,copy)NSString *desc;

//试卷来源
@property(nonatomic,copy)NSString *source;

//所属地区
@property(nonatomic,copy)NSString *area;

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

@end
