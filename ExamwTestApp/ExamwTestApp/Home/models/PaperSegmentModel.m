//
//  PaperSegmentModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/1.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperSegmentModel.h"

#define __kPaperSegmentModel_keys_subjectId @"subjectId"//科目ID
#define __kPaperSegmentModel_keys_subjectName @"subjectName"//科目名称
#define __kPaperSegmentModel_keys_total @"total"//试题数

//试卷分段数据模型实现
@implementation PaperSegmentModel

#pragma mark 初始化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if((self = [super init]) && dict && dict.count > 0){
        NSArray *keys = dict.allKeys;
        //科目ID
        if([keys containsObject:__kPaperSegmentModel_keys_subjectId]){
            id value = [dict objectForKey:__kPaperSegmentModel_keys_subjectId];
            _subjectId = (value == [NSNull null] ? @"" : value);
        }
        //科目名称
        if([keys containsObject:__kPaperSegmentModel_keys_subjectName]){
            id value = [dict objectForKey:__kPaperSegmentModel_keys_subjectName];
            _subjectName = (value == [NSNull null] ? @"" : value);
        }
        //试题数
        if([keys containsObject:__kPaperSegmentModel_keys_total]){
            id value = [dict objectForKey:__kPaperSegmentModel_keys_total];
            _total = (value == [NSNull null] ? 0 : ((NSNumber *)value).integerValue);
        }
    }
    return self;
}

#pragma mark 序列化
-(NSDictionary *)serialize{
    return @{__kPaperSegmentModel_keys_subjectId : (_subjectId ? _subjectId : @""),
             __kPaperSegmentModel_keys_subjectName : (_subjectName ? _subjectName : @""),
             __kPaperSegmentModel_keys_total : [NSNumber numberWithInteger:_total]};
}
@end
