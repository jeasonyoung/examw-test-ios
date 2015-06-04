//
//  AppClient.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSONSerialize.h"

@class AppSettings;
//应用客户端
@interface AppClient : NSObject<JSONSerialize>
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
@end
