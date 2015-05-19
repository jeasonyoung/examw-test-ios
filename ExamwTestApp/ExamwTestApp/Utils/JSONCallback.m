//
//  JSONCallback.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "JSONCallback.h"

#define __kJSONCallback_keys_success @"success"//
#define __kJSONCallback_keys_data @"data"//
#define __kJSONCallback_keys_msg @"msg"//
//HTTP反馈JSON数据模型实现
@implementation JSONCallback
#pragma mark 反序列化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if((self = [super init]) && dict && dict.count > 0){
        NSArray *keys = dict.allKeys;
        //success
        if([keys containsObject:__kJSONCallback_keys_success]){
            [self setValue:[dict objectForKey:__kJSONCallback_keys_success] forKey:__kJSONCallback_keys_success];
        }
        //data
        if([keys containsObject:__kJSONCallback_keys_data]){
            [self setValue:[dict objectForKey:__kJSONCallback_keys_data] forKey:__kJSONCallback_keys_data];
        }
        //msg
        if([keys containsObject:__kJSONCallback_keys_msg]){
            [self setValue:[dict objectForKey:__kJSONCallback_keys_msg] forKey:__kJSONCallback_keys_msg];
        }
    }
    return self;
}
#pragma mark 序列化
-(NSDictionary *)serialize{
    return @{
             __kJSONCallback_keys_success:[NSNumber numberWithBool:_success],
             __kJSONCallback_keys_data:_data,
             __kJSONCallback_keys_msg:_msg
             };
}
#pragma mark 静态序列化
+(instancetype)callbackWithDict:(NSDictionary *)dict{
    return [[self alloc]initWithDict:dict];
}
@end
