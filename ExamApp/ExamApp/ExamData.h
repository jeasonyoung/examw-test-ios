//
//  ExamData.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"

//字段名称宏定义
#define __k_examdata_fields_code @"code"
#define __k_examdata_fields_name @"name"
#define __k_examdata_fields_abbr @"abbr"
#define __k_examdata_fields_status @"status"

#define __k_examdatadao_tableName @"tbl_exams"//考试数据表名称
//考试数据
@interface ExamData : NSObject<JSONSerialize>
//考试代码
@property(nonatomic,copy)NSString *code;
//考试名称
@property(nonatomic,copy)NSString *name;
//考试简称
@property(nonatomic,copy)NSString *abbr;
//考试状态
@property(nonatomic,assign)NSInteger status;
@end
