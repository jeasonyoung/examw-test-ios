//
//  AppClient.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"
#import "AppConstant.h"
//应用客户端基类
@interface AppClient : NSObject<JSONSerialize>
//客户端ID
@property(nonatomic,copy)NSString *clientId;
//客户端名称
@property(nonatomic,copy)NSString *clientName;
//客户端版本
@property(nonatomic,copy)NSString *clientVersion;
@end