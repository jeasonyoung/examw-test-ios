//
//  PaperData.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperData.h"
//试卷数据实现类
@implementation PaperData
#pragma mark 初始化
-(instancetype)initWithDictionary:(NSDictionary *)dict{
    if((self = [super init]) && dict && dict.count > 0){
        self.code = [dict objectForKey:__k_paperdata_fields_code];
        self.title = [dict objectForKey:__k_paperdata_fields_title];
        NSNumber *typeNum = [dict objectForKey:__k_paperdata_fields_type];
        if(typeNum){
            self.type = typeNum.integerValue;
        }
        NSNumber *totalNum = [dict objectForKey:__k_paperdata_fields_total];
        if(totalNum){
            self.total = totalNum.integerValue;
        }
        self.content = [dict objectForKey:__k_paperdata_fields_content];
        self.createTime = [dict objectForKey:__k_paperdata_fields_createTime];
        self.subjectCode = [dict objectForKey:__k_paperdata_fields_subjectCode];
    }
    return self;
}
#pragma mark 序列化
-(NSDictionary *)serializeJSON{
    return @{__k_paperdata_fields_code:(self.code ? self.code : @""),
             __k_paperdata_fields_title:(self.title ? self.title : @""),
             __k_paperdata_fields_type:[NSNumber numberWithInteger:self.type],
             __k_paperdata_fields_total:[NSNumber numberWithInteger:self.total],
             __k_paperdata_fields_content:(self.content ? self.content : @""),
             __k_paperdata_fields_createTime:(self.createTime ? self.createTime : @""),
             __k_paperdata_fields_subjectCode:(self.subjectCode ? self.subjectCode : @"")};
}
#pragma mark 静态反序列化
+(NSArray *)deSerializeWithArray:(NSArray *)array{
    if(!array || array.count == 0) return nil;
    NSMutableArray *paperArrays = [NSMutableArray array];
    for(NSDictionary *dict in array){
        if(!dict || dict.count == 0) continue;
        PaperData *p = [[PaperData alloc] initWithDictionary:dict];
        if(p){
            [paperArrays addObject:p];
        }
    }
    return [paperArrays mutableCopy];
}
@end