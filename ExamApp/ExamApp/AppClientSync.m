//
//  AppClientSync.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AppClientSync.h"

#define __k_appclientsync_parameters_code @"code"
#define __k_appclientsync_parameters_ignoreCode @"ignoreCode"
#define __k_appclientsync_parameters_startTime @"startTime"

//客户端同步请求数据实现
@implementation AppClientSync
#pragma mark 重载JSON序列化
-(NSDictionary *)serializeJSON{
    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:[super serializeJSON]];
    //注册码
    [json setObject:(self.code ? self.code : @"") forKey:__k_appclientsync_parameters_code];
    //是否忽略注册码
    [json setObject:[NSNumber numberWithBool:self.ignoreCode] forKey:__k_appclientsync_parameters_ignoreCode];
    //同步起始时间
    if(self.startTime){//同步起始时间
        [json setObject:self.startTime forKey:__k_appclientsync_parameters_startTime];
    }
    return [json mutableCopy];
}
@end