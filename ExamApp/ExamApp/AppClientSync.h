//
//  AppClientSync.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AppClient.h"
//客户端同步请求数据
@interface AppClientSync : AppClient
//注册码
@property(nonatomic,copy)NSString *code;
//同步起始时间
@property(nonatomic,copy)NSString *startTime;
@end
