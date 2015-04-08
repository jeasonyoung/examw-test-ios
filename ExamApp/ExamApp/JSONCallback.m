//
//  JSONCallback.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "JSONCallback.h"

#define __k_jsoncallback_field_success @"success"//
#define __k_jsoncallback_field_data @"data"//
#define __k_jsoncallback_field_msg @"msg"//
//反馈JSON数据模型成员变量
@interface JSONCallback(){
    
}
@end
//反馈JSON数据模型实现类
@implementation JSONCallback
#pragma mark 初始化
-(instancetype)initWithDictionary:(NSDictionary *)dict{
    if((self = [super init]) && dict && dict.count > 0){
        for(NSString *key in dict.allKeys){
            if(!key || key.length == 0)continue;
            [self setValue:[dict objectForKey:key] forKey:key];
        }
    }
    return self;
}
#pragma mark 序列化
-(NSDictionary *)serializeJSON{
    return @{__k_jsoncallback_field_success:[NSNumber numberWithBool:self.success],
             __k_jsoncallback_field_msg:self.msg,
             __k_jsoncallback_field_data:self.data};
}
#pragma mark 静态化处理
+(instancetype)callbackWithDictionary:(NSDictionary *)dict{
    return [[self alloc] initWithDictionary:dict];
}
@end
