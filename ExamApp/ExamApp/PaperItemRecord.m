//
//  PaperItemRecord.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemRecord.h"
//做题记录类实现
@implementation PaperItemRecord
//序列化
-(NSDictionary *)serializeJSON{
    return @{__k_paperitemrecord_fields_code:(self.code ? self.code : @""),
             __k_paperitemrecord_fields_paperRecordCode:(self.paperRecordCode ? self.paperRecordCode : @""),
             __k_paperitemrecord_fields_structureCode:(self.structureCode ? self.structureCode : @""),
             __k_paperitemrecord_fields_itemCode:(self.itemCode ? self.itemCode : @""),
             __k_paperitemrecord_fields_itemType:(self.itemType ? self.itemType : [NSNumber numberWithInt:0]),
             __k_paperitemrecord_fields_itemContent:(self.itemContent ? self.itemContent : @""),
             __k_paperitemrecord_fields_answer:(self.answer ? self.answer : @""),
             __k_paperitemrecord_fields_status:(self.status ? self.status : [NSNumber numberWithInt:0]),
             __k_paperitemrecord_fields_score:(self.score ? self.score : [NSNumber numberWithDouble:0]),
             __k_paperitemrecord_fields_useTimes:(self.useTimes ? self.useTimes : [NSNumber numberWithDouble:0]),
             __k_paperitemrecord_fields_createTime:(self.createTime ? self.createTime : @""),
             __k_paperitemrecord_fields_lastTime:(self.lastTime ? self.lastTime : @"")};
}
@end
