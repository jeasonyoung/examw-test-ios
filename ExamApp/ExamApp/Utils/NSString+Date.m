//
//  NSString+Date.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/23.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import "NSString+Date.h"
#import "NSDate+TimeZone.h"

#define __k_default_date_format "yyyy-MM-dd HH:mm:ss"
//日期处理
@implementation NSString (Date)
#pragma mark 将日期转为指定格式的字符串
+(NSString *)stringFromDate:(NSDate *)date withDateFormat:(NSString *)format{
    if(!date)return nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    //[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}
#pragma mark 将日期转为默认格式的字符串
+(NSString *)stringFromDate:(NSDate *)date{
    return [NSString stringFromDate:date withDateFormat:@__k_default_date_format];
}
#pragma mark 将日期格式的字符串转换为日期对象
-(NSDate *)toDateWithFormat:(NSString *)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:(format == nil ? @__k_default_date_format : format)];
    //NSDate *target = [[dateFormatter dateFromString:self] localTime];
    //NSLog(@"self -format- target ===> %@  -> %@",self, target);
   // return target;
    return [dateFormatter dateFromString:self];
}
@end
