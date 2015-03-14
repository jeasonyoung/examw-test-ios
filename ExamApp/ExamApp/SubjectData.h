//
//  SubjectData.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"
//科目字段
#define __k_subjectdata_fields_code @"code"//科目代码
#define __k_subjectdata_fields_name @"name"//科目名称
#define __k_subjectdata_fields_status @"status"//科目状态
#define __k_subjectdata_fields_exam_code @"examCode"//所属考试
//科目数据
@interface SubjectData : NSObject<JSONSerialize>
//所属考试代码
@property(nonatomic,copy)NSString *examCode;
//科目代码
@property(nonatomic,copy)NSString *code;
//科目名称
@property(nonatomic,copy)NSString *name;
//科目状态
@property(nonatomic,assign)NSInteger status;
@end
