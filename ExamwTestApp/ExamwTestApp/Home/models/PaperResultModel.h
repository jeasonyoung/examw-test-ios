//
//  PaperResultModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/1.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaperRecordModel.h"

//试卷结果数据模型
@interface PaperResultModel : PaperRecordModel
//总题数
@property(nonatomic,assign)NSUInteger total;
//做错题数
@property(nonatomic,assign)NSUInteger errors;
//未做题数
@property(nonatomic,assign)NSUInteger nots;
//开始时间
@property(nonatomic,copy)NSString *createTime;
//结束时间
@property(nonatomic,copy)NSString *lastTime;
@end
