//
//  JSONSerialize.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSDictionary;
//序列化为JSON的协议
@protocol JSONSerialize <NSObject>
//序列化为JSON的数据集合
-(NSDictionary *)serializeJSON;
@end