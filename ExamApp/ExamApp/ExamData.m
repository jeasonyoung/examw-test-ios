//
//  ExamData.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ExamData.h"
//考试数据
@implementation ExamData
//序列化
-(NSDictionary *)serializeJSON{
    return @{__k_examdata_fields_code:(self.code ? self.code : @""),
             __k_examdata_fields_name:(self.name ? self.name : @""),
             __k_examdata_fields_abbr:(self.abbr ? self.abbr : @""),
             __k_examdata_fields_status:[NSNumber numberWithInteger:self.status]};
}
@end
