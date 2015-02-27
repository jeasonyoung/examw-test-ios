//
//  AppClientSync.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AppClientSync.h"

#define __k_appclientsync_parameters_code @"code"

//客户端同步请求数据实现
@implementation AppClientSync
#pragma mark 重载JSON序列化
-(NSDictionary *)serializeJSON{
    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:[super serializeJSON]];
    [json setObject:(self.code ? self.code : @"") forKey:__k_appclientsync_parameters_code];
    return [json mutableCopy];
}
@end