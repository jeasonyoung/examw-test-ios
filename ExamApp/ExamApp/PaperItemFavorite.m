//
//  PaperItemFavorite.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemFavorite.h"
//试题收藏实现类
@implementation PaperItemFavorite
//序列化
-(NSDictionary *)serializeJSON{
    return @{__k_paperitemfavorite_fields_code:(self.code ? self.code : @""),
             __k_paperitemfavorite_fields_subjectCode:(self.subjectCode ? self.subjectCode : @""),
             __k_paperitemfavorite_fields_itemCode:(self.itemCode ? self.itemCode : @""),
             __k_paperitemfavorite_fields_itemType:[NSNumber numberWithInteger:self.itemType],
             __k_paperitemfavorite_fields_itemContent:(self.itemContent ? self.itemContent : @""),
             __k_paperitemfavorite_fields_remarks:(self.remarks ? self.remarks : @""),
             __k_paperitemfavorite_fields_status:(self.status ? self.status : [NSNumber numberWithInteger:0]),
             __k_paperitemfavorite_fields_createTime:(self.createTime ? self.createTime : @"")};
}
@end
