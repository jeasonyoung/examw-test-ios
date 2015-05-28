//
//  PaperItemAnalysisModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaperItemOptModel.h"
//试题答案解析数据模型
@interface PaperItemAnalysisModel : PaperItemOptModel
//选项集合
@property(nonatomic,copy)NSArray *options;
@end
