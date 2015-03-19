//
//  NSDate+TimeZone.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/23.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//当前时区处理
@interface NSDate (TimeZone)
//获取当前时间的静态方法
+(NSDate *)currentLocalTime;
//将当前GMT时间转换为本地时间
//-(NSDate *)localTime;
//比较两个日期相差的正书天数
-(int)dayIntervalSinceDate:(NSDate *)since;
@end
