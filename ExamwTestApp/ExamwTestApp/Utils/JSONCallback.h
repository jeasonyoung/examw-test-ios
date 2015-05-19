//
//  JSONCallback.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"
//HTTP反馈JSON数据模型
@interface JSONCallback : NSObject<JSONSerialize>
//是否成功。
@property(nonatomic,assign,readonly)BOOL success;
//返回数据。
@property(nonatomic,assign,readonly)id data;
//反馈消息
@property(nonatomic,copy,readonly)NSString *msg;

//静态序列化
+(instancetype)callbackWithDict:(NSDictionary *)dict;
@end
