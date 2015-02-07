//
//  JSONCallback.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"
//反馈JSON数据模型
@interface JSONCallback : NSObject<JSONSerialize>
//是否成功。
@property(nonatomic,assign)BOOL success;
//数据。
@property(nonatomic,copy)NSString* data;
//消息。
@property(nonatomic,copy)NSString *msg;
//初始化
-(instancetype)initWithDictionary:(NSDictionary *)dict;
@end
