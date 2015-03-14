//
//  PaperRecord.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperRecord.h"
//试卷记录类实现
@implementation PaperRecord
//序列化
-(NSDictionary *)serializeJSON{
    return @{__k_paperrecord_fields_code:(self.code ? self.code : @""),
             __k_paperrecord_fields_paperCode:(self.paperCode ? self.paperCode : @""),
             __k_paperrecord_fields_status:(self.status ? self.status : [NSNumber numberWithInt:0]),
             __k_paperrecord_fields_score:(self.score ? self.score : [NSNumber numberWithInteger:0]),
             __k_paperrecord_fields_rights:(self.rights ? self.rights : [NSNumber numberWithInteger:0]),
             __k_paperrecord_fields_useTimes:(self.useTimes ? self.useTimes : [NSNumber numberWithInteger:0]),
             __k_paperrecord_fields_createTime:(self.createTime ? self.createTime : @""),
             __k_paperrecord_fields_lastTime:(self.lastTime ? self.lastTime : @"")};
}
@end