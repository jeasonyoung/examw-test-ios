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
             __k_paperrecord_fields_status:[NSNumber numberWithInteger:self.status],
             __k_paperrecord_fields_score:(self.score ? self.score : [NSNumber numberWithInteger:0]),
             __k_paperrecord_fields_rights:[NSNumber numberWithInteger:self.rights],
             __k_paperrecord_fields_useTimes:[NSNumber numberWithInteger:self.useTimes],
             __k_paperrecord_fields_createTime:(self.createTime ? self.createTime : @""),
             __k_paperrecord_fields_lastTime:(self.lastTime ? self.lastTime : @"")};
}
@end