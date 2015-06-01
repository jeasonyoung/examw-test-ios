//
//  PaperSegmentModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/1.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"
//试卷分段数据模型
@interface PaperSegmentModel : NSObject<JSONSerialize>
//分段值
@property(nonatomic,assign)NSUInteger segValue;
//科目ID
@property(nonatomic,copy)NSString *subjectId;
//科目名称
@property(nonatomic,copy)NSString *subjectName;
//试题汇总
@property(nonatomic,assign)NSUInteger total;
@end
