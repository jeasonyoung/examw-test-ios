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
             __k_paperitemrecord_fields_itemContent:(self.itemContent ? self.itemContent : @""),
             __k_paperitemrecord_fields_answer:(self.answer ? self.answer : @""),
             __k_paperitemrecord_fields_status:[NSNumber numberWithInteger:self.status],
             __k_paperitemrecord_fields_score:(self.score ? self.score : [NSNumber numberWithInteger:0]),
             __k_paperitemrecord_fields_useTimes:[NSNumber numberWithInteger:self.useTimes],
             __k_paperitemrecord_fields_createTime:(self.createTime ? self.createTime : @""),
             __k_paperitemrecord_fields_lastTime:(self.lastTime ? self.lastTime : @"")};
}
@end
