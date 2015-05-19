//
//  JSONSerialize.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//JSON序列化协议
@protocol JSONSerialize <NSObject>
//将Dict反序列化为对象
-(instancetype)initWithDict:(NSDictionary *)dict;
//序列化数据
-(NSDictionary *)serialize;
@end
