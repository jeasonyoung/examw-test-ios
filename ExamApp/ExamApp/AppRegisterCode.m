//
//  AppRegisterCode.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/18.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AppRegisterCode.h"

#define __k_appregistercode_parameters_code @"code"

@implementation AppRegisterCode
//初始化处理
-(instancetype)initWithCode:(NSString *)code{
    if(self = [super init]){
        [self setCode:code];
    }
    return self;
}
//JSON序列化
-(NSDictionary *)serializeJSON{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super serializeJSON]];
    [dict setValue:self.code forKey:__k_appregistercode_parameters_code];
    return dict;
}
@end
