//
//  AppClientSync.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppClient.h"
//客户端同步请求数据模型
@interface AppClientSync : AppClient
//注册码
@property(nonatomic,copy,readonly)NSString *code;
//忽略注册码
@property(nonatomic,assign)BOOL ignoreCode;
//同步起始时间
@property(nonatomic,copy)NSString *startTime;
@end
