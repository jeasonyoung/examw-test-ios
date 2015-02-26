//
//  SubjectData.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "SubjectData.h"
//考试科目数据
@implementation SubjectData
//序列化
-(NSDictionary *)serializeJSON{
    return @{__k_subjectdata_fields_code : (self.code ? self.code : @""),
             __k_subjectdata_fields_name : (self.name ? self.name : @""),
             __k_subjectdata_fields_status : [NSNumber numberWithInteger:self.status],
             __k_subjectdata_fields_exam_code : (self.examCode ? self.examCode : @"")};
}
@end
