//
//  AppClientSync.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"
//客户端同步请求数据模型
@interface AppClientSync : NSObject<JSONSerialize>
//客户端ID
@property(nonatomic,copy,readonly)NSString *clientId;
//客户端名称
@property(nonatomic,copy,readonly)NSString *clientName;
//客户端版本
@property(nonatomic,copy,readonly)NSString *clientVersion;
//客户端类型代码
@property(nonatomic,copy,readonly)NSString *clientTypeCode;
//客户端机器码
@property(nonatomic,copy,readonly)NSString *clientMachine;
//产品ID
@property(nonatomic,copy,readonly)NSString *productId;
//注册码
@property(nonatomic,copy,readonly)NSString *code;
//忽略注册码
@property(nonatomic,assign)BOOL ignoreCode;
//同步起始时间
@property(nonatomic,copy)NSString *startTime;
@end
