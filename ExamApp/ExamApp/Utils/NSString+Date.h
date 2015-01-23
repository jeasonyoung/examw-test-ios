//
//  NSString+Date.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/23.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//日期字符串处理
@interface NSString (Date)
//将日期转换为字符串
+(NSString *)stringFromDate:(NSDate *)date;
//将日期转换为指定格式的字符串
+(NSString *)stringFromDate:(NSDate *)date withDateFormat:(NSString *)format;
//将字符串转换为日期对象
-(NSDate *)toDateWithFormat:(NSString *)format;
@end
